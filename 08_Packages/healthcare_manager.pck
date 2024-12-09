CREATE OR REPLACE PACKAGE healthcare_manager AS
  PROCEDURE add_condition_specialisation(
    p_doctor_id IN NUMBER,
    p_condition_name IN VARCHAR2,
    p_specialisation_name IN VARCHAR2
  );

  PROCEDURE add_new_doctor(
    p_doctor_name IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2,
    p_working_day IN VARCHAR2,
    p_working_hour IN VARCHAR2,
    p_condition_name IN VARCHAR2,
    p_specialisation_name IN VARCHAR2
  );

  PROCEDURE add_new_patient(
    p_patient_name IN VARCHAR2,
    p_age IN NUMBER,
    p_gender IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2,
    p_medical_history IN CLOB,
    p_current_condition IN VARCHAR2
  );

  PROCEDURE payment(
    p_amount_paid IN NUMBER,
    p_bill_id IN NUMBER
  );
END healthcare_manager;
/
/
CREATE OR REPLACE PACKAGE BODY healthcare_manager AS

  PROCEDURE add_condition_specialisation(
    p_doctor_id IN NUMBER,
    p_condition_name IN VARCHAR2,
    p_specialisation_name IN VARCHAR2
  ) IS
    v_doctor_exists NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_doctor_exists
    FROM Doctor
    WHERE doctor_id = p_doctor_id;

    IF v_doctor_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Doctor ID does not exist.');
    END IF;

    INSERT INTO Condition_Specialisation(
      doctor_id, condition_name, specialisation_name
    )
    VALUES (
      p_doctor_id, p_condition_name, p_specialisation_name
    );

    DBMS_OUTPUT.PUT_LINE('Condition "' || p_condition_name || '" with specialisation "' || p_specialisation_name || 
                         '" added for Doctor ID ' || p_doctor_id || '.');
  END add_condition_specialisation;

  PROCEDURE add_new_doctor(
    p_doctor_name IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2,
    p_working_day IN VARCHAR2,
    p_working_hour IN VARCHAR2,
    p_condition_name IN VARCHAR2,
    p_specialisation_name IN VARCHAR2
  ) IS
  BEGIN
    IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
      RAISE_APPLICATION_ERROR(-20002, 'Invalid email format.');
    END IF;

    IF NOT REGEXP_LIKE(p_phone_number, '^\+?[0-9]{7,20}$') THEN
      RAISE_APPLICATION_ERROR(-20003, 'Invalid phone number format.');
    END IF;

    IF NOT REGEXP_LIKE(p_working_day, '^(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)(-(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday))?$') THEN
      RAISE_APPLICATION_ERROR(-20004, 'Invalid working day format.');
    END IF;

    IF NOT REGEXP_LIKE(p_working_hour, '^(0[8-9]|1[0-9]):[0-5][0-9]-(0[8-9]|1[0-9]):[0-5][0-9]$') THEN
      RAISE_APPLICATION_ERROR(-20005, 'Invalid working hour format.');
    END IF;

    INSERT INTO doctor
      (doctor_name, phone_number, email, working_day, working_hour)
    VALUES
      (p_doctor_name, p_phone_number, p_email, p_working_day, p_working_hour);

    INSERT INTO condition_specialisation
      (condition_name, specialisation_name, doctor_id)
    VALUES
      (p_condition_name, p_specialisation_name, doctor_seq.currval);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Doctor successfully added!');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      ROLLBACK;
      RAISE;
  END add_new_doctor;

  PROCEDURE add_new_patient(
    p_patient_name IN VARCHAR2,
    p_age IN NUMBER,
    p_gender IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2,
    p_medical_history IN CLOB,
    p_current_condition IN VARCHAR2
  ) IS
  BEGIN
    IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
      RAISE_APPLICATION_ERROR(-20002, 'Invalid email format.');
    END IF;

    IF NOT REGEXP_LIKE(p_phone_number, '^\+?[0-9]{7,20}$') THEN
      RAISE_APPLICATION_ERROR(-20003, 'Invalid phone number format.');
    END IF;

    INSERT INTO patient
      (patient_name, age, gender, phone_number, email, medical_history, current_condition)
    VALUES
      (p_patient_name, p_age, p_gender, p_phone_number, p_email, p_medical_history, p_current_condition);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      ROLLBACK;
      RAISE;
  END add_new_patient;

  PROCEDURE payment(p_amount_paid IN NUMBER, p_bill_id IN NUMBER) IS
    v_total_amount NUMBER;
    v_amount_paid NUMBER;
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM bill
    WHERE bill_id = p_bill_id;

    IF v_count = 0 THEN
      raise_application_error(-20003, 'Bill ID does not exist.');
    END IF;

    SELECT total_amount, NVL(amount_paid, 0)
    INTO v_total_amount, v_amount_paid
    FROM bill
    WHERE bill_id = p_bill_id;

    IF p_amount_paid < 0 THEN
      raise_application_error(-20001, 'Payment amount cannot be negative.');
    ELSIF (v_amount_paid + p_amount_paid) > v_total_amount THEN
      raise_application_error(-20002, 'Payment amount cannot exceed the total amount owed.');
    END IF;

    UPDATE bill
      SET amount_paid = v_amount_paid + p_amount_paid
    WHERE bill_id = p_bill_id;

    COMMIT;
  END payment;

END healthcare_manager;
/
