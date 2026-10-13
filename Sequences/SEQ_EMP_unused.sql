/*створення сиквенса "завернутий" в динамічний SQL
Сиквенс видалено: не використовуватиму, т.я. "збивається" нумерація при неуспішних спробах інсерту,
т.я. виклик NEXTVAL назавжди збільшує значення сиквенса, навіть якщо сталася помилка і спрацював ROLLBACK 
*/
DECLARE
  v_start_with NUMBER;
BEGIN

  SELECT MAX(employee_id) + 1
      INTO v_start_with
  FROM irina_vyx.employees;

  EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_EMP
                     MINVALUE 1 MAXVALUE 99999999999999999
                     START WITH ' || v_start_with ||
                    'INCREMENT BY 1
                     CACHE 20';
END;
/
