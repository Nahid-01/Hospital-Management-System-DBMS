SET LINESIZE 200;
SET PAGESIZE 100;

-- 1. Department
CREATE TABLE department (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(50) NOT NULL,
    location VARCHAR2(50)
);
INSERT INTO department VALUES (1, 'Cardiology', 'Building A');
INSERT INTO department VALUES (2, 'Neurology', 'Building B');
INSERT INTO department VALUES (3, 'Orthopedics', 'Building C');

-- 2. Doctor
CREATE TABLE doctor (
    doctor_id NUMBER PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    specialization VARCHAR2(50),
    phone VARCHAR2(15),
    dept_id NUMBER REFERENCES department(dept_id)
);
INSERT INTO doctor VALUES (101, 'Dr. Rahman', 'Cardiologist', '01711111111', 1);
INSERT INTO doctor VALUES (102, 'Dr. Karim', 'Neurologist', '01822222222', 2);
INSERT INTO doctor VALUES (103, 'Dr. Hasan', 'Orthopedic Surgeon', '01933333333', 3);

-- 3. Patient
CREATE TABLE patient (
    patient_id NUMBER PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    gender VARCHAR2(10),
    dob DATE,
    phone VARCHAR2(15),
    address VARCHAR2(100)
);
INSERT INTO patient VALUES (201, 'Asha', 'Female', DATE '2001-05-12', '01744444444', 'Dhaka');
INSERT INTO patient VALUES (202, 'Karim', 'Male', DATE '1998-08-20', '01855555555', 'Chittagong');
INSERT INTO patient VALUES (203, 'Nadia', 'Female', DATE '2003-01-15', '01966666666', 'Dhaka');
INSERT INTO patient VALUES (204, 'Sakib', 'Male', DATE '1995-11-10', '01677777777', 'Rajshahi');
INSERT INTO patient VALUES (205, 'Mitu', 'Female', DATE '2000-03-25', '01588888888', 'Khulna');

-- 4. Appointment
CREATE TABLE appointment (
    appointment_id NUMBER PRIMARY KEY,
    patient_id NUMBER REFERENCES patient(patient_id),
    doctor_id NUMBER REFERENCES doctor(doctor_id),
    app_date DATE,
    status VARCHAR2(20) CHECK (status IN ('Completed', 'Pending', 'Cancelled'))
);
INSERT INTO appointment VALUES (301, 201, 101, DATE '2026-09-01', 'Completed');
INSERT INTO appointment VALUES (302, 202, 102, DATE '2026-09-02', 'Completed');
INSERT INTO appointment VALUES (303, 203, 103, DATE '2026-09-03', 'Pending');
INSERT INTO appointment VALUES (304, 201, 101, DATE '2026-09-10', 'Completed');
INSERT INTO appointment VALUES (305, 204, 102, DATE '2026-09-12', 'Cancelled');

-- 5. Medicine
CREATE TABLE medicine (
    medicine_id NUMBER PRIMARY KEY,
    medicine_name VARCHAR2(50),
    manufacturer VARCHAR2(50),
    price NUMBER(8,2)
);
INSERT INTO medicine VALUES (401, 'Napa', 'Square', 2.00);
INSERT INTO medicine VALUES (402, 'Seclo', 'Square', 5.00);
INSERT INTO medicine VALUES (403, 'DP', 'Beximco', 8.00);
INSERT INTO medicine VALUES (404, 'Napa Extra', 'Square', 4.00);
INSERT INTO medicine VALUES (405, 'Flexi', 'Renata', 12.00);

-- 6. Prescription
CREATE TABLE prescription (
    prescription_id NUMBER PRIMARY KEY,
    appointment_id NUMBER REFERENCES appointment(appointment_id),
    patient_id NUMBER REFERENCES patient(patient_id),
    medicine_id NUMBER REFERENCES medicine(medicine_id),
    quantity NUMBER
);
INSERT INTO prescription VALUES (501, 301, 201, 401, 10);
INSERT INTO prescription VALUES (502, 301, 201, 402, 5);
INSERT INTO prescription VALUES (503, 302, 202, 403, 3);
INSERT INTO prescription VALUES (504, 304, 201, 404, 5);
INSERT INTO prescription VALUES (505, 303, 203, 405, 2);

