DROP TRIGGER IF EXISTS trg_student ON student;
DROP TRIGGER IF EXISTS trg_administration_worker ON administration_worker;
DROP TRIGGER IF EXISTS trg_doorkeeper ON doorkeeper;
DROP TRIGGER IF EXISTS trg_issue ON issue;
DROP TRIGGER IF EXISTS trg_accomodation ON accomodation;

DROP FUNCTION IF EXISTS validateIfPersonCanBeStudent();
DROP FUNCTION IF EXISTS validateIfPersonCanBeAdministrationWorker();
DROP FUNCTION IF EXISTS validateIfPersonCanBeDoorkeeper();
DROP FUNCTION IF EXISTS validateIfStudentAndDoorkeeperAreFromTheSameDormitory();

CREATE OR REPLACE FUNCTION validateIfPersonCanBeStudent() RETURNS TRIGGER
AS
$$
BEGIN
IF EXISTS (SELECT aw.person_id FROM administration_worker aw WHERE aw.person_id = NEW.person_id) THEN
RAISE 'This person is already an administration worker';
END IF;
IF EXISTS (SELECT d.person_id FROM doorkeeper d WHERE d.person_id = NEW.person_id) THEN
RAISE 'This person is already a doorkeeper'; 
END IF;
RETURN NULL;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER trg_student
BEFORE INSERT
ON student
FOR EACH ROW EXECUTE PROCEDURE validateIfPersonCanBeStudent();




CREATE OR REPLACE FUNCTION validateIfPersonCanBeAdministrationWorker() RETURNS TRIGGER
AS
$$
BEGIN
IF EXISTS (SELECT s.person_id FROM student s WHERE s.person_id = NEW.person_id) THEN
RAISE 'This person is already a student';
END IF;
IF EXISTS (SELECT d.person_id FROM doorkeeper d WHERE d.person_id = NEW.person_id) THEN
RAISE 'This person is already a doorkeeper'; 
END IF;
RETURN NULL;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER trg_administration_worker
BEFORE INSERT
ON administration_worker
FOR EACH ROW EXECUTE PROCEDURE validateIfPersonCanBeAdministrationWorker();





CREATE OR REPLACE FUNCTION validateIfPersonCanBeDoorkeeper() RETURNS TRIGGER
AS
$$
BEGIN
IF EXISTS (SELECT aw.person_id FROM administration_worker aw WHERE aw.person_id = NEW.person_id) THEN
RAISE 'This person is already an administration worker';
END IF;
IF EXISTS (SELECT s.person_id FROM student s WHERE s.person_id = NEW.person_id) THEN
RAISE 'This person is already a student';
END IF;
RETURN NULL;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER trg_doorkeeper
BEFORE INSERT
ON doorkeeper
FOR EACH ROW EXECUTE PROCEDURE validateIfPersonCanBeDoorkeeper();



CREATE OR REPLACE FUNCTION validateIfStudentAndDoorkeeperAreFromTheSameDormitory() RETURNS TRIGGER
AS
$$
DECLARE dorm1 VARCHAR(100);
DECLARE dorm2 VARCHAR(100);
BEGIN
dorm1 := (SELECT s."Dormitory" FROM students s WHERE s.id= NEW.student_id);	
dorm2 := (SELECT d."Dormitory" FROM doorkeepers d WHERE d.id=NEW.doorkeeper_id);
IF dorm1 != dorm2 THEN RAISE 'There is an identity problem. Student and doorkeeper are from different dormitories';
END IF;
RETURN NULL;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER trg_issue
BEFORE INSERT
ON issue
FOR EACH ROW EXECUTE PROCEDURE validateIfStudentAndDoorkeeperAreFromTheSameDormitory();


CREATE TRIGGER trg_accomodation
BEFORE INSERT
ON accomodation
FOR EACH ROW EXECUTE PROCEDURE validateIfStudentAndDoorkeeperAreFromTheSameDormitory();



