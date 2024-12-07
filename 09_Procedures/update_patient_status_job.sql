BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'update_patient_status_job',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN update_patient_status; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1',
        enabled         => TRUE
    );
END;
