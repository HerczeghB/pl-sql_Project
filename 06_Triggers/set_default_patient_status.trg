CREATE OR REPLACE TRIGGER set_default_patient_status
BEFORE INSERT ON patients
FOR EACH ROW
BEGIN
  IF :NEW.patient_status IS NULL THEN
    :NEW.patient_status := 'Inactive';
  END IF;
END;
/
