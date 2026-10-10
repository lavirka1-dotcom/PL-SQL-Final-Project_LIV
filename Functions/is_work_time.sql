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
