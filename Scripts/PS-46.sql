
SELECT line, position, text FROM USER_ERRORS
WHERE name = 'DEL_EMPLOYEES_HISTORY_LOG' and type = 'TRIGGER'; 
--WHERE name = 'FIRE_AN_EMPLOYEE' and type = 'PROCEDURE'; 

--============================================================================
--перевірка роботи процедури fire_an_employee
BEGIN
util.fire_an_employee(214);
END;
/ 

--Співробітник Dilan, Black, FI_MGR, 30 видалено з таблиці.
--===========================================================

SELECT e.*--, e.rowid
FROM employees e
WHERE employee_id > 207
ORDER BY 1 desc
;

SELECT * FROM logs
ORDER BY 1 desc
; 

SELECT * FROM employees_history;
