CREATE OR REPLACE FUNCTION get_patient_current_condition(p_patient_id IN NUMBER)
  RETURN VARCHAR2 IS
  v_current_condition VARCHAR2(100);
BEGIN
  BEGIN
    SELECT p.current_condition
      INTO v_current_condition
      FROM patient p
     WHERE p.patient_id = p_patient_id;
  
    --dbms_output.put_line('Patient ID: ' || p_patient_id || ' Current Condition: ' || v_current_condition);
    RETURN v_current_condition;
  
  EXCEPTION
    WHEN no_data_found THEN
      dbms_output.put_line('No patient found with ID: ' || p_patient_id);
      raise_application_error(-20001,'No patient found with ID: ' || p_patient_id);
    
    WHEN OTHERS THEN
      dbms_output.put_line('Error occured for patient ID: ' ||p_patient_id);
      raise_application_error(-20002, 'Error occurred for patient ID: ' || p_patient_id || ' - ' || SQLERRM);
  END;
END get_patient_current_condition;
/
