CREATE OR REPLACE PROCEDURE add_new_doctor(p_doctor_name         IN VARCHAR2
                                          ,p_phone_number        IN VARCHAR2
                                          ,p_email               IN VARCHAR2
                                          ,p_working_hours       IN VARCHAR2
                                          ,p_condition_name      IN VARCHAR2
                                          ,p_specialisation_name IN VARCHAR2) IS
  v_new_doctor_id NUMBER := doctor_seq.nextval;
  v_new_cs_id     NUMBER := cs_seq.nextval;
BEGIN

  INSERT INTO doctors
    (doctor_id
    ,doctor_name
    ,phone_number
    ,email
    ,working_hours)
  VALUES
    (v_new_doctor_id
    ,p_doctor_name
    ,p_phone_number
    ,p_email
    ,p_working_hours);

  INSERT INTO conditions_specialisations
    (condition_specialisation_id
    ,condition_name
    ,specialisation_name
    ,doctor_id)
  VALUES
    (v_new_cs_id
    ,p_condition_name
    ,p_specialisation_name
    ,v_new_doctor_id);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END add_new_doctor;
/