-- 7. Diagnosis
CREATE TABLE diagnosis (
    diagnosis_id NUMBER PRIMARY KEY,
    appointment_id NUMBER REFERENCES appointment(appointment_id),
    diagnosis_name VARCHAR2(100),
    diagnosis_date DATE
);
INSERT INTO diagnosis VALUES (601, 301, 'Heart Disease', DATE '2026-09-01');
INSERT INTO diagnosis VALUES (602, 302, 'Migraine', DATE '2026-09-02');
INSERT INTO diagnosis VALUES (603, 303, 'Bone Fracture', DATE '2026-09-03');
INSERT INTO diagnosis VALUES (604, 304, 'Chest Pain', DATE '2026-09-10');

-- 8. Bill
CREATE TABLE bill (
    bill_id NUMBER PRIMARY KEY,
    appointment_id NUMBER UNIQUE REFERENCES appointment(appointment_id),
    consultation_fee NUMBER(8,2),
    medicine_charge NUMBER(8,2),
    total_amount NUMBER(10,2),
    payment_status VARCHAR2(20) CHECK (payment_status IN ('Paid', 'Unpaid'))
);
INSERT INTO bill VALUES (701, 301, 1000, 45, 1045, 'Paid');
INSERT INTO bill VALUES (702, 302, 800, 24, 824, 'Paid');
INSERT INTO bill VALUES (703, 303, 1200, 24, 1224, 'Unpaid');
INSERT INTO bill VALUES (704, 304, 1000, 20, 1020, 'Paid');
INSERT INTO bill VALUES (705, 305, 500, 0, 500, 'Unpaid');

-- 1: WHERE + AND + OR + NOT + ORDER BY
SELECT * FROM patient WHERE NOT gender = 'Male' AND (address = 'Dhaka' OR address = 'Khulna') ORDER BY name;

-- 2: LIKE + IN
SELECT * FROM patient WHERE name LIKE 'A%' OR address IN ('Dhaka', 'Chittagong');

-- 3: BETWEEN + NOT IN + SUBQUERY
SELECT * FROM bill WHERE total_amount BETWEEN 400 AND 1200
AND appointment_id NOT IN (SELECT appointment_id FROM appointment WHERE status = 'Cancelled');

-- 4: SET OPERATIONS
SELECT patient_id FROM appointment UNION SELECT patient_id FROM prescription;
SELECT patient_id FROM appointment UNION ALL SELECT patient_id FROM prescription;
SELECT patient_id FROM appointment INTERSECT SELECT patient_id FROM prescription;
SELECT patient_id FROM patient MINUS SELECT patient_id FROM appointment;

-- 5: Comparison Operators (SOME / ALL)
SELECT * FROM bill WHERE total_amount > SOME (SELECT total_amount FROM bill WHERE payment_status = 'Paid');
SELECT * FROM bill WHERE total_amount > ALL (SELECT total_amount FROM bill WHERE payment_status = 'Paid');

-- 6: EXISTS
SELECT name, address FROM patient p WHERE EXISTS (SELECT 1 FROM appointment a WHERE p.patient_id = a.patient_id);

-- 7: INNER JOIN
SELECT p.name AS patient_name, d.name AS doctor_name, a.app_date, a.status FROM patient p
JOIN appointment a ON p.patient_id = a.patient_id
JOIN doctor d ON a.doctor_id = d.doctor_id
WHERE a.status = 'Completed'
ORDER BY a.app_date;

-- 8: LEFT JOIN + Aggregation
SELECT d.name AS doctor_name, COUNT(a.appointment_id) AS total_appointments FROM doctor d
LEFT JOIN appointment a ON d.doctor_id = a.doctor_id GROUP BY d.name;

-- 9: RIGHT JOIN & FULL JOIN
SELECT d.dept_name, dr.name AS doctor_name FROM doctor dr RIGHT JOIN department d ON dr.dept_id = d.dept_id;
SELECT d.dept_name, dr.name AS doctor_name FROM department d FULL JOIN doctor dr ON d.dept_id = dr.dept_id;

-- 10: Aggregates + GROUP BY + HAVING
SELECT manufacturer, COUNT(*) AS total_med, AVG(price) AS avg_price FROM medicine GROUP BY manufacturer HAVING AVG(price) > 5;

-- 11: WITH CLAUSE
WITH HighBill AS (
    SELECT * FROM bill WHERE total_amount > 1000
)
SELECT * FROM HighBill;


