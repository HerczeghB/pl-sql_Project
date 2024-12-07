CREATE OR REPLACE FUNCTION list_doctors_by_condition(p_condition_name IN VARCHAR2)
RETURN VARCHAR2 IS
    v_result VARCHAR2(4000) := '';
BEGIN
    -- Loop through doctors for the given condition
    FOR doctor_rec IN (
        SELECT d.doctor_name, d.email, d.phone_number, cs.specialisation_name
        FROM Doctors d
        JOIN Conditions_Specialisations cs ON d.doctor_id = cs.doctor_id
        WHERE cs.condition_name = p_condition_name
    ) LOOP
        v_result := v_result || 'Doctor Name: ' || doctor_rec.doctor_name || 
                     ', Email: ' || doctor_rec.email || 
                     ', Phone: ' || doctor_rec.phone_number || 
                     ', Specialisation: ' || doctor_rec.specialisation_name || CHR(10);
    END LOOP;

    -- Check if any doctors were found
    IF LENGTH(v_result) = 0 THEN
        v_result := 'No doctors found for the condition: ' || p_condition_name;
    END IF;

    RETURN v_result;
END list_doctors_by_condition;
/
