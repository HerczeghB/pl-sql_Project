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
    UPDATE appointments
       SET appointment_status = 'Canceled'
     WHERE appointment_id = p_appointment_id;
  END cancel_appointment;

  PROCEDURE complete_appointment(p_appointment_id        IN NUMBER
                                ,p_bill                  IN NUMBER
                                ,p_treatment_description IN VARCHAR2) IS
    v_patient_id NUMBER;
    v_doctor_id  NUMBER;
  
  BEGIN
    IF p_bill = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Bill amount cannot be zero.');
    END IF;

    SELECT patient_id
          ,doctor_id
      INTO v_patient_id
          ,v_doctor_id
      FROM appointments
     WHERE appointment_id = p_appointment_id;
  
    UPDATE appointments
       SET appointment_status = 'Completed'
     WHERE appointment_id = p_appointment_id;
  
    INSERT INTO treatments
      (treatment_id
      ,patient_id
      ,treatment_description
      ,treatment_date
      ,doctor_id)
    VALUES
      (treatment_seq.nextval
      ,v_patient_id
      ,p_treatment_description
      ,trunc(SYSDATE)
      ,v_doctor_id);
  
    INSERT INTO bills
      (bill_id
      ,patient_id
      ,total_amount
      ,payment_status
      ,payment_date
      ,bill_date
      ,due_date
      ,amount_paid)
    VALUES
      (bill_seq.nextval
      ,v_patient_id
      ,p_bill
      ,'Pending'
      ,NULL
      ,trunc(SYSDATE)
      ,trunc(SYSDATE) + 60
      ,0);
  
  END complete_appointment;

END appointment_package;
/
