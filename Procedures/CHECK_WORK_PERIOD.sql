/*Як альтернативний варіант перевірки робочого часу, а в проекті для визначення робочого часу
використовуватиму функцію is_work_time
*/
CREATE OR REPLACE PROCEDURE CHECK_WORK_PERIOD IS

  BEGIN
        IF TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) in ('неділя', 'субота')
           or (TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) not in ('неділя', 'субота')
               and TRIM(TO_CHAR(SYSDATE,'hh24:mi')) not between '08:00' and '18:00') THEN

        raise_application_error(-20001, 'Ви можете додавати нового співробітника лише в робочий час');

      END IF;

  END;
/
