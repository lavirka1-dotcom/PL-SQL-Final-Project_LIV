CREATE OR REPLACE TRIGGER del_employees_history_log
  AFTER DELETE ON employees
  FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  INSERT INTO employees_history 
    (employee_id
    ,first_name
    ,last_name
    ,job_id
    ,department_id
    ,hire_date
    ,delete_date) 
  VALUES      
    (:old.employee_id
    ,:old.first_name
    ,:old.last_name
    ,:old.job_id
    ,:old.department_id
    ,:old.hire_date
    ,trunc(SYSDATE,'DD'));

  COMMIT;
  
END del_employees_history_log;
