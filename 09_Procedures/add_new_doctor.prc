CREATE OR REPLACE PROCEDURE add_new_doctor(p_doctor_name         IN VARCHAR2
                                          ,p_phone_number        IN VARCHAR2
                                          ,p_email               IN VARCHAR2
                                          ,p_working_day         IN VARCHAR2
                                          ,p_working_hours       IN VARCHAR2
                                          ,p_condition_name      IN VARCHAR2
                                          ,p_specialisation_name IN VARCHAR2) IS
BEGIN
  --Validate email
  IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid email format.');
  END IF;
  
  --Validate phone number
  IF NOT REGEXP_LIKE(p_phone_number, '^\+?[0-9]{7,20}$') THEN
    RAISE_APPLICATION_ERROR(-20003, 'Invalid phone number format.');
  END IF;
  
  -- Validate working_day format (single day or day range)
  IF NOT REGEXP_LIKE(p_working_day, '^(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)(-(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday))?$') THEN
    RAISE_APPLICATION_ERROR(-20004, 'Invalid working day format. It must be a single day (e.g., "Monday") or a day range (e.g., "Monday-Wednesday").');
  END IF;

  -- Validate working_hours format (HH:mm-HH:mm)
  IF NOT REGEXP_LIKE(p_working_hours, '^(0[8-9]|1[0-9]):[0-5][0-9]-(0[8-9]|1[0-9]):[0-5][0-9]$') THEN
    RAISE_APPLICATION_ERROR(-20005, 'Invalid working hours format. It must be in the format "HH:mm-HH:mm", e.g., "08:00-15:00".');
  END IF;

  INSERT INTO doctors
    (doctor_id
    ,doctor_name
    ,phone_number
    ,email
    ,working_day
    ,working_hours)
  VALUES
    (doctor_seq.nextval
    ,p_doctor_name
    ,p_phone_number
    ,p_email
    ,p_working_day
    ,p_working_hours);

  INSERT INTO conditions_specialisations
    (condition_specialisation_id
    ,condition_name
    ,specialisation_name
    ,doctor_id)
  VALUES
    (cs_seq.nextval
    ,p_condition_name
    ,p_specialisation_name
    ,doctor_seq.currval);
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Doctor successfully added!');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END add_new_doctor;
/
