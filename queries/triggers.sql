

DROP TRIGGER trg_student
DROP TRIGGER trg_issue
DROP TRIGGER trg_accomodation
DROP TRIGGER trg_administration_worker
DROP TRIGGER trg_doorkeeper
GO

CREATE TRIGGER trg_student
ON student
INSTEAD OF INSERT
AS
BEGIN TRY


IF EXISTS (SELECT aw.person_id FROM administration_worker aw WHERE aw.person_id = (SELECT person_id FROM inserted))
 THROW 51000, 'This person is already an administration worker', 1; 
IF EXISTS (SELECT d.person_id FROM doorkeeper d WHERE d.person_id = (SELECT person_id FROM inserted))
 THROW 51000, 'This person is already a doorkeeper', 1; 

INSERT INTO student(term, degree_course_id, person_id, room_id) SELECT term, degree_course_id, person_id, room_id FROM inserted
END TRY
BEGIN CATCH
THROW;
END CATCH

GO



CREATE TRIGGER trg_administration_worker
ON administration_worker
INSTEAD OF INSERT
AS
BEGIN TRY


IF EXISTS (SELECT s.person_id FROM student s WHERE s.person_id = (SELECT person_id FROM inserted))
 THROW 51000, 'This person is already a student', 1; 
IF EXISTS (SELECT d.person_id FROM doorkeeper d WHERE d.person_id = (SELECT person_id FROM inserted))
 THROW 51000, 'This person is already a doorkeeper', 1; 

INSERT INTO administration_worker(email, phone_number, dormitory_id, person_id) SELECT email, phone_number, dormitory_id, person_id FROM inserted
END TRY
BEGIN CATCH
THROW;
END CATCH

GO

CREATE TRIGGER trg_doorkeeper
ON doorkeeper
INSTEAD OF INSERT
AS
BEGIN TRY


IF EXISTS (SELECT s.person_id FROM student s WHERE s.person_id = (SELECT person_id FROM inserted))
 THROW 51000, 'This person is already a student', 1; 
IF EXISTS (SELECT aw.person_id FROM administration_worker aw WHERE aw.person_id = (SELECT person_id FROM inserted))
 THROW 51000, 'This person is already an administration worker', 1; 

INSERT INTO doorkeeper(dormitory_id, person_id) SELECT dormitory_id, person_id FROM inserted
END TRY
BEGIN CATCH
THROW;
END CATCH

GO


CREATE TRIGGER trg_issue
ON issue
INSTEAD OF INSERT
AS
BEGIN TRY

DECLARE @dorm1 AS VARCHAR(100)
DECLARE @dorm2 AS VARCHAR(100)

SET @dorm1 = (SELECT s.[Dormitory] FROM students s WHERE s.id= (SELECT student_id FROM INSERTED))	
SET @dorm2 = (SELECT d.[Dormitory] FROM doorkeepers d WHERE d.id=(SELECT doorkeeper_id FROM INSERTED))
IF @dorm1 != @dorm2 THROW 51000, 'There is an identity problem. Student and doorkeeper are from different dormitories', 1; 

INSERT INTO issue(date, content, student_id, doorkeeper_id) SELECT date, content, student_id, doorkeeper_id FROM INSERTED 


END TRY
BEGIN CATCH
THROW;
END CATCH

GO


CREATE TRIGGER trg_accomodation
ON accomodation
INSTEAD OF INSERT
AS
BEGIN TRY

DECLARE @dorm1 AS VARCHAR(100)
DECLARE @dorm2 AS VARCHAR(100)

SET @dorm1 = (SELECT s.[Dormitory] FROM students s WHERE s.id= (SELECT student_id FROM INSERTED))	
SET @dorm2 = (SELECT d.[Dormitory] FROM doorkeepers d WHERE d.id=(SELECT doorkeeper_id FROM INSERTED))
IF @dorm1 != @dorm2 THROW 51000, 'There is an identity problem. Student and doorkeeper are from different dormitories', 1; 

INSERT INTO accomodation(start_date, end_date, student_id, person_id, doorkeeper_id) SELECT start_date, end_date, student_id, person_id, doorkeeper_id FROM INSERTED 


END TRY
BEGIN CATCH
THROW;
END CATCH



