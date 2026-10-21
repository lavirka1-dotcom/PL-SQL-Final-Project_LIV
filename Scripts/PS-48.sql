SELECT line, position, text FROM USER_ERRORS
WHERE name = 'COPY_TABLE' and type = 'PROCEDURE';
--==============================================================================
SELECT owner, table_name
FROM all_tables
WHERE owner = 'HR'
;

SELECT * FROM all_tab_columns;

SELECT *
FROM TABLE(irina_vyx.util.table_from_list('COUNTRIES,JOB_HISTORY,STUDENTS'))
;
--===============================================================================

SELECT table_name,
       'CREATE TABLE ' || table_name||' ('||LISTAGG(column_name ||' '|| data_type||count_symbol,', ')WITHIN GROUP(ORDER BY column_id)||')' AS ddl_code
FROM (SELECT table_name,
             column_name,
             data_type,
             CASE
               WHEN data_type = 'VARCHAR2' OR data_type = 'CHAR' THEN '('||data_length||')'
               WHEN data_type = 'DATE' THEN NULL
               WHEN data_type = 'NUMBER' THEN replace( '('||data_precision||','||data_scale||')', '(,)', NULL)
             END AS count_symbol,
             column_id
      FROM all_tab_columns
      WHERE owner = 'HR'
      AND table_name IN ('COUNTRIES','JOB_HISTORY')
      ORDER BY table_name, column_id)
GROUP BY table_name
;

--===============================================================================

SELECT * FROM logs
ORDER BY ID desc
;

SELECT * FROM IRINA_VYX.COUNTRIES;
SELECT * FROM IRINA_VYX.JOB_HISTORY;
------------------------------------------------------------------------- 
DECLARE
v_result VARCHAR2(1000);
BEGIN
copy_table(p_source_scheme => 'HR' -- 'bb@gg'
          ,p_target_scheme => 'IRINA_VYX' --'IRINA_VYXkk'
          ,p_list_table    => 'COUNTRIES,JOB_HISTORY,STUDENTS' --NULL
--          ,p_copy_data     => TRUE
          ,po_result => v_result);
--  dbms_output.put_line(v_result);
END;
/
