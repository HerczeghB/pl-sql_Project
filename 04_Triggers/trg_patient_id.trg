CREATE OR REPLACE TRIGGER trg_patient_id
BEFORE INSERT ON Patient
FOR EACH ROW
BEGIN
  :NEW.patient_id := patient_seq.NEXTVAL;

  IF :NEW.patient_status IS NULL THEN
    :NEW.patient_status := 'Inactive';
  END IF;
END;
/
