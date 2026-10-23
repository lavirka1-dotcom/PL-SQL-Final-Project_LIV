--===================================================================================
--СПЕЦИФІКАЦІЯ ПАКЕТУ UTIL
--===================================================================================
CREATE OR REPLACE PACKAGE util AS
--===================================================================================

--процедура синхронізації курсів валют та запис в таблицю cur_exchange
PROCEDURE api_nbu_sync;
                                   
--===================================================================================
END util;

--===================================================================================
--===================================================================================
--===================================================================================
--ТІЛО ПАКЕТУ UTIL
--===================================================================================
CREATE OR REPLACE PACKAGE BODY util AS
--===================================================================================

--процедура синхронізації курсів валют та запис в таблицю cur_exchange
PROCEDURE api_nbu_sync IS

  v_list_currencies irina_vyx.sys_params.value_text%TYPE; 

BEGIN

  --отримуємо список з переліком валют  
  BEGIN
    <<get_a_list_of_currencies>>

      SELECT value_text
        INTO v_list_currencies
        FROM sys_params
       WHERE param_name = 'list_currencies'; --фільтр про всяк випадок: наприклад, якщо в таблиці з'являться ще якісь параметри     

      --виняток на випадок помилки на етапі зчитування даних з таблиці sys_params: записуємо в таблицю логів помилку
      EXCEPTION
        WHEN OTHERS THEN
          irina_vyx.log_utils.log_error('api_nbu_sync', 'Не вдалося отримати список валют. ' || SQLERRM);
          RAISE_APPLICATION_ERROR(-20001, 'Виникла помилка: ' || SQLERRM);

  END get_a_list_of_currencies;

  --прокручуємо в циклі список валют з таблиці
  FOR cc IN (SELECT value_list AS curr
             FROM TABLE(irina_vyx.util.table_from_list(p_list_val => v_list_currencies))) LOOP

      --робимо інсерт по кожній ітерації в таблицю cur_exchange окремим блоком, щоб перехопити помилки по окремим валютам та записати їх в лог
      BEGIN
        <<insert_into_cur_exchange>>
          
          INSERT INTO irina_vyx.cur_exchange (r030, txt, rate, cur, exchangedate)
          SELECT * FROM TABLE (irina_vyx.util.get_currency(p_currency => cc.curr));

          --перевірка по кожній валюті, чи вставились дані, якщо ні - запис у лог  
          IF
            SQL%ROWCOUNT = 0 THEN
            irina_vyx.log_utils.log_error('api_nbu_sync', ' Для валюти ' || cc.curr || ' даних з НБУ не отримано');

            --цикл не перериваємо, а переходимо до запису наступної валюти
            CONTINUE;

          END IF;

          COMMIT;

      --виняток на випадок будь-якої іншої помилки по валюті у циклі з записом у лог
      EXCEPTION
        WHEN OTHERS THEN
          irina_vyx.log_utils.log_error('api_nbu_sync', ' Для валюти ' || cc.curr || ': ' || SQLERRM);

      --цикл не перериваємо, а переходимо до запису наступної валюти
      CONTINUE;

      END insert_into_cur_exchange;

  END LOOP;      

  --запускаємо процес логування кінця роботи (запис в таблицю логів)
  irina_vyx.log_utils.log_finish('api_nbu_sync');

--виняток на випадок будь-якої іншої помилки з записом у лог
EXCEPTION
    WHEN OTHERS THEN
        irina_vyx.log_utils.log_error('api_nbu_sync', SQLERRM);
        --виводимо помилку на екран
        RAISE;

END api_nbu_sync;

--===================================================================================
END util;
