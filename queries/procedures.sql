	
DROP PROCEDURE IF EXISTS addNewStudent;
DROP PROCEDURE IF EXISTS addAnnouncement;
DROP PROCEDURE IF EXISTS addIssue;
DROP PROCEDURE IF EXISTS addNewStudent;


CREATE PROCEDURE addNewStudent 
(
	p_firstName varchar(25) DEFAULT NULL,
	p_secondName varchar(25) DEFAULT NULL,
	p_lastName varchar(50) DEFAULT NULL,
	p_pesel char(11) DEFAULT NULL,
	p_street varchar(70) DEFAULT NULL,
	p_flat smallint DEFAULT NULL,
	p_zip varchar(10) DEFAULT NULL,
	p_city varchar(50) DEFAULT NULL,
	p_country varchar(50) DEFAULT NULL,
	p_term smallint DEFAULT NULL,
	p_degreeCourse varchar(100) DEFAULT NULL,
	p_department varchar(100) DEFAULT NULL,
	p_university varchar(150) DEFAULT NULL,
	p_room varchar(10) DEFAULT NULL,
	p_dormitory varchar(100) DEFAULT NULL
)
AS
$$
DECLARE duplicateAddressId INT;
DECLARE degreeCourseId SMALLINT;
DECLARE departmentId SMALLINT;
DECLARE newPersonId INT;
BEGIN 
IF NOT EXISTS (SELECT id FROM university u WHERE u.name=p_university)
THEN
RAISE 'Invalid university name';
ROLLBACK;
END IF;
IF NOT EXISTS (SELECT id FROM department d WHERE d.name=p_department)
THEN
RAISE 'Invalid department name';
ROLLBACK;
END IF;
IF NOT EXISTS (SELECT id FROM degree_course dc WHERE dc.name=p_degreeCourse)
THEN
RAISE 'Invalid degree course name';
ROLLBACK;
END IF;
IF NOT EXISTS (SELECT id FROM dormitory d WHERE d.name=p_dormitory)
THEN
RAISE 'Invalid dormitory name';
ROLLBACK;
END IF;


IF NOT EXISTS (SELECT id FROM address ad WHERE ad.city=p_city AND ad.country=p_country AND ad.flat_number=p_flat AND ad.postcode=p_zip AND ad.street=p_street LIMIT 1)
THEN
INSERT INTO address(street,postcode,city,country, flat_number) VALUES
(p_street, p_zip, p_city, p_country, p_flat) RETURNING id INTO duplicateAddressId;
ELSE
duplicateAddressId := (SELECT id FROM address ad WHERE ad.city=p_city AND ad.country=p_country AND ad.flat_number=p_flat AND ad.postcode=p_zip AND ad.street=p_street LIMIT 1);
END IF;

degreeCourseId := (SELECT dc.id FROM degree_course dc INNER JOIN department d ON d.id=dc.department_id WHERE d.name=p_department AND dc.name=p_degreeCourse);
IF degreeCourseId = NULL THEN
RAISE 'Degree course not found for provided department';
ROLLBACK;
END IF;
departmentId := (SELECT d.id FROM department d INNER JOIN university u  ON u.id=d.university_id WHERE u.name=p_university AND d.name=p_department);
IF departmentId = NULL THEN
RAISE 'Department not found for provided university';
ROLLBACK;
END IF;
CREATE TEMP TABLE  foundRoom (id INT, capacity smallint, locators INT) ON COMMIT DROP ;
INSERT INTO foundRoom select r.id, r.capacity, r.locators FROM rooms r WHERE r.number=p_room AND r.dormitory=p_dormitory;
IF NOT EXISTS (SELECT id FROM foundRoom) THEN
RAISE 'No room with provided number found in chosen dormitory';
ROLLBACK;
END IF;
IF EXISTS (SELECT * FROM foundRoom WHERE capacity=locators) THEN
RAISE 'This room is already full';
ROLLBACK;
END IF;
INSERT INTO person(first_name, second_name, last_name, pesel, address_id) VALUES
(p_firstName, p_secondName, p_lastName, p_pesel, duplicateAddressId) RETURNING id INTO newPersonId;
INSERT INTO student(term, degree_course_id, person_id, room_id) VALUES
(p_term, degreeCourseId, newPersonId, (SELECT id FROM foundRoom));
COMMIT;
END;
$$
LANGUAGE plpgsql;



CREATE PROCEDURE addAnnouncement(
content text DEFAULT NULL,
administrator_id SMALLINT DEFAULT NULL
)
AS 
$$
BEGIN
IF NOT EXISTS (SELECT aws.id FROM administration_workers aws WHERE aws.id=administrator_id) THEN
RAISE 'Please enter a valid administration_worker_id'; 
END IF;
INSERT INTO announcement(date, content, administration_worker_id) VALUES(
	CURRENT_TIMESTAMP, content, administrator_id
);
END;
$$
LANGUAGE plpgsql;




CREATE PROCEDURE addIssue(
content text DEFAULT NULL,
doorkeeperId SMALLINT DEFAULT NULL,
pesel CHAR(11) DEFAULT NULL
)
AS
$$
BEGIN
IF NOT EXISTS(SELECT s."PESEL" FROM students s WHERE s."PESEL"=pesel)
THEN RAISE 'Invalid PESEL';
END IF;
IF NOT EXISTS(SELECT d.id FROM doorkeepers d WHERE d.id=doorkeeperId)
THEN RAISE 'Please enter a valid doorkeeper_id';
END IF;

INSERT INTO issue(date, content, student_id, doorkeeper_id) VALUES (
	CURRENT_TIMESTAMP, content, (SELECT s.id FROM students s WHERE s."PESEL"=pesel), doorkeeperId
);
END;
$$
LANGUAGE plpgsql;

CALL addNewStudent(
p_firstName => 'Adam',
p_lastName =>'Adamiak',
p_pesel => '99634502199',
p_street => 'Kwiatowa',
p_flat => 13::smallint,
p_term => 5::smallint,
p_zip => '02-031',
p_city => 'Radom',
p_country => 'Polska',
p_university => 'Politechnika Warszawska',
p_department => 'Wydział Elektryczny',
p_degreeCourse => 'Informatyka',
p_room => '264',
p_dormitory =>'Dom Studencki Bratniak-Muszelka'
);







