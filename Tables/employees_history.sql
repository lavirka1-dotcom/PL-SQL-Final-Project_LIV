--таблиця для запису історії видалених співробітників
CREATE TABLE employees_history (employee_id   NUMBER
                               ,first_name    VARCHAR2(20)
                               ,last_name     VARCHAR2(25)
                               ,job_id        VARCHAR2(10)
                               ,department_id NUMBER
                               ,hire_date     DATE
                               ,delete_date   DATE);


