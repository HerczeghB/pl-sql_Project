CREATE OR REPLACE PROCEDURE payment(p_amount_paid IN NUMBER
                                   ,p_bill_id     IN NUMBER) IS
  v_total_amount NUMBER;
  v_amount_paid  NUMBER;
BEGIN
  SELECT total_amount
        ,amount_paid
    INTO v_total_amount
        ,v_amount_paid
    FROM bills
   WHERE bill_id = p_bill_id;

  --Error handling
  IF p_amount_paid < 0
  THEN
    raise_application_error(-20001, 'Payment amount cannot be negative.');
  ELSIF (v_amount_paid + p_amount_paid) > v_total_amount
  THEN
    raise_application_error(-20002,
                            'Payment amount cannot exceed the total amount owed.');
  END IF;

  --Updating bills
  UPDATE bills
     SET amount_paid = v_amount_paid + p_amount_paid
   WHERE bill_id = p_bill_id;

END payment;
/
