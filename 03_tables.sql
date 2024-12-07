--Creating Patients Table (betegek)
Create table Patients(
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

--Creating Doctors Table(orvosok)
Create table Doctors(
       doctor_id NUMBER PRIMARY KEY not null,
       doctor_name VARCHAR2(60) not null,
       phone_number VARCHAR2(15),
       email VARCHAR2(100),
       working_day varchar2(30),
       working_hours VARCHAR2(20)
       );

-- Creating Conditions_Specialisations Table(doktor-betegség speciálódás)
CREATE TABLE Conditions_Specialisations (
       condition_specialisation_id NUMBER PRIMARY KEY not null,
       doctor_id NUMBER not null,
       condition_name VARCHAR2(100) not null,
       specialisation_name VARCHAR2(100) not null,
       FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
       );
       
-- Creating Appointments Table(időpontok)
CREATE TABLE Appointments (
       appointment_id NUMBER PRIMARY KEY not null,
       patient_id NUMBER not null,
       doctor_id NUMBER not null,
       appointment_start DATE not null,
       appointment_end DATE not null,
       appointment_status VARCHAR2(20),
       FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
       FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
       );
       
-- Creating Treatments Table(kezelések)
CREATE TABLE Treatments (
    treatment_id NUMBER PRIMARY KEY not null,
    patient_id NUMBER not null,
    doctor_id NUMBER not null,
    treatment_description VARCHAR2(255) not null,
    treatment_date DATE not null,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
    );
    
-- Creating Bills Table(számlák)
CREATE TABLE Bills (
    bill_id NUMBER PRIMARY KEY not null,
    patient_id NUMBER not null,
    total_amount NUMBER not null,
    amount_paid number default 0,
    payment_status VARCHAR2(20) not null,
    payment_date DATE default null,
    bill_date DATE DEFAULT SYSDATE not null,
    due_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
    );
--Comments
Comment on column bills.payment_status is 'Fizetes statusza: Paid(kifizetett), Pending(meg nincs kifizetve), Overdue(késedelmes)';
Comment on column appointments.appointment_status is 'Rendeles/idopont statusza: Scheduled(tervezett), Completed(befejezett), Canceled(lemondott)';
Comment on column patients.patient_status is 'Betegek statusza: Active(A beteg kezelesen vesz/vett reszt az elmult 1 evben), Inactive(A beteg nem vett reszt kezelesen, vagy kezelese tobb mint 1 evvel ezelott tortent);'
