BEGIN
  sys.dbms_scheduler.create_job (job_name        => 'job_api_nbu_sync'
                                ,job_type        => 'PLSQL_BLOCK'
                                ,job_action      => 'begin api_nbu_sync(); end;'
                                ,start_date      => SYSDATE
                                ,repeat_interval => 'FREQ=DAILY; BYHOUR=6; BYMINUTE=0; BYSECOND=0'
                                ,end_date        => to_date(NULL)
                                ,job_class       => 'DEFAULT_JOB_CLASS'
                                ,enabled         => TRUE
                                ,auto_drop       => FALSE
                                ,comments        => 'Синхронізація даних курсів валют з НБУ у базу даних в таблицю cur_exchange щодня о 6 ранку'
                                );
END;
/
