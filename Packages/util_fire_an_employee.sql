--===================================================================================
--СПЕЦИФІКАЦІЯ ПАКЕТУ UTIL
--===================================================================================
CREATE OR REPLACE PACKAGE util AS
--===================================================================================

--процедура звільнення (видалення) співробітника з таблиці employees
PROCEDURE fire_an_employee(p_employee_id IN NUMBER);

--===================================================================================
END util;

--===================================================================================
--===================================================================================
--===================================================================================
--ТІЛО ПАКЕТУ UTIL
--===================================================================================
CREATE OR REPLACE PACKAGE BODY util AS
--===================================================================================

--процедура звільнення (видалення) співробітника з таблиці employees
PROCEDURE fire_an_employee(p_employee_id IN NUMBER) IS

  v_emplid        NUMBER;
  v_first_name    irina_vyx.employees.first_name%TYPE;
  v_last_name     irina_vyx.employees.last_name%TYPE;
  v_job_id        irina_vyx.employees.job_id%TYPE;
  v_department_id irina_vyx.employees.department_id%TYPE;

BEGIN
  --запускаємо процес логування початку роботи (запис в таблицю логів)
  irina_vyx.log_utils.log_start('fire_an_employee');

  --перевірка на робочий час (вносити дані можна тільки з ПН по ПТ з 08:00 до 18:00)
  irina_vyx.check_work_period();

  --перевірка існуючих EMPLOYEE_ID
  SELECT COUNT(e.employee_id)
    INTO v_emplid
    FROM irina_vyx.employees e
   WHERE e.employee_id = p_employee_id;

  IF v_emplid < 1 THEN
    raise_application_error(-20001,'Переданий співробітник нe існує');
  END IF;

  --записати ІМʼЯ, Прізвище, КОД ПОСАДИ, IД ДЕПАРТАМЕНТУ для видаляємого співробітника
  SELECT e.first_name
        ,e.last_name
        ,e.job_id
        ,e.department_id
    INTO v_first_name
        ,v_last_name
        ,v_job_id
        ,v_department_id
    FROM irina_vyx.employees e
   WHERE e.employee_id = p_employee_id;

  --запустити процес видалення
  DELETE FROM irina_vyx.employees e
   WHERE e.employee_id = p_employee_id;

  COMMIT;

  --виводимо меседж при успішному видаленні співробітника
  dbms_output.put_line('Співробітник ' || v_first_name || ', ' || v_last_name || ', ' || v_job_id || ', ' || v_department_id || ' видалено з таблиці.');

  --запускаємо процес логування кінця роботи (запис в таблицю логів)
  --виконається тільки при успішному деліті
  irina_vyx.log_utils.log_finish('fire_an_employee');

  --виняток на випадок будь-якої помилки: записуємо в таблицю логів помилку
EXCEPTION
  WHEN OTHERS THEN
    irina_vyx.log_utils.log_error('fire_an_employee',SQLERRM);
    --виводимо помилку на екран
    RAISE;
  
END fire_an_employee;

--===================================================================================
END util;