CREATE OR REPLACE TRIGGER update_patient_status
AFTER INSERT ON Treatments
FOR EACH ROW
DECLARE
    recent_treatments_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO recent_treatments_count
    FROM Treatments
    WHERE patient_id = :NEW.patient_id
      AND treatment_date >= SYSDATE - INTERVAL '1' YEAR;

    IF recent_treatments_count > 0 THEN
        UPDATE Patients
        SET patient_status = 'Active'
        WHERE patient_id = :NEW.patient_id;
        
    ELSE
        UPDATE Patients
        SET patient_status = 'Inactive'
        WHERE patient_id = :NEW.patient_id;
    END IF;
END;
/
