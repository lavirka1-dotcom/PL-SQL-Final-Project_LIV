--===================================================================================
--СПЕЦИФІКАЦІЯ ПАКЕТУ UTIL
--===================================================================================
CREATE OR REPLACE PACKAGE util AS
--===================================================================================

--процедура додавання нового співробітника в таблицю employees

	PROCEDURE add_employee (p_first_name     IN VARCHAR2
						   ,p_last_name      IN VARCHAR2
						   ,p_email          IN VARCHAR2
						   ,p_phone_number   IN VARCHAR2
						   ,p_hire_date      IN DATE DEFAULT trunc(sysdate, 'dd')
						   ,p_job_id         IN VARCHAR2
						   ,p_salary         IN NUMBER
						   ,p_commission_pct IN NUMBER DEFAULT NULL
						   ,p_manager_id     IN NUMBER DEFAULT 100
						   ,p_department_id  IN NUMBER);          

--===================================================================================
END util;

--===================================================================================
--===================================================================================
--===================================================================================
--ТІЛО ПАКЕТУ UTIL
--===================================================================================
CREATE OR REPLACE PACKAGE BODY util AS
--===================================================================================

--процедура додавання нового співробітника в таблицю employees

	PROCEDURE add_employee (p_first_name     IN VARCHAR2
						   ,p_last_name      IN VARCHAR2
						   ,p_email          IN VARCHAR2
						   ,p_phone_number   IN VARCHAR2
						   ,p_hire_date      IN DATE DEFAULT trunc(sysdate, 'dd')
						   ,p_job_id         IN VARCHAR2
						   ,p_salary         IN NUMBER
						   ,p_commission_pct IN NUMBER DEFAULT NULL
						   ,p_manager_id     IN NUMBER DEFAULT 100
						   ,p_department_id  IN NUMBER
						   ) IS 

		v_is_exist_job   NUMBER;
		v_is_exist_depid NUMBER;
		v_min_sal        irina_vyx.jobs.max_salary%TYPE;
		v_max_sal        irina_vyx.jobs.max_salary%TYPE;
		v_new_emplid     irina_vyx.employees.employee_id%TYPE;

	BEGIN
	--запускаємо процес логування початку роботи (запис в таблицю логів)
		irina_vyx.log_utils.log_start('add_employee');

	--перевірка на робочий час (вносити дані можна тільки з ПН по ПТ з 08:00 до 18:00)
		irina_vyx.CHECK_WORK_PERIOD();

	--перевірка існуючих JOB_ID
		SELECT COUNT(j.job_id)
			INTO v_is_exist_job
		FROM irina_vyx.jobs j
		WHERE j.job_id = p_job_id;

		IF v_is_exist_job < 1 THEN
		   raise_application_error(-20001, 'Введено неіснуючий код посади');
		END IF;

	--перевірка існуючих DEPARTMENT_ID
		SELECT COUNT(d.department_id)
			INTO v_is_exist_depid
		FROM irina_vyx.departments d
		WHERE d.department_id = p_department_id;

		IF v_is_exist_depid < 1 THEN
			  raise_application_error(-20001, 'Введено неіснуючий ідентифікатор відділу');
		END IF;

	--перевірка проміжку дозволених зарплат
		SELECT j.min_salary, j.max_salary
			INTO v_min_sal, v_max_sal
		FROM irina_vyx.jobs j
		WHERE j.job_id = p_job_id;

		IF p_salary < v_min_sal OR p_salary > v_max_sal THEN
			  raise_application_error(-20001, 'Введено неприпустиму заробітну плату для даного коду посади');
		END IF;

		  BEGIN
	/*створення наступного ідентифікатору EMPLOYEE_ID
	Сиквенс не використовуватиму, т.я. збивається нумерація при неуспішних спробах інсерту
	(виклик NEXTVAL назавжди збільшує значення сиквенса, навіть якщо сталася помилка і спрацював ROLLBACK)
	Не виносила в окрему функцію, т.я. створення employee_id планую використовувати тільки в даній процедурі*/
			SELECT NVL(MAX(e.employee_id), 0) + 1
				INTO v_new_emplid
			FROM irina_vyx.employees e;

	--почати процес вставки
		  <<insert_employee>>
			   INSERT INTO irina_vyx.employees (employee_id
											   ,first_name
											   ,last_name
											   ,email
											   ,phone_number
											   ,hire_date
											   ,job_id
											   ,salary
											   ,commission_pct
											   ,manager_id
											   ,department_id)
										VALUES (v_new_emplid
											   ,p_first_name
											   ,p_last_name
											   ,p_email
											   ,p_phone_number
											   ,p_hire_date
											   ,p_job_id
											   ,p_salary
											   ,p_commission_pct
											   ,p_manager_id
											   ,p_department_id);

				  COMMIT;

	--виводимо меседж при успішному додаванні співробітника
		  dbms_output.put_line('Співробітник ' || p_first_name ||', '|| p_last_name ||', '|| p_job_id ||', '|| p_department_id ||' успішно додано до системи.');

		  END insert_employee;

	--запускаємо процес логування кінця роботи (запис в таблицю логів)
	--виконається тільки при успішному інсерті
	  irina_vyx.log_utils.log_finish('add_employee');

	--виняток на випадок будь-якої помилки: записуємо в таблицю логів помилку
		  EXCEPTION
			  WHEN OTHERS THEN irina_vyx.log_utils.log_error('add_employee', SQLERRM);
	--виводимо помилку на екран
		  RAISE;

	END add_employee;

--===================================================================================
END util;