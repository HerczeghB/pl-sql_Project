CREATE OR REPLACE PACKAGE Appointment_Manager IS

    FUNCTION day_to_number(p_day in VARCHAR2) RETURN NUMBER;
    
    FUNCTION check_working_day(p_day_of_week in NUMBER, p_working_day in VARCHAR2) RETURN BOOLEAN;

    PROCEDURE schedule_appointment(p_patient_id in NUMBER, p_date in DATE);

END Appointment_Manager;
/
CREATE OR REPLACE PACKAGE BODY Appointment_Manager IS

    -- convert day name to number
    FUNCTION day_to_number(p_day in VARCHAR2) RETURN NUMBER IS
    BEGIN
        CASE upper(p_day)
            WHEN 'MONDAY' THEN RETURN 1;
            WHEN 'TUESDAY' THEN RETURN 2;
            WHEN 'WEDNESDAY' THEN RETURN 3;
            WHEN 'THURSDAY' THEN RETURN 4;
            WHEN 'FRIDAY' THEN RETURN 5;
            WHEN 'SATURDAY' THEN RETURN 6;
            WHEN 'SUNDAY' THEN RETURN 7;
            ELSE
                RETURN NULL;
        END CASE;
    END day_to_number;

    --check if the day is within the working range
    FUNCTION check_working_day(p_day_of_week in NUMBER, p_working_day in VARCHAR2) RETURN BOOLEAN IS
        v_start_day VARCHAR2(10);
        v_end_day VARCHAR2(10);
        v_start_day_num NUMBER;
        v_end_day_num NUMBER;
    BEGIN
        v_start_day := TRIM(SUBSTR(p_working_day, 1, INSTR(p_working_day, '-') - 1));
        v_end_day := TRIM(SUBSTR(p_working_day, INSTR(p_working_day, '-') + 1));

        v_start_day_num := day_to_number(v_start_day);
        v_end_day_num := day_to_number(v_end_day);

        IF (v_start_day_num <= p_day_of_week AND v_end_day_num >= p_day_of_week) OR
           (v_start_day_num > v_end_day_num AND (p_day_of_week >= v_start_day_num OR p_day_of_week <= v_end_day_num)) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END check_working_day;

    --schedule the appointment
    PROCEDURE schedule_appointment(p_patient_id in NUMBER, p_date in DATE) IS
        v_current_condition VARCHAR2(100);
        v_doctor_id NUMBER;
        v_working_day VARCHAR2(30);
        v_working_hours VARCHAR2(20);
        v_day_of_week NUMBER;
        v_appointment_exists NUMBER;

        v_start_time TIMESTAMP;
        v_end_time TIMESTAMP;
        v_input_time TIMESTAMP;
        v_input_minutes NUMBER;

    BEGIN
        v_input_minutes := TO_NUMBER(TO_CHAR(p_date, 'MI'));
        IF v_input_minutes NOT IN (0, 15, 30, 45) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid time. Minutes must be 00, 15, 30, or 45.');
        END IF;

        SELECT current_condition 
        INTO v_current_condition
        FROM Patients
        WHERE patient_id = p_patient_id;

        FOR doctor_rec IN (
            SELECT doctor_id, condition_name
            FROM Conditions_Specialisations
            WHERE condition_name = v_current_condition
        ) LOOP

            SELECT working_day, working_hours
            INTO v_working_day, v_working_hours
            FROM Doctors
            WHERE doctor_id = doctor_rec.doctor_id;


            v_day_of_week := day_to_number(TRIM(TO_CHAR(p_date, 'DAY', 'NLS_DATE_LANGUAGE= ''ENGLISH''')));

            IF check_working_day(v_day_of_week, v_working_day) THEN

                v_start_time := TO_TIMESTAMP(TO_CHAR(p_date, 'YYYY-MM-DD') || ' ' || SUBSTR(v_working_hours, 1, 5), 'YYYY-MM-DD HH24:MI');
                v_end_time := TO_TIMESTAMP(TO_CHAR(p_date, 'YYYY-MM-DD') || ' ' || SUBSTR(v_working_hours, INSTR(v_working_hours, '-') + 1), 'YYYY-MM-DD HH24:MI');

                v_input_time := TO_TIMESTAMP(TO_CHAR(p_date, 'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI');
                IF v_input_time >= v_start_time AND v_input_time + INTERVAL '15' MINUTE <= v_end_time THEN

                    SELECT COUNT(*) INTO v_appointment_exists
                    FROM Appointments
                    WHERE doctor_id = doctor_rec.doctor_id
                    AND (appointment_start <= v_input_time AND appointment_end > v_input_time OR
                         appointment_start < v_input_time + INTERVAL '15' MINUTE AND appointment_end >= v_input_time + INTERVAL '15' MINUTE);

                    IF v_appointment_exists = 0 THEN

                        INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_start, appointment_end, appointment_status)
                        VALUES (Appointment_seq.NEXTVAL, p_patient_id, doctor_rec.doctor_id, v_input_time, v_input_time + INTERVAL '15' MINUTE, 'Scheduled');
                        
                        DBMS_OUTPUT.PUT_LINE('Appointment scheduled with doctor ' || doctor_rec.doctor_id || 
                                             ' from ' || TO_CHAR(v_input_time, 'HH24:MI') || 
                                             ' to ' || TO_CHAR(v_input_time + INTERVAL '15' MINUTE, 'HH24:MI'));
                        RETURN;
                    END IF;
                END IF;
            END IF;
        END LOOP;

        RAISE_APPLICATION_ERROR(-20002, 'No available doctor found for the given condition, date, and time.');
    END schedule_appointment;

END Appointment_Manager;
/
