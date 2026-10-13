--функція для перевірки робочого часу - як альтернатива, не використовується
CREATE OR REPLACE FUNCTION is_work_time RETURN BOOLEAN IS

    v_day  VARCHAR2(20);
    v_hour VARCHAR2(20);

BEGIN  
    v_day  := TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN'));
    v_hour := TRIM(TO_CHAR(SYSDATE,'hh24:mi'));
    
    IF v_day in ('неділя', 'субота') or v_hour not between '08:00' and '18:00' THEN
       RETURN FALSE;
    ELSE
       RETURN TRUE;
    END IF;
    
END is_work_time;
/

--====================================================================================
--перевірка на робочий час: використання
    IF NOT is_work_time() THEN
        raise_application_error(-20001, 'Ви можете додавати нового співробітника лише в робочий час');
    END IF;