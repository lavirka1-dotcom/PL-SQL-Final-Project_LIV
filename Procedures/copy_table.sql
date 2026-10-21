CREATE OR REPLACE PROCEDURE copy_table(p_source_scheme IN  VARCHAR2
                                      ,p_target_scheme IN  VARCHAR2 DEFAULT USER
                                      ,p_list_table    IN  VARCHAR2
                                      ,p_copy_data     IN  BOOLEAN  DEFAULT FALSE
                                      ,po_result       OUT VARCHAR2) IS

  v_is_exist_tab    NUMBER;
  v_is_exist_scheme NUMBER;

BEGIN

  --запис в лог про початок копіювання таблиць
  po_result := 'Запуск процесу копіювання таблиць';
  to_log(p_appl_proc => 'copy_table', p_message => po_result);

  --перевірка, чи існує схема-джерело в БД
  SELECT COUNT(*)
    INTO v_is_exist_scheme
    FROM all_users
   WHERE username = UPPER(p_source_scheme); 

  --якщо передана в параметрі схема-джерело не існує, то викликаємо помилку
  --при помилці спрацює зовнішній EXCEPTION та помилка запишеться в лог
  IF v_is_exist_scheme = 0 THEN     
     po_result := 'Схема-джерело ' || p_source_scheme || ' не існує в БД';
     RAISE_APPLICATION_ERROR(-20001, po_result);
  END IF;

  --перевірка, чи існує схема-отримувач в БД
  SELECT COUNT(*)
    INTO v_is_exist_scheme
    FROM all_users
   WHERE username = UPPER(p_target_scheme); 

  --якщо передана в параметрі схема-отримувач не існує, то викликаємо помилку
  --при помилці спрацює зовнішній EXCEPTION та помилка запишеться в лог
  IF v_is_exist_scheme = 0 THEN     
     po_result := 'Схема-отримувач ' || p_target_scheme || ' не існує в БД';
     RAISE_APPLICATION_ERROR(-20001, po_result);
  END IF;

  --перевірка, чи передано список таблиць для копіювання
   IF p_list_table IS NULL THEN     
      po_result := 'Список таблиць для копіювання не надано (заповніть параметр p_list_table)';
      RAISE_APPLICATION_ERROR(-20002, po_result);
   END IF;

  --перевірка, чи всі передані таблиці для копіювання дійсно існують у схемі-джерелі
  FOR ut IN (SELECT value_list
               FROM TABLE(irina_vyx.util.table_from_list(p_list_table))
              WHERE value_list NOT IN (SELECT table_name
                                         FROM all_tables
                                        WHERE owner = p_source_scheme)) LOOP  

    --якщо передана в параметрі таблиця не існує в схемі-джерелі, то записуємо в лог
    po_result := 'Таблиця ' || ut.value_list || ' не існує в схемі-джерелі ' || p_source_scheme;
    to_log(p_appl_proc => 'copy_table', p_message => po_result);

  END LOOP;

  --проходимо по всіх назвах таблиць зі списку та генеруємо DDL-коди для кожної
  FOR cc IN (SELECT table_name
                   ,'CREATE TABLE ' || p_target_scheme || '.' || table_name || ' (' ||
                    listagg(column_name || ' ' || data_type || count_symbol,', ')
                    WITHIN GROUP(ORDER BY column_id) || ')' AS ddl_code
               FROM (SELECT table_name
                           ,column_name
                           ,data_type
                           ,CASE
                              WHEN data_type = 'VARCHAR2' OR data_type = 'CHAR' THEN
                               '(' || data_length || ')'
                              WHEN data_type = 'DATE' THEN
                               NULL
                              WHEN data_type = 'NUMBER' THEN
                               REPLACE('(' || data_precision || ',' || data_scale || ')','(,)', NULL)
                            END AS count_symbol
                           ,column_id
                       FROM all_tab_columns
                      WHERE owner = UPPER(p_source_scheme)
                        AND table_name IN (SELECT value_list
                                             FROM TABLE(irina_vyx.util.table_from_list(p_list_table)))
                      ORDER BY table_name,column_id)
              GROUP BY table_name) LOOP
    BEGIN
      --перевірка на вже існуючі таблиці в схемі-отримувачі
      SELECT COUNT(*)
        INTO v_is_exist_tab
        FROM all_tables
       WHERE owner = UPPER(p_target_scheme)
         AND table_name = cc.table_name;
      --якщо таблиця вже існує в схемі-отримувачі, то записуємо це в лог
      IF v_is_exist_tab > 0 THEN      
        po_result := 'Таблиця ' || cc.table_name || ' вже існує в поданій схемі.';
        to_log(p_appl_proc => 'copy_table', p_message => po_result);
      --якщо таблиця вже існує в схемі-отримувачі - пропускаємо створення таблиці та переходимо до наступної
      CONTINUE;
      END IF;

      --створюємо таблицю, запускаючи динамічний SQL
      EXECUTE IMMEDIATE cc.ddl_code;

      --переносимо дані, якщо потрібно (p_copy_data = TRUE)
      IF p_copy_data THEN
        EXECUTE IMMEDIATE
             'INSERT INTO ' || p_target_scheme || '.' || cc.table_name || ' SELECT * FROM ' || p_source_scheme || '.' || cc.table_name;
        COMMIT;
        --ділимо повідомлення на два типи: в залежності від того копіювали таблицю з даними, чи без
        po_result := 'Таблицю ' || cc.table_name || ' скопійовано разом з даними';
      ELSE
        po_result := 'Таблицю ' || cc.table_name || ' скопійовано без даних';
      END IF;
      --записуємо в лог повідомлення про створення таблиць
      to_log(p_appl_proc => 'copy_table', p_message => po_result);

      --Виключення: при виникненні будь-якої помилки в циклі записуємо її в лог
      EXCEPTION
        WHEN OTHERS THEN
          po_result := 'Для таблиці ' || cc.table_name || ' виникла помилка: ' || SQLERRM;
          to_log(p_appl_proc => 'copy_table', p_message => po_result);

      --переходимо до наступної таблиці
      CONTINUE;
      END;

  END LOOP;

  --запис в лог про завершення копіювання таблиць
  po_result := 'Процес копіювання таблиць завершено';
  to_log(p_appl_proc => 'copy_table', p_message => po_result);

  --Виключення: при виникненні будь-якої помилки поза циклом записуємо її в лог
  EXCEPTION
    WHEN OTHERS THEN
        po_result := 'Виникла помилка: ' || SQLERRM;
        to_log(p_appl_proc => 'copy_table', p_message => po_result);
      --виводимо помилку на екран
      RAISE;

END copy_table;
/
