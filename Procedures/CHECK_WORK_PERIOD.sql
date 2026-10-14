--процедура для перевірки робочого часу

CREATE OR REPLACE PROCEDURE check_work_period IS

  BEGIN
        IF TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) in ('неділя', 'субота')
           or (TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) not in ('неділя', 'субота')
               and TRIM(TO_CHAR(SYSDATE,'hh24:mi')) not between '08:00' and '18:00') THEN

--        raise_application_error(-20001, 'Ви можете додавати нового співробітника лише в робочий час');
        raise_application_error(-20001, 'Ви можете вносити зміни в таблицю лише в робочий час');
      END IF;

  END;