-- View 1: Patient_App_View
CREATE OR REPLACE VIEW Patient_App_View AS
SELECT patient_id, appointment_id FROM appointment
WHERE patient_id IN (SELECT patient_id FROM patient WHERE address = 'Dhaka');

SELECT patient_id, COUNT(*) FROM Patient_App_View
GROUP BY patient_id
HAVING COUNT(*) >= 2;

-- View 2: Dept_Workload_View
CREATE OR REPLACE VIEW Dept_Workload_View AS
SELECT dept_id, doctor_id FROM doctor
WHERE dept_id IN (SELECT dept_id FROM department WHERE location = 'Building A');

SELECT dept_id, COUNT(*) FROM Dept_Workload_View
GROUP BY dept_id
HAVING COUNT(*) >= 1;


-- 1. Variables & Output
DECLARE
    patient_name VARCHAR2(30) := 'Asha';
    bill_amount  NUMBER := 1045;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Patient: ' || patient_name || ' | Bill: ' || bill_amount);
END;
/

-- 2. %TYPE & %ROWTYPE
DECLARE
    p_name patient.name%TYPE;
    p_rec  patient%ROWTYPE;
BEGIN
    SELECT name INTO p_name FROM patient WHERE patient_id = 201;
    SELECT * INTO p_rec FROM patient WHERE patient_id = 201;
    DBMS_OUTPUT.PUT_LINE('Name: ' || p_name || ' | Address: ' || p_rec.address);
END;
/

-- 3. IF-ELSIF-ELSE
DECLARE
    amount NUMBER := 1045;
BEGIN
    IF amount >= 1500 THEN
        DBMS_OUTPUT.PUT_LINE('High Bill');
    ELSIF amount >= 800 THEN
        DBMS_OUTPUT.PUT_LINE('Medium Bill');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Low Bill');
    END IF;
END;
/

-- 4. Associative Array + Loop
DECLARE
    TYPE name_array IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
    patient_names name_array;
BEGIN
    FOR i IN 1..3 LOOP
        SELECT name INTO patient_names(i) FROM patient WHERE patient_id = 200 + i;
        DBMS_OUTPUT.PUT_LINE('Patient ' || i || ': ' || patient_names(i));
    END LOOP;
END;
/

-- 5. VARRAY (short, simple values)
DECLARE
    TYPE bill_array IS VARRAY(3) OF NUMBER;
    bills bill_array := bill_array(1045, 824, 1224);
BEGIN
    FOR i IN 1..bills.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Bill ' || i || ': ' || bills(i));
    END LOOP;
END;
/

-- 6. Exception Handling
DECLARE
    p_name patient.name%TYPE;
BEGIN
    SELECT name INTO p_name FROM patient WHERE patient_id = 999;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Patient not found!');
END;
/

-- 7. Procedure
CREATE OR REPLACE PROCEDURE update_app_status (p_id NUMBER, p_status VARCHAR2) IS
BEGIN
    UPDATE appointment SET status = p_status WHERE appointment_id = p_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment status updated.');
END;
/
EXEC update_app_status(303, 'Completed');

-- 8. Function (simple calculation)
CREATE OR REPLACE FUNCTION get_patient_bill (p_id NUMBER) RETURN NUMBER IS
    total NUMBER;
BEGIN
    SELECT NVL(SUM(total_amount), 0) INTO total
    FROM bill b JOIN appointment a ON b.appointment_id = a.appointment_id
    WHERE a.patient_id = p_id;
    RETURN total;
END;
/
SELECT get_patient_bill(201) AS total_bill FROM dual;

-- 9. Cursor
DECLARE
    CURSOR doc_cursor IS
        SELECT dr.name AS doc_name, d.dept_name
        FROM doctor dr JOIN department d ON dr.dept_id = d.dept_id;
BEGIN
    FOR rec IN doc_cursor LOOP
        DBMS_OUTPUT.PUT_LINE(rec.doc_name || ' works in ' || rec.dept_name);
    END LOOP;
END;
/

--CASE STATEMENT
SELECT bill_id, total_amount,
       CASE
           WHEN total_amount >= 1500 THEN 'High'
           WHEN total_amount >= 800  THEN 'Medium'
           ELSE 'Low'
       END AS bill_category
FROM bill;
