SELECT line, position, text FROM USER_ERRORS
WHERE name = 'API_NBU_SYNC' and type = 'PROCEDURE';
--=====================================================
SELECT * FROM sys_params;
-----------------------------
DECLARE
v_val VARCHAR2(4000);
BEGIN
v_val := get_needed_curr (); --(p_valcode => 'AMD')
dbms_output.put_line(v_val);
END;
/

SELECT * FROM TABLE(util.get_currency(p_currency => 'USD')); --'AMD'
--------------------------------

BEGIN
    util.api_nbu_sync;
    dbms_output.put_line('успішно');
END;
/ 
--------------------------------

SELECT * FROM cur_exchange
ORDER BY CHANGE_DATE DESC
;

SELECT * FROM logs
ORDER BY ID DESC;
 



