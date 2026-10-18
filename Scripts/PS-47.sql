SELECT line, position, text FROM USER_ERRORS
WHERE name = 'CHANGE_ATTRIBUTE_EMPLOYEE' and type = 'PROCEDURE'; 
--=========================================================================
SELECT e.*--, e.rowid
FROM employees e
WHERE employee_id > 207
ORDER BY 1 desc
;
--=========================================================================
BEGIN
util.change_attribute_employee (p_employee_id    => 214   
--                               ,p_first_name     => 'Dillan'
                               ,p_last_name      => 'Smith'
                               ,p_email          => 'DSmith'
--                               ,p_phone_number   => '310.782.6716'
                               ,p_job_id         => 'IT_PROG'
                               ,p_salary         => 12000
--                               ,p_commission_pct => 0.3
                               ,p_manager_id     => 102
                               ,p_department_id  => 60
                               );
END;
/
--У співробітника 214 успішно оновлені атрибути

SELECT * FROM logs
ORDER BY 1 desc;

--==========================================================
UPDATE irina_vyx.employees
   SET department_id = 80
 WHERE employee_id = 214;
---------------------------------------
DECLARE
  v_sql VARCHAR2(4000);

  p_employee_id    irina_vyx.employees.employee_id%TYPE := 214;
  p_first_name     irina_vyx.employees.first_name%TYPE := NULL;
  p_last_name      irina_vyx.employees.last_name%TYPE := 'Smith';
  p_email          irina_vyx.employees.email%TYPE := 'DSmith';
  p_phone_number   irina_vyx.employees.phone_number%TYPE := NULL;
  p_job_id         irina_vyx.employees.job_id%TYPE := 'IT_PROG';
  p_salary         irina_vyx.employees.salary%TYPE := NULL;
  p_commission_pct irina_vyx.employees.commission_pct%TYPE := NULL;
  p_manager_id     irina_vyx.employees.manager_id%TYPE := 102;
  p_department_id  irina_vyx.employees.department_id%TYPE := 60;

BEGIN

  v_sql := 'UPDATE irina_vyx.employees SET ';

  --перебрати параметри і додати в умову, якщо не null
  IF p_first_name IS NOT NULL THEN
    v_sql := v_sql || 'first_name = ''' || p_first_name || ''', ';
  END IF;

  IF p_last_name IS NOT NULL THEN
    v_sql := v_sql || 'last_name = ''' || p_last_name || ''', ';
  END IF;

  IF p_email IS NOT NULL THEN
    v_sql := v_sql || 'email = ''' || p_email || ''', ';
  END IF;

  IF p_phone_number IS NOT NULL THEN
    v_sql := v_sql || 'phone_number = ''' || p_phone_number || ''', ';
  END IF;

  IF p_job_id IS NOT NULL THEN
    v_sql := v_sql || 'job_id = ''' || p_job_id || ''', ';
  END IF;

  IF p_salary IS NOT NULL THEN
    v_sql := v_sql || 'salary = ' || p_salary || ', ';
  END IF;

  IF p_commission_pct IS NOT NULL THEN
    v_sql := v_sql || 'commission_pct = ' || p_commission_pct || ', ';
  END IF;

  IF p_manager_id IS NOT NULL THEN
    v_sql := v_sql || 'manager_id = ' || p_manager_id || ', ';
  END IF;

  IF p_department_id IS NOT NULL THEN
    v_sql := v_sql || 'department_id = ' || p_department_id || ', ';
  END IF;

  --прибрати останню кому та пробіл
  v_sql := rtrim(v_sql
                ,', ');

  --додати умову WHERE
  v_sql := v_sql || ' WHERE employee_id = ' || p_employee_id;

  dbms_output.put_line(v_sql);

END;
/
