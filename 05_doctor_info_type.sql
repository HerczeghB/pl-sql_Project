CREATE OR REPLACE TYPE doctor_info_type AS OBJECT (
    doctor_name VARCHAR2(60),
    email VARCHAR2(100),
    phone_number VARCHAR2(15),
    specialisation_name VARCHAR2(100)
);

CREATE OR REPLACE TYPE doctor_info_list AS TABLE OF doctor_info_type;
