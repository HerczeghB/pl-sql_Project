CREATE OR REPLACE FUNCTION get_patient_current_condition(p_patient_id IN NUMBER)
  RETURN VARCHAR2 IS
  v_current_condition VARCHAR2(100);
BEGIN
  begin
    SELECT p.current_condition
    INTO v_current_condition
    FROM patients p
    WHERE p.patient_id = p_patient_id;
    
    --dbms_output.put_line('Patient ID: ' || p_patient_id || ' Current Condition: ' || v_current_condition);
    RETURN v_current_condition;
    
  exception
    when no_data_found then
      dbms_output.put_line('No patient found with ID: ' || p_patient_id);
      return 'No condition available!';
      
    when others then
      dbms_output.put_line('Error occured for patient ID: ' || p_patient_id);
      return 'Error retrieving condition';
  end;
END get_patient_current_condition;
/
