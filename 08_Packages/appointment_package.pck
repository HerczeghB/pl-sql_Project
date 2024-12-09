CREATE OR REPLACE PACKAGE appointment_package IS

  PROCEDURE update_appointment_status(p_appointment_id        IN NUMBER
                                     ,p_status                IN NUMBER
                                     ,p_bill                  IN NUMBER DEFAULT NULL
                                     ,p_treatment_description IN VARCHAR2 DEFAULT NULL);

  PROCEDURE cancel_appointment(p_appointment_id IN NUMBER);
  PROCEDURE complete_appointment(p_appointment_id        IN NUMBER
                                ,p_bill                  IN NUMBER
                                ,p_treatment_description IN VARCHAR2);

END appointment_package;
/
CREATE OR REPLACE PACKAGE BODY appointment_package AS

  PROCEDURE update_appointment_status(p_appointment_id        IN NUMBER
                                     ,p_status                IN NUMBER
                                     ,p_bill                  IN NUMBER DEFAULT NULL
                                     ,p_treatment_description IN VARCHAR2 DEFAULT NULL) IS
                                     
  BEGIN
  
    CASE p_status
      WHEN 1 THEN
        cancel_appointment(p_appointment_id);
      WHEN 2 THEN
        complete_appointment(p_appointment_id,
                             p_bill,
                             nvl(p_treatment_description,
                                 'No description provided'));
      ELSE
        raise_application_error(-20001, 'Invalid status provided');
    END CASE;
  
  END update_appointment_status;

  PROCEDURE cancel_appointment(p_appointment_id IN NUMBER) IS
  BEGIN
    UPDATE appointment
       SET appointment_status = 'Canceled'
     WHERE appointment_id = p_appointment_id;
  END cancel_appointment;

  PROCEDURE complete_appointment(p_appointment_id        IN NUMBER
                                ,p_bill                  IN NUMBER
                                ,p_treatment_description IN VARCHAR2) IS
    v_patient_id NUMBER;
    v_doctor_id  NUMBER;
    v_current_status VARCHAR2(20);
  
  BEGIN
    IF p_bill <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Bill amount cannot be zero or negative.');
    END IF;

    SELECT patient_id
          ,doctor_id
          ,appointment_status
      INTO v_patient_id
          ,v_doctor_id
          ,v_current_status
      FROM appointment
     WHERE appointment_id = p_appointment_id;
     
     IF v_current_status != 'Scheduled' THEN
        RAISE_APPLICATION_ERROR(-20003, 'Appointment can only be marked as completed if it is currently in Scheduled status.');
    END IF;
  
    UPDATE appointment
       SET appointment_status = 'Completed'
     WHERE appointment_id = p_appointment_id;
  
    INSERT INTO treatment
      (patient_id
      ,treatment_description
      ,treatment_date
      ,doctor_id)
    VALUES
      (v_patient_id
      ,p_treatment_description
      ,trunc(SYSDATE)
      ,v_doctor_id);
  
    INSERT INTO bill
      (patient_id
      ,total_amount
      ,payment_status
      ,payment_date
      ,bill_date
      ,due_date
      ,amount_paid)
    VALUES
      (v_patient_id
      ,p_bill
      ,'Pending'
      ,NULL
      ,trunc(SYSDATE)
      ,trunc(SYSDATE) + 60
      ,0);
  
  END complete_appointment;

END appointment_package;
/
