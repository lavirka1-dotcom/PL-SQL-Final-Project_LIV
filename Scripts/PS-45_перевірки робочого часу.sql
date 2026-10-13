SELECT TRIM(TO_CHAR(SYSDATE,'hh24:mi')) FROM DUAL;

SELECT TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) FROM DUAL;

--перевірка умови створення переіоду робочого часу для процедури CHECK_WORK_PERIOD
BEGIN
    IF TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) IN ('субота', 'понеділок')
        OR (TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) NOT IN ('субота', 'понеділок')
       AND TRIM(TO_CHAR(SYSDATE,'hh24:mi')) NOT BETWEEN '20:00' AND '22:00') THEN

    raise_application_error(-20001, 'Ви можете додавати нового співробітника лише в робочий час');
    
    ELSE dbms_output.put_line(SYSDATE);

    END IF;
END;
/

--перевірка функції робочого часу is_work_time
DECLARE
    v_res BOOLEAN;
BEGIN
    v_res := is_work_time();    
    
    IF v_res THEN
       dbms_output.put_line ('робочий час');
    ELSE
      dbms_output.put_line ('НЕ робочий час');
    END IF;
END;


