CREATE OR REPLACE PROCEDURE update_patient_status AS
BEGIN
    -- Update patients to Active if they have recent treatments
    UPDATE Patients
    SET patient_status = 'Active'
    WHERE patient_id IN (
        SELECT DISTINCT patient_id
        FROM Treatments
        WHERE treatment_date >= SYSDATE - INTERVAL '1' YEAR
    );

    -- Update patients to Inactive if they have no treatments or all treatments are older than 1 year
    UPDATE Patients
    SET patient_status = 'Inactive'
    WHERE patient_id NOT IN (
        SELECT DISTINCT patient_id
        FROM Treatments
        WHERE treatment_date >= SYSDATE - INTERVAL '1' YEAR
    ) 
    OR patient_id NOT IN (SELECT DISTINCT patient_id FROM Treatments);
END;
/
