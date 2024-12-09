CREATE OR REPLACE TRIGGER bill_status_update
  BEFORE UPDATE OR INSERT ON bill
  FOR EACH ROW
BEGIN
  IF :new.amount_paid = :new.total_amount
  THEN
    :new.payment_status := 'Paid';
    :new.payment_date   := trunc(SYSDATE);
  ELSE
    :new.payment_status := 'Pending';
    :new.payment_date   := NULL;
  END IF;

  IF :new.payment_status = 'Pending'
     AND :new.due_date <= SYSDATE
  THEN
    :new.payment_status := 'Overdue';
    :new.total_amount   := :new.total_amount * 1.05;
  END IF;
END;
/
