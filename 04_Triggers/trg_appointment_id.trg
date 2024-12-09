CREATE OR REPLACE TRIGGER trg_appointment_id
BEFORE INSERT ON Appointment
FOR EACH ROW
BEGIN
  :NEW.appointment_id := appointment_seq.NEXTVAL;
END;
/
