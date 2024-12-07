CREATE OR REPLACE PACKAGE appointment_manager IS

  FUNCTION day_to_number(p_day IN VARCHAR2) RETURN NUMBER;

  FUNCTION check_working_day(p_day_of_week IN NUMBER
                            ,p_working_day IN VARCHAR2) RETURN BOOLEAN;

  PROCEDURE schedule_appointment(p_patient_id IN NUMBER
                                ,p_date       IN DATE);

END appointment_manager;
/
CREATE OR REPLACE PACKAGE BODY appointment_manager IS

  -- convert day name to number
  FUNCTION day_to_number(p_day IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    CASE upper(p_day)
      WHEN 'MONDAY' THEN
        RETURN 1;
      WHEN 'TUESDAY' THEN
        RETURN 2;
      WHEN 'WEDNESDAY' THEN
        RETURN 3;
      WHEN 'THURSDAY' THEN
        RETURN 4;
      WHEN 'FRIDAY' THEN
        RETURN 5;
      WHEN 'SATURDAY' THEN
        RETURN 6;
      WHEN 'SUNDAY' THEN
        RETURN 7;
      ELSE
        RETURN NULL;
    END CASE;
  END day_to_number;

  --check if the day is within the working range
  FUNCTION check_working_day(p_day_of_week IN NUMBER, p_working_day IN VARCHAR2) RETURN BOOLEAN IS
    v_start_day     VARCHAR2(10);
    v_end_day       VARCHAR2(10);
    v_start_day_num NUMBER;
    v_end_day_num   NUMBER;
  BEGIN
    -- Check if p_working_day is a range or a single day
    IF instr(p_working_day, '-') > 0 THEN
      -- It’s a range, split by the hyphen
      v_start_day := TRIM(substr(p_working_day, 1, instr(p_working_day, '-') - 1));
      v_end_day   := TRIM(substr(p_working_day, instr(p_working_day, '-') + 1));
    
      v_start_day_num := day_to_number(v_start_day);
      v_end_day_num   := day_to_number(v_end_day);
    
      -- Check if p_day_of_week is within the range
      IF (v_start_day_num <= p_day_of_week AND v_end_day_num >= p_day_of_week)
         OR (v_start_day_num > v_end_day_num AND
             (p_day_of_week >= v_start_day_num OR p_day_of_week <= v_end_day_num))
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    ELSE
      -- It’s a single day, compare directly
      v_start_day     := TRIM(p_working_day);
      v_start_day_num := day_to_number(v_start_day);
    
      IF v_start_day_num = p_day_of_week THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
  END check_working_day;

  --schedule the appointment
  PROCEDURE schedule_appointment(p_patient_id IN NUMBER, p_date IN DATE) IS
    v_current_condition  VARCHAR2(100);
    v_doctor_id          NUMBER;
    v_working_day        VARCHAR2(30);
    v_working_hours      VARCHAR2(20);
    v_day_of_week        NUMBER;
    v_appointment_exists NUMBER;
  
    v_start_time    TIMESTAMP;
    v_end_time      TIMESTAMP;
    v_input_time    TIMESTAMP;
    v_input_minutes NUMBER;
  
  BEGIN
    v_input_minutes := to_number(to_char(p_date, 'MI'));
    IF v_input_minutes NOT IN (0, 15, 30, 45) THEN
      raise_application_error(-20001, 'Invalid time. Minutes must be 00, 15, 30, or 45.');
    END IF;
  
    SELECT current_condition
      INTO v_current_condition
      FROM patients
     WHERE patient_id = p_patient_id;

    dbms_output.put_line('Patient ' || p_patient_id || ' has condition: ' || v_current_condition);
  
    FOR doctor_rec IN (SELECT doctor_id, condition_name
                         FROM conditions_specialisations
                        WHERE condition_name = v_current_condition) LOOP
    
      SELECT working_day, working_hours
        INTO v_working_day, v_working_hours
        FROM doctors
       WHERE doctor_id = doctor_rec.doctor_id;

      dbms_output.put_line('Doctor ' || doctor_rec.doctor_id || ' works on: ' || v_working_day ||
                           ' with working hours: ' || v_working_hours);

      v_day_of_week := day_to_number(TRIM(to_char(p_date, 'DAY', 'NLS_DATE_LANGUAGE= ''ENGLISH''')));

      IF check_working_day(v_day_of_week, v_working_day) THEN
        v_start_time := to_timestamp(to_char(p_date, 'YYYY-MM-DD') || ' ' || substr(v_working_hours, 1, 5),
                                     'YYYY-MM-DD HH24:MI');
        v_end_time   := to_timestamp(to_char(p_date, 'YYYY-MM-DD') || ' ' || substr(v_working_hours,
                                                                                       instr(v_working_hours, '-') + 1),
                                     'YYYY-MM-DD HH24:MI');
        
        v_input_time := to_timestamp(to_char(p_date, 'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI');
        
        IF v_input_time >= v_start_time AND v_input_time + INTERVAL '15' MINUTE <= v_end_time THEN
          -- Check if the appointment slot is already taken
          SELECT COUNT(*)
            INTO v_appointment_exists
            FROM appointments
           WHERE doctor_id = doctor_rec.doctor_id
             AND ((appointment_start <= v_input_time AND appointment_end > v_input_time) OR
                  (appointment_start < v_input_time + INTERVAL '15' MINUTE AND appointment_end >= v_input_time + INTERVAL '15' MINUTE));

          IF v_appointment_exists = 0 THEN
            INSERT INTO appointments
              (appointment_id, patient_id, doctor_id, appointment_start, appointment_end, appointment_status)
            VALUES
              (appointment_seq.nextval, p_patient_id, doctor_rec.doctor_id, v_input_time,
               v_input_time + INTERVAL '15' MINUTE, 'Scheduled');
          
            dbms_output.put_line('Appointment scheduled with doctor ' || doctor_rec.doctor_id || ' from ' ||
                                 to_char(v_input_time, 'HH24:MI') || ' to ' || to_char(v_input_time + INTERVAL '15' MINUTE, 'HH24:MI'));
            RETURN;
          ELSE
            dbms_output.put_line('The selected appointment time is already taken by another patient.');
          END IF;
        ELSE
          dbms_output.put_line('The selected time is outside the available working hours for doctor ' || doctor_rec.doctor_id);
        END IF;
      ELSE
        dbms_output.put_line('Doctor ' || doctor_rec.doctor_id || ' does not work on the selected day.');
      END IF;
    END LOOP;

    dbms_output.put_line('No available doctor found for the given condition, date, and time.');
    raise_application_error(-20002, 'No available doctor found for the given condition, date, and time.');
  END schedule_appointment;

END appointment_manager;
/
