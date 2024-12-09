--Selecting tables
select * from patient;
select * from doctor;
select * from condition_specialisation;
select * from appointment;
select * from treatment;
select * from bill;

--get_patient_current_condition function test
SELECT get_patient_current_condition(1) AS current_condition
FROM dual;

--list_doctors_by_condition
SELECT list_doctors_by_condition('Diabetes') FROM dual;

--Scheduling appointments
BEGIN
    Appointment_Manager.schedule_appointment(3, TO_DATE('2024-12-10 17:00', 'YYYY-MM-DD HH24:MI'));
END;

--Changing appointment status to Completed or Canceled
BEGIN
  appointment_package.update_appointment_status(
      p_appointment_id => 3,
      p_status         => 2, --1 Canceled 2 Completed
      p_bill        =>   100-- p_bill not necessary for Canceled 
      --p_treatment_description   =>     'test' --p_treatment_description not necessary for Completed/Canceled
  );
END;

--Selecting views
select * from patient_appointment_view;
select * from active_patients_view;

--Testing add_new_doctor and add_new_patient procedures
BEGIN
    healthcare_manager.add_new_patient(
        p_patient_name      => 'Test2',
        p_age               => 28,
        p_gender            => 'Male',
        p_phone_number      => '1234567890',
        p_email             => 'test@example.com',
        p_medical_history   => 'No known allergies',
        p_current_condition => 'Heart Diseases'
    );
END;
/
BEGIN
  healthcare_manager.add_new_doctor(
    p_doctor_name => 'Dr. Smith2',
    p_phone_number => '+1234567890',
    p_email => 'dr.smith@example.com',
    p_working_day => 'Monday',
    p_working_hour => '08:00-15:00',
    p_condition_name => 'Heart Diseases',
    p_specialisation_name => 'Cardiology'
  );
END;

--Testing update_patient_status_job
UPDATE Treatment
SET treatment_date = TO_DATE('2024-11-20', 'YYYY-MM-DD')
WHERE patient_id = 1;

BEGIN
    DBMS_SCHEDULER.RUN_JOB('update_patient_status_job');
END;

--Testing add_condition_specialisation
BEGIN
    healthcare_manager.add_condition_specialisation(
        p_doctor_id => 1,
        p_condition_name => 'Dermatitis',
        p_specialisation_name => 'Dermatology'
    );
END;

--Testing payment and bill status trigger
BEGIN
    healthcare_manager.payment(50, 3);
END;

Update bill
set due_date = TO_DATE('11/15/2024', 'MM/DD/YYYY')
where bill_id = 8;

-- Only to 0 amount_paid for testing
UPDATE Bill
SET amount_paid = 0
WHERE bill_id = 3;





