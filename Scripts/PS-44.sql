DECLARE
    v_mes       VARCHAR2(1000);
    v_text      VARCHAR2(1000) := null; --'меседж';
    v_proc_name VARCHAR2(1000) := 'процес';

BEGIN
   IF v_text IS NULL THEN
         v_mes := 'Старт логування, назва процесу = ' || v_proc_name;
    ELSE v_mes := v_text;
    END IF;

    dbms_output.put_line(v_mes);
END;
/   
--------------------------------------------------
BEGIN 
irina_vyx.log_utils.log_start (p_proc_name => 'СТАРТ'
--                              ,p_text      => 'меседж'
                              );
END;
/
--------------------------------------------------
BEGIN 
irina_vyx.log_utils.log_finish (p_proc_name => 'ФІНІШ'
                               ,p_text      => 'меседж'
                               );
END;
/
--------------------------------------------------
BEGIN 
irina_vyx.log_utils.log_error (p_proc_name => 'ERR'
                              ,p_sqlerrm   => 'ERROR'
--                              ,p_text      => 'меседж'
                              );
END;
/
--------------------------------------------------

SELECT * FROM irina_vyx.logs ORDER BY 4 DESC; 
