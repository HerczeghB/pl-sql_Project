create or replace view active_patients_view as
select patient_id, patient_name, age, gender, phone_number, email, medical_history, current_condition, registration_date
from patients
where patient_status = 'Active';
