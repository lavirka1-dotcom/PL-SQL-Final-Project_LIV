SELECT TRIM(TO_CHAR(SYSDATE,'hh24:mi')) FROM DUAL;

SELECT TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) FROM DUAL;

--перевірка умови створення переіоду робочого часу для процедури CHECK_WORK_PERIOD
BEGIN
    IF TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) IN ('субота', 'понеділок')
        OR (TRIM(TO_CHAR(SYSDATE,'day', 'NLS_DATE_LANGUAGE = UKRAINIAN')) NOT IN ('субота', 'понеділок')
       AND TRIM(TO_CHAR(SYSDATE,'hh24:mi')) NOT BETWEEN '20:00' AND '22:00') THEN

    raise_application_error(-20001, 'Ви можете додавати нового співробітника лише в робочий час');
    
    ELSE dbms_output.put_line(SYSDATE);

    END IF;
END;
/

--перевірка функції робочого часу is_work_time
DECLARE
    v_res BOOLEAN;
BEGIN
    v_res := is_work_time();    
    
    IF v_res THEN
       dbms_output.put_line ('робочий час');
    ELSE
      dbms_output.put_line ('НЕ робочий час');
    END IF;
END;

--====================================================================================================

SELECT * FROM jobs;

SELECT distinct (department_id)
FROM departments
ORDER BY 1
;

SELECT employee_id
      ,first_name
      ,last_name
      ,email
      ,phone_number
      ,hire_date
      ,job_id
      ,salary
      ,commission_pct
      ,manager_id
      ,department_id
  FROM irina_vyx.employees
;

SELECT NVL(MAX(employee_id), 0) + 1
FROM irina_vyx.employees
;
--============================================================================
--пошук помилок
SELECT line, position, text FROM USER_ERRORS
WHERE name = 'ADD_EMPLOYEE' and type = 'PROCEDURE'; 

--============================================================================
--перевірка роботи процедури add_employee
BEGIN
util.add_employee (p_first_name     => 'Dilan' -- 'Dilan Black 310.782.6715'
                  ,p_last_name      => 'Black'
                  ,p_email          => 'DBLACK'
                  ,p_phone_number   => '310.782.6715'
--                  ,p_hire_date      => --DEFAULT trunc(sysdate, 'dd')
                  ,p_job_id         => 'FI_MGR' --'IT_PROG'
                  ,p_salary         => 11000 --100000
--                  ,p_commission_pct => 0.20 --DEFAULT NULL
--                  ,p_manager_id     => 101 --DEFAULT 100
                  ,p_department_id  => 30
                  );
END;
/ 
--Співробітник ІМʼЯ, Прізвище, КОД ПОСАДИ, IД ДЕПАРТАМЕНТУ успішно додано до системи. 
--Співробітник Dilan, Black, FI_MGR, 30 успішно додано до системи.

SELECT e.*--, e.rowid
FROM employees e
--WHERE e.job_id in ('PU_MAN')
--and e.commission_pct is not null 
WHERE employee_id > 207
ORDER BY 1 desc
;

SELECT * FROM logs
ORDER BY 1 desc
; 

