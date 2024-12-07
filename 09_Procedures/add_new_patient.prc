CREATE OR REPLACE PROCEDURE add_new_patient(p_patient_name      IN VARCHAR2
                                           ,p_age               IN NUMBER
                                           ,p_gender            IN VARCHAR2
                                           ,p_phone_number      IN VARCHAR2
                                           ,p_email             IN VARCHAR2
                                           ,p_medical_history   IN CLOB
                                           ,p_current_condition IN VARCHAR2) IS
v_new_patient_id number := patient_seq.nextval;                                           
BEGIN
  --Validate email
  IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid email format.');
  END IF;
  --Validate phone number
  IF NOT REGEXP_LIKE(p_phone_number, '^\+?[0-9]{7,20}$') THEN
    RAISE_APPLICATION_ERROR(-20003, 'Invalid phone number format.');
  END IF;
  
  INSERT INTO patients
    (patient_id
    ,patient_name
    ,age
    ,gender
    ,phone_number
    ,email
    ,medical_history
    ,current_condition)
  VALUES
    (v_new_patient_id
    ,p_patient_name
    ,p_age
    ,p_gender
    ,p_phone_number
    ,p_email
    ,p_medical_history
    ,p_current_condition);

  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Patient successfully added with ID: ' || v_new_patient_id);
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END add_new_patient;
/
