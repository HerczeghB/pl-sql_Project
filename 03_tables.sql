--Creating Patient Table (beteg)
Create table Patient(
       patient_id number Primary key not null,
       patient_name varchar2(60) not null,
       age number check(age>=0) not null,
       gender varchar2(10) not null,
       phone_number varchar2(15),
       email varchar2(100),
       medical_history clob,
       patient_status varchar2(20) not null,
       current_condition varchar2(100),
       registration_date date default sysdate not null
       );

--Creating Doctor Table(orvos)
Create table Doctor(
       doctor_id NUMBER PRIMARY KEY not null,
       doctor_name VARCHAR2(60) not null,
       phone_number VARCHAR2(15),
       email VARCHAR2(100),
       working_day varchar2(30),
       working_hour VARCHAR2(20)
       );

-- Creating Condition_Specialisation Table(doktor-betegség speciálódás)
CREATE TABLE Condition_Specialisation(
       condition_specialisation_id NUMBER PRIMARY KEY not null,
       doctor_id NUMBER not null,
       condition_name VARCHAR2(100) not null,
       specialisation_name VARCHAR2(100) not null,
       FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
       );
       
-- Creating Appointment Table(időpont)
CREATE TABLE Appointment(
       appointment_id NUMBER PRIMARY KEY not null,
       patient_id NUMBER not null,
       doctor_id NUMBER not null,
       appointment_start DATE not null,
       appointment_end DATE not null,
       appointment_status VARCHAR2(20),
       FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
       FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
       );
       
-- Creating Treatment Table(kezelés)
CREATE TABLE Treatment(
    treatment_id NUMBER PRIMARY KEY not null,
    patient_id NUMBER not null,
    doctor_id NUMBER not null,
    treatment_description VARCHAR2(255) not null,
    treatment_date DATE not null,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
    );
    
-- Creating Bill Table(számla)
CREATE TABLE Bill(
    bill_id NUMBER PRIMARY KEY not null,
    patient_id NUMBER not null,
    total_amount NUMBER not null,
    amount_paid number default 0,
    payment_status VARCHAR2(20) not null,
    payment_date DATE default null,
    bill_date DATE DEFAULT SYSDATE not null,
    due_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
    );
--Comments
Comment on column bill.payment_status is 'Fizetes statusza: Paid(kifizetett), Pending(meg nincs kifizetve), Overdue(késedelmes)';
Comment on column appointment.appointment_status is 'Rendeles/idopont statusza: Scheduled(tervezett), Completed(befejezett), Canceled(lemondott)';
Comment on column patient.patient_status is 'Betegek statusza: Active(A beteg kezelesen vesz/vett reszt az elmult 1 evben), Inactive(A beteg nem vett reszt kezelesen, vagy kezelese tobb mint 1 evvel ezelott tortent);'
