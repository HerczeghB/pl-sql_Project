create view patient_appointment_view as
select
p.patient_id,
p.patient_name,
p.age,
p.gender,
p.current_condition,
a.appointment_start,
a.appointment_end,
a.appointment_status,
d.doctor_name
from patient p join appointment a on p.patient_id = a.patient_id join doctor d on d.doctor_id = a.doctor_id;
