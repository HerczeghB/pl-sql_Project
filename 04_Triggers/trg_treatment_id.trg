CREATE OR REPLACE TRIGGER trg_treatment_id
BEFORE INSERT ON Treatment
FOR EACH ROW
BEGIN
  :NEW.treatment_id := treatment_seq.NEXTVAL;
END;
/
