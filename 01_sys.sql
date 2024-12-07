PROMPT creating hospital_manager user...

DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO v_count
    FROM dba_users t
   WHERE t.username = 'HOSPITAL_MANAGER';
  IF v_count = 1
  THEN
    EXECUTE IMMEDIATE 'DROP USER hospital_manager CASCADE';
  END IF;
END;
/ 
CREATE USER hospital_manager identified BY "12345678" DEFAULT tablespace users quota unlimited ON users;

grant CREATE session TO hospital_manager;
grant CREATE TABLE TO hospital_manager;
grant CREATE view TO hospital_manager;
grant CREATE sequence TO hospital_manager;
grant CREATE PROCEDURE TO hospital_manager;
grant CREATE trigger to hospital_manager;
grant CREATE job to hospital_manager;
Prompt Done.
