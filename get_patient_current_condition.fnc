CREATE OR REPLACE FUNCTION get_patient_current_condition(p_patient_id IN NUMBER)
  RETURN VARCHAR2 IS
  v_current_condition VARCHAR2(100);
BEGIN
  SELECT p.current_condition
    INTO v_current_condition
    FROM patients p
   WHERE p.patient_id = p_patient_id;
  RETURN v_current_condition;
END get_patient_current_condition;
/
