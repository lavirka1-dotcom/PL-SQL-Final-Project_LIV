--створення таблиці
CREATE TABLE sys_params (param_name VARCHAR2(150)
                        ,value_date DATE
                        ,value_text VARCHAR2(2000)
                        ,value_number NUMBER
                        ,param_descr VARCHAR2(200)
                        );

-----------------------------------------------------
--робимо одноразовий інсерт в таблицю
INSERT INTO sys_params
  (param_name
  ,value_date
  ,value_text
  ,value_number
  ,param_descr)
VALUES
  ('list_currencies'
   ,NULL
   ,'USD,EUR,KZT,AMD,GBP,ILS'
   ,NULL
   ,'Список валют для синхронації в процедурі util.арi_nbu_sync')
;

COMMIT;

