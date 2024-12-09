CREATE OR REPLACE TRIGGER trg_cs_id
BEFORE INSERT ON Condition_Specialisation
FOR EACH ROW
BEGIN
  :NEW.condition_specialisation_id := cs_seq.NEXTVAL;
END;
/
