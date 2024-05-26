ALTER TABLE dimemployee
DROP CONSTRAINT dimemployee_pkey;

ALTER TABLE dimemployee
ADD COLUMN startdate TIMESTAMP,
ADD COLUMN enddate TIMESTAMP,
ADD COLUMN iscurrent BOOLEAN DEFAULT TRUE,
ADD COLUMN employeehistoryid SERIAL PRIMARY KEY;

UPDATE  dimemployee SET employeehistoryid = DEFAULT;

UPDATE dimemployee SET startdate = hiredate, enddate = '9999-12-31';
   
CREATE OR REPLACE FUNCTION employees_update_function()
RETURNS TRIGGER AS $$
BEGIN
    IF (old.title <> new.title OR old.address <> new.address) AND old.iscurrent AND new.iscurrent THEN
        UPDATE dimemployee
        SET enddate = CURRENT_TIMESTAMP,
        iscurrent = FALSE, title = old.title,
        address = old.address
        WHERE employeeid = old.employeeid AND iscurrent = TRUE;
        INSERT INTO dimemployee (employeeid, lastname, firstname, title, birthdate, hiredate, address, city, region, postalcode, country, homephone, extension, startdate, enddate, iscurrent)
        VALUES (old.employeeid, old.lastname, old.firstname, new.title, old.birthdate, old.hiredate, new.address, old.city, old.region, old.postalcode, old.country, old.homephone, old.extension, CURRENT_TIMESTAMP, '9999-12-31', TRUE);
    END IF;
    RETURN new;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS employees_update_trigger ON dimemployee CASCADE;
CREATE TRIGGER employees_update_trigger
AFTER UPDATE ON dimemployee
FOR EACH ROW
EXECUTE FUNCTION employees_update_function();

UPDATE dimemployee
SET address = 'mogilevskaya'
WHERE firstname = 'Uladzislau' AND lastname = 'Bandarenka' AND iscurrent = TRUE;

UPDATE dimemployee
SET title ='manager'
WHERE firstname = 'Petr' AND lastname = 'Sidorov' AND iscurrent = TRUE;
