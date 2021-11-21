USE dormitory		
GO

DROP PROCEDURE addNewStudent
DROP PROCEDURE addAnnouncement
DROP PROCEDURE addIssue
GO

CREATE PROCEDURE addNewStudent 
(
	@firstName varchar(25) = NULL,
	@secondName varchar(25) = NULL,
	@lastName varchar(50) = NULL,
	@pesel char(11) = NULL,
	@street varchar(70) = NULL,
	@flat tinyint = NULL,
	@zip varchar(10) = NULL,
	@city varchar(50) = NULL,
	@country varchar(50) = NULL,
	@term tinyint = NULL,
	@degreeCourse varchar(100) = NULL,
	@department varchar(100) = NULL,
	@university varchar(150) = NULL,
	@room varchar(10),
	@dormitory varchar(100) = NULL
)
AS
BEGIN TRY
IF NOT EXISTS (SELECT id FROM university u WHERE u.name=@university) THROW 51000, 'Invalid university name.', 1; 
IF NOT EXISTS (SELECT id FROM department d WHERE d.name=@department) THROW 51000, 'Invalid department name.', 1; 
IF NOT EXISTS (SELECT id FROM degree_course dc WHERE dc.name=@degreeCourse) THROW 51000, 'Invalid degree course name.', 1; 
IF NOT EXISTS (SELECT id FROM dormitory d WHERE d.name=@dormitory) THROW 51000, 'Invalid dormitory name.', 1; 

DECLARE @duplicateAddressId AS INT
BEGIN TRAN
IF EXISTS (SELECT TOP 1 id FROM address ad WHERE ad.city=@city AND ad.country=@country AND ad.flat_number=@flat AND ad.postcode=@zip AND ad.street=@street)
SET @duplicateAddressId = (SELECT TOP 1 id FROM address ad WHERE ad.city=@city AND ad.country=@country AND ad.flat_number=@flat AND ad.postcode=@zip AND ad.street=@street)
ELSE
BEGIN
INSERT INTO address(street,postcode,city,country, flat_number) VALUES
(@street, @zip, @city, @country, @flat)
SET @duplicateAddressId = SCOPE_IDENTITY()
END

DECLARE @degreeCourseId AS SMALLINT
SET @degreeCourseId = (SELECT dc.id FROM degree_course dc INNER JOIN department d ON d.id=dc.department_id WHERE d.name=@department AND dc.name=@degreeCourse)
IF @degreeCourseId = NULL THROW 51000, 'Degree course not found for provided department', 1; 
DECLARE @departmentId AS SMALLINT
SET @departmentId = (SELECT d.id FROM department d INNER JOIN university u  ON u.id=d.university_id WHERE u.name=@university AND d.name=@department)
IF @departmentId = NULL THROW 51000, 'Department not found for provided university', 1; 
DECLARE @foundRoom AS TABLE(id INT, capacity TINYINT, locators INT)
INSERT INTO @foundRoom select r.id, r.capacity, r.locators FROM rooms r WHERE r.number=@room AND r.dormitory=@dormitory
IF NOT EXISTS (SELECT id FROM @foundRoom) THROW 51000, 'No room with provided number found in chosen dormitory', 1; 
IF EXISTS (SELECT * FROM @foundRoom WHERE capacity=locators) THROW 51000, 'This room is already full', 1; 
DECLARE @newPersonId AS INT
INSERT INTO person(first_name, second_name, last_name, pesel, address_id) VALUES
(@firstName, @secondName, @lastName, @pesel, @duplicateAddressId)
SET @newPersonId = SCOPE_IDENTITY()
INSERT INTO student(term, degree_course_id, person_id, room_id) VALUES
(@term, @degreeCourseId, @newPersonId, (SELECT id FROM @foundRoom))
COMMIT
END TRY
BEGIN CATCH
THROW
ROLLBACK
END CATCH

GO

CREATE PROCEDURE addAnnouncement(
@content text = NULL,
@id SMALLINT = NULL
)
AS
IF NOT EXISTS(SELECT aws.id FROM administration_workers aws WHERE aws.id=@id) THROW 51000, 'Please enter a valid id', 1; 
INSERT INTO announcement(date, content, administration_worker_id) VALUES(
	GETDATE(), @content, @id
)
GO

CREATE PROCEDURE addIssue(
@content text = NULL,
@doorkeeperId SMALLINT = NULL,
@pesel CHAR(11) = NULL
)
AS
IF NOT EXISTS(SELECT s.PESEL FROM students s WHERE s.PESEL=@pesel) THROW 51000, 'Invalid PESEL', 1; 
IF NOT EXISTS(SELECT d.id FROM doorkeepers d WHERE d.id=@doorkeeperId) THROW 51000, 'Please enter a valid id', 1; 
INSERT INTO issue(date, content, student_id, doorkeeper_id) VALUES (
	GETDATE(), @content, (SELECT s.id FROM students s WHERE s.pesel=@pesel), @doorkeeperId
)
GO

EXEC addIssue @content=N'³obuziak', @doorkeeperId=1, @pesel='03261725835'


EXEC addAnnouncement @content='Testowe ogloszenie', @id=1


EXEC addNewStudent 
@firstName='Adam',
@lastName='Adamiak',
@pesel='99034502199',
@street='Kwiatowa',
@flat=13,
@term=5,
@zip='02-031',
@city='Radom',
@country='Polska',
@university='Politechnika Warszawska',
@department=N'Wydzia³ Elektryczny',
@degreeCourse='Informatyka',
@room=101,
@dormitory='Dom Studencki Bratniak-Muszelka'





