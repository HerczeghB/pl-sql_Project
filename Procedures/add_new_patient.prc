CREATE OR REPLACE PROCEDURE add_new_patient(p_patient_name      IN VARCHAR2
                                           ,p_age               IN NUMBER
                                           ,p_gender            IN VARCHAR2
                                           ,p_phone_number      IN VARCHAR2
                                           ,p_email             IN VARCHAR2
                                           ,p_medical_history   IN CLOB
                                           ,p_patient_status    IN VARCHAR2
                                           ,p_current_condition IN VARCHAR2) IS
v_new_patient_id number := patient_seq.nextval;                                           
BEGIN
 
  INSERT INTO patients
    (patient_id
    ,patient_name
    ,age
    ,gender
    ,phone_number
    ,email
    ,medical_history
    ,patient_status
    ,current_condition)
  VALUES
    (v_new_patient_id
    ,p_patient_name
    ,p_age
    ,p_gender
    ,p_phone_number
    ,p_email
    ,p_medical_history
    ,p_patient_status
    ,p_current_condition);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END add_new_patient;
/
