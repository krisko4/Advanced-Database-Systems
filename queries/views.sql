DROP VIEW dormitories
DROP VIEW rooms
DROP VIEW students
DROP VIEW issues
DROP VIEW payments
DROP VIEW administration_workers
DROP VIEW doorkeepers
DROP VIEW announcements
GO

CREATE VIEW dormitories
AS
  SELECT d.name as "Dormitory name", d.phone_number as "Phone number", u.name as "University name", a.city as "City", a.street as "Street", a.postcode as "ZIP", w.name as "Day", s.start_hour as "Start hour", s.end_hour as "End hour"
  from dormitory d
    inner join university u on u.id = d.university_id
    inner join address a on a.id=d.address_id
    inner join dormitory_administration_schedule das on das.dormitory_id = d.id
    inner join administration_schedule s on s.id = das.administration_schedule_id
    inner join working_day w on s.working_day_id = w.id
GO


CREATE VIEW rooms
AS
  select r.number, r.capacity, dorm.name, count(s.room_id) as "Locators"
  from room r
    inner join dormitory dorm on dorm.id=r.dormitory_id
    inner join student s on s.room_id=r.id
  group by s.room_id, r.number, r.capacity, dorm.name
GO

CREATE VIEW students
AS
  select
    p.id, 
    p.first_name as "First name",
    p.last_name as "Last name",
    p.pesel as "PESEL",
    a.street as "Street",
    a.flat_number as "Flat number",
    a.postcode as "ZIP",
    a.country as "Country",
    s.term as "Term",
    d.name as "Department",
    u.name as "University",
    r.number as "Room number",
    dorm.name as "Dormitory"

  from student s
    join degree_course dc on s.degree_course_id=dc.id
    join department d on dc.department_id=d.id
    join university u on d.university_id=u.id
    join person p on p.id=s.person_id
    join address a on a.id = p.address_id
    join room r on r.id=s.room_id
    join dormitory dorm on r.dormitory_id=dorm.id

GO


CREATE VIEW doorkeepers
AS
  select
	d.id,
    p.first_name as "First name",
    p.last_name as "Last name",
    p.pesel as "PESEL",
    a.street as "Street",
    a.flat_number as "Flat number",
    a.postcode as "ZIP",
    a.country as "Country",
    dorm.name as "Dormitory"
  from doorkeeper d
    inner join person p on p.id=d.person_id
    inner join dormitory dorm on d.dormitory_id=dorm.id
    inner join address a on a.id=p.address_id
     
     GO

CREATE VIEW administration_workers
AS select aw.id, p.first_name, p.last_name, aw.email, aw.phone_number, d.name as "dormitory"
 from administration_worker aw
  INNER JOIN dormitory d on aw.dormitory_id=d.id
   inner join person p on aw.person_id=p.id


GO

CREATE VIEW issues
AS
  select i.date, i.content, p1.first_name as "student first name", p1.last_name as "student last name", r.number as "room number", p2.first_name as "doorkeeper first name", p2.last_name as "doorkeeper last name"
  from issue i inner join student s on s.id=i.student_id
  inner join doorkeeper d on d.id=i.doorkeeper_id
  inner join room r on s.room_id=r.id
  inner join person p1 on s.person_id=p1.id
  inner join person p2 on d.person_id=p2.id

GO

CREATE VIEW announcements
AS
select a.date, a.content, p.first_name, p.last_name, aw.email, aw.phone_number, d.name from announcement a 
inner join administration_worker aw on a.administration_worker_id=aw.id
inner join person p on aw.person_id = p.id
inner join dormitory d on d.id=aw.dormitory_id
GO

CREATE VIEW payments
AS
SELECT p.date, p.amount, s.*  FROM payment p INNER JOIN students s ON s.id = p.student_id
Go


select * from doorkeepers
select*  from issues
select * from students
select * from dormitories
select * from rooms
select * from administration_workers
select * from announcements
select * from payments

