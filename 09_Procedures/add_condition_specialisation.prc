CREATE OR REPLACE PROCEDURE add_condition_specialisation(
    p_doctor_id        IN NUMBER,
    p_condition_name   IN VARCHAR2,
    p_specialisation_name IN VARCHAR2
) IS
    v_doctor_exists NUMBER;
BEGIN
    -- Check if the doctor exists
    SELECT COUNT(*)
    INTO v_doctor_exists
    FROM Doctors
    WHERE doctor_id = p_doctor_id;

    IF v_doctor_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Doctor ID does not exist.');
    END IF;

    -- Insert the new condition-specialisation pair
    INSERT INTO Conditions_Specialisations (
        condition_specialisation_id, doctor_id, condition_name, specialisation_name
    )
    VALUES (
        cs_seq.NEXTVAL, p_doctor_id, p_condition_name, p_specialisation_name
    );

    DBMS_OUTPUT.PUT_LINE('Condition "' || p_condition_name || '" with specialisation "' || p_specialisation_name || 
                         '" added for Doctor ID ' || p_doctor_id || '.');
END Add_Condition_Specialisation;
/
