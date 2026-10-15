CREATE OR REPLACE PROCEDURE fire_an_employee_2 (p_employee_id IN NUMBER) IS

  v_first_name    irina_vyx.employees.first_name%TYPE;
  v_last_name     irina_vyx.employees.last_name%TYPE;
  v_job_id        irina_vyx.employees.job_id%TYPE;
  v_department_id irina_vyx.employees.department_id%TYPE;
  v_hire_date     irina_vyx.employees.hire_date%TYPE;

BEGIN
  --запускаємо процес логування початку роботи (запис в таблицю логів)
  irina_vyx.log_utils.log_start('fire_an_employee');

  --перевірка на робочий час (вносити дані можна тільки з ПН по ПТ з 08:00 до 18:00)
  irina_vyx.check_work_period();

  --записати ІМʼЯ, Прізвище, КОД ПОСАДИ, IД ДЕПАРТАМЕНТУ для видаляємого співробітника
  --вивести помилку, якщо переданого EMPLOYEE_ID не знайдено
  BEGIN
    SELECT e.first_name, e.last_name, e.job_id, e.department_id, e.hire_date
      INTO v_first_name, v_last_name, v_job_id, v_department_id, v_hire_date
      FROM irina_vyx.employees e
     WHERE e.employee_id = p_employee_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001, 'Переданий співробітник не існує');
  END;

  BEGIN 
  --записати історію по звільненим (видаленим) співробітникам в таблицю employees_history
    INSERT INTO employees_history
      (employee_id
      ,first_name
      ,last_name
      ,job_id
      ,department_id
      ,hire_date
      ,delete_date)
    VALUES
      (p_employee_id
      ,v_first_name
      ,v_last_name
      ,v_job_id
      ,v_department_id
      ,v_hire_date
      ,trunc(SYSDATE,'DD'));

  --почати процес видалення
  DELETE FROM irina_vyx.employees e
   WHERE e.employee_id = p_employee_id;

  COMMIT;

  END;

  --виводимо меседж при успішному видаленні співробітника
  dbms_output.put_line('Співробітник ' || v_first_name || ', ' || v_last_name || ', ' || v_job_id || ', ' || v_department_id || ' видалено з таблиці.');

  --запускаємо процес логування кінця роботи (запис в таблицю логів)
  --виконається тільки при успішному деліті
  irina_vyx.log_utils.log_finish('fire_an_employee');

  --виняток на випадок будь-якої помилки: записуємо в таблицю логів помилку
EXCEPTION
  WHEN OTHERS THEN
    irina_vyx.log_utils.log_error('fire_an_employee', SQLERRM);
    --виводимо помилку на екран
    RAISE;

END fire_an_employee_2;
