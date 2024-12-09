CREATE OR REPLACE TRIGGER trg_doctor_id
BEFORE INSERT ON Doctor
FOR EACH ROW
BEGIN
  :NEW.doctor_id := doctor_seq.NEXTVAL;
END;
/
