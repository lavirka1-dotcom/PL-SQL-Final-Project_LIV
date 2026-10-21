--===================================================================================
--СПЕЦИФІКАЦІЯ ПАКЕТУ UTIL
--===================================================================================
CREATE OR REPLACE PACKAGE util AS
--===================================================================================
--процедура заміни атрибутів співробітника в таблиці employees
PROCEDURE change_attribute_employee(p_employee_id    IN NUMBER
                                   ,p_first_name     IN VARCHAR2 DEFAULT NULL
                                   ,p_last_name      IN VARCHAR2 DEFAULT NULL
                                   ,p_email          IN VARCHAR2 DEFAULT NULL
                                   ,p_phone_number   IN VARCHAR2 DEFAULT NULL
                                   ,p_job_id         IN VARCHAR2 DEFAULT NULL
                                   ,p_salary         IN NUMBER   DEFAULT NULL
                                   ,p_commission_pct IN NUMBER   DEFAULT NULL
                                   ,p_manager_id     IN NUMBER   DEFAULT NULL
                                   ,p_department_id  IN NUMBER   DEFAULT NULL);
                                   
--===================================================================================
END util;

--===================================================================================
--===================================================================================
--===================================================================================
--ТІЛО ПАКЕТУ UTIL
--===================================================================================
CREATE OR REPLACE PACKAGE BODY util AS
--===================================================================================
--процедура заміни атрибутів співробітника в таблиці employees
PROCEDURE change_attribute_employee(p_employee_id    IN NUMBER
                                   ,p_first_name     IN VARCHAR2 DEFAULT NULL
                                   ,p_last_name      IN VARCHAR2 DEFAULT NULL
                                   ,p_email          IN VARCHAR2 DEFAULT NULL
                                   ,p_phone_number   IN VARCHAR2 DEFAULT NULL
                                   ,p_job_id         IN VARCHAR2 DEFAULT NULL
                                   ,p_salary         IN NUMBER   DEFAULT NULL
                                   ,p_commission_pct IN NUMBER   DEFAULT NULL
                                   ,p_manager_id     IN NUMBER   DEFAULT NULL
                                   ,p_department_id  IN NUMBER   DEFAULT NULL) IS

  v_sql    VARCHAR2(4000);
  v_emplid irina_vyx.employees.employee_id%TYPE;

BEGIN
  --запускаємо процес логування початку роботи (запис в таблицю логів)
  irina_vyx.log_utils.log_start('change_attribute_employee');

  --перевірка на робочий час (вносити дані можна тільки з ПН по ПТ з 08:00 до 18:00)
  irina_vyx.check_work_period();

  --перевірка існуючих EMPLOYEE_ID
  SELECT COUNT(e.employee_id)
    INTO v_emplid
    FROM irina_vyx.employees e
   WHERE e.employee_id = p_employee_id;

  IF v_emplid < 1 THEN
    raise_application_error(-20001
                           ,'Переданий співробітник нe існує');
  END IF;

  --перевірка, чи є якісь параметри для оновлення
  IF     p_first_name     IS NULL
     AND p_last_name      IS NULL
     AND p_email          IS NULL
     AND p_phone_number   IS NULL
     AND p_job_id         IS NULL
     AND p_salary         IS NULL
     AND p_commission_pct IS NULL
     AND p_manager_id     IS NULL
     AND p_department_id  IS NULL THEN
    raise_application_error(-20001
                           ,'Не передано жодного атрибуту для оновлення');
  END IF;

  --формування динамічного SQL для оновлення атрибутів
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
  v_sql := rtrim(v_sql, ', ');

  --додати умову WHERE
  v_sql := v_sql || ' WHERE employee_id = ' || p_employee_id;

  --оновлюємо атрибути
  BEGIN
    <<update_attributes>>
    EXECUTE IMMEDIATE v_sql;
  
    COMMIT;
  
    --виводимо меседж при успішному оновленні атрибутів
    dbms_output.put_line('У співробітника ' || p_employee_id || ' успішно оновлені атрибути');
  
    --виняток на випадок будь-якої помилки на етапі оновлення: записуємо в таблицю логів помилку
  EXCEPTION
    WHEN OTHERS THEN
      irina_vyx.log_utils.log_error('change_attribute_employee'
                                   ,SQLERRM);
      --виводимо помилку на екран
      RAISE;
    
  END update_attributes;

  --запускаємо процес логування кінця роботи (запис в таблицю логів)
  --виконається тільки при успішній зміні атрибутів
  irina_vyx.log_utils.log_finish('change_attribute_employee');

  --виняток на випадок будь-якої іншої помилки: записуємо в таблицю логів помилку
EXCEPTION
  WHEN OTHERS THEN
    irina_vyx.log_utils.log_error('change_attribute_employee'
                                 ,SQLERRM);
    --виводимо помилку на екран
    RAISE;
  
END change_attribute_employee;

--===================================================================================
END util;
