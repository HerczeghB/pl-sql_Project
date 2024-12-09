CREATE OR REPLACE FUNCTION list_doctors_by_condition(p_condition_name IN VARCHAR2)
RETURN doctor_info_list IS
    v_doctors doctor_info_list := doctor_info_list();
BEGIN
    -- Loop through doctors for the given condition
    FOR doctor_rec IN (
        SELECT d.doctor_name, d.email, d.phone_number, cs.specialisation_name
        FROM Doctor d
        JOIN Condition_Specialisation cs ON d.doctor_id = cs.doctor_id
        WHERE cs.condition_name = p_condition_name
    ) LOOP
      v_doctors.extend;
      v_doctors(v_doctors.count) := doctor_info_type(doctor_rec.doctor_name, doctor_rec.email, doctor_rec.phone_number, doctor_rec.specialisation_name);   
    END LOOP;

    -- Check if any doctors were found
    IF v_doctors.count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No doctors found for the condition: ' || p_condition_name);
    END IF;

    RETURN v_doctors;
END list_doctors_by_condition;
/
