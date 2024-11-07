CREATE OR REPLACE FUNCTION get_max_id(p_table_name  IN VARCHAR2
                                     ,p_column_name IN VARCHAR2)
  RETURN NUMBER IS
  v_sql    VARCHAR2(4000);
  v_max_id NUMBER;
BEGIN
  v_sql := 'Select NVL(Max(' || p_column_name || '), 0) From ' ||
           p_table_name;
  EXECUTE IMMEDIATE v_sql
    INTO v_max_id;
  return v_max_id;
END get_max_id;
/
