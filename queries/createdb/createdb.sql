USE dormitory



IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[announcement]') AND type in (N'U'))
DROP TABLE [dbo].[announcement]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[issue]') AND type in (N'U'))
DROP TABLE [dbo].[issue]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[accomodation]') AND type in (N'U'))
DROP TABLE [dbo].[accomodation]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[administration_worker]') AND type in (N'U'))
DROP TABLE [dbo].[administration_worker]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[doorkeeper]') AND type in (N'U'))
DROP TABLE [dbo].[doorkeeper]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[payment]') AND type in (N'U'))
DROP TABLE [dbo].[payment]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[student]') AND type in (N'U'))
DROP TABLE [dbo].[student]
GO



IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[person]') AND type in (N'U'))
DROP TABLE [dbo].[person]
GO


IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[room]') AND type in (N'U'))
DROP TABLE [dbo].[room]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[dormitory_administration_schedule]') AND type in (N'U'))
DROP TABLE [dbo].[dormitory_administration_schedule]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[dormitory]') AND type in (N'U'))
DROP TABLE [dbo].[dormitory]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[administration_schedule]') AND type in (N'U'))
DROP TABLE [dbo].[administration_schedule]
GO



IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[working_day]') AND type in (N'U'))
DROP TABLE [dbo].[working_day]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[price_list]') AND type in (N'U'))
DROP TABLE [dbo].[price_list]
GO


IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[degree_course]') AND type in (N'U'))
DROP TABLE [dbo].[degree_course]
GO



IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[department]') AND type in (N'U'))
DROP TABLE [dbo].[department]
GO



IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[university]') AND type in (N'U'))
DROP TABLE [dbo].[university]
GO

IF  EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[address]') AND type in (N'U'))
DROP TABLE [dbo].[address]
GO


CREATE TABLE address
(
    id INT PRIMARY KEY IDENTITY(1, 1),
    street VARCHAR(70) UNIQUE NOT NULL,
    flat_number TINYINT,
    postcode VARCHAR(10) NOT NULL,
    city varchar(50) NOT NULL,
    country varchar(50) NOT NULL
)


CREATE TABLE university
(
    id SMALLINT PRIMARY KEY IDENTITY(1, 1),
    name VARCHAR(150) NOT NULL UNIQUE,
    address_id INT FOREIGN KEY REFERENCES address(id) UNIQUE  NOT NULL
)

CREATE TABLE working_day
(
    id TINYINT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(20) NOT NULL UNIQUE
)

CREATE TABLE administration_schedule
(
     id SMALLINT PRIMARY KEY IDENTITY(1,1),
     working_day_id TINYINT FOREIGN KEY REFERENCES working_day(id) NOT NULL,
     start_hour TIME NOT NULL,
     end_hour TIME NOT NULL
)



CREATE TABLE price_list
(
    id SMALLINT PRIMARY KEY IDENTITY(1, 1),
    single DECIMAL(6, 2),
    doubled DECIMAL(6, 2),
    tripled DECIMAL(6, 2),
    quadrupled DECIMAL(6, 2),
    five DECIMAL(6, 2)
)

CREATE TABLE dormitory
(
    id SMALLINT PRIMARY KEY IDENTITY(1, 1),
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address_id INT FOREIGN KEY REFERENCES address(id) UNIQUE NOT NULL,
    university_id SMALLINT FOREIGN KEY REFERENCES university(id) NOT NULL,
    price_list_id SMALLINT FOREIGN KEY REFERENCES price_list(id) NOT NULL,
    user_id SMALLINT NOT NULL
)

CREATE TABLE dormitory_administration_schedule
(
    id SMALLINT PRIMARY KEY IDENTITY(1,1),
    dormitory_id SMALLINT NOT NULL FOREIGN KEY REFERENCES dormitory(id),
    administration_schedule_id SMALLINT FOREIGN KEY REFERENCES administration_schedule(id) NOT NULL
)



CREATE TABLE department
(
    id SMALLINT PRIMARY KEY IDENTITY(1, 1),
    name VARCHAR(100) NOT NULL UNIQUE,
    university_id SMALLINT FOREIGN KEY REFERENCES university(id) NOT NULL,
)

CREATE TABLE degree_course
(
    id SMALLINT PRIMARY KEY IDENTITY(1, 1),
    name VARCHAR(100) NOT NULL UNIQUE,
    department_id SMALLINT FOREIGN KEY REFERENCES department(id) NOT NULL,
)



CREATE TABLE person
(
    id INT PRIMARY KEY IDENTITY(1, 1),
    first_name VARCHAR(25) NOT NULL,
    second_name VARCHAR(25),
    last_name VARCHAR(50) NOT NULL,
    pesel CHAR(11) UNIQUE NOT NULL,
    address_id INT FOREIGN KEY REFERENCES address(id) NOT NULL
)



CREATE TABLE room
(
    id INT PRIMARY KEY IDENTITY(1, 1),
    number varchar(10) NOT NULL,
    capacity TINYINT NOT NULL CHECK (capacity BETWEEN 1 and 5),
    dormitory_id SMALLINT NOT NULL FOREIGN KEY REFERENCES dormitory(id)
)


CREATE TABLE student
(
    id INT PRIMARY KEY IDENTITY(1, 1),
    term TINYINT NOT NULL CHECK (term BETWEEN 1 AND 7),
    degree_course_id SMALLINT FOREIGN KEY REFERENCES degree_course(id) NOT NULL,
    person_id INT FOREIGN KEY REFERENCES person(id) UNIQUE NOT NULL,
    room_id INT FOREIGN KEY REFERENCES room(id) NOT NULL
   
)


CREATE TABLE payment
(
 id INT PRIMARY KEY IDENTITY(1, 1),
 date SMALLDATETIME NOT NULL,
 student_id INT FOREIGN KEY REFERENCES student(id) NOT NULL,
 amount DECIMAL(6, 2) NOT NULL
)


CREATE TABLE doorkeeper
(
    id SMALLINT PRIMARY KEY IDENTITY(1, 1),
    dormitory_id SMALLINT FOREIGN KEY REFERENCES dormitory(id) NOT NULL,
    person_id INT UNIQUE FOREIGN KEY REFERENCES person(id) NOT NULL,
)

CREATE TABLE accomodation
(
    id INT PRIMARY KEY IDENTITY(1, 1),
    start_date SMALLDATETIME NOT NULL,
    end_date SMALLDATETIME NOT NULL,
    student_id INT FOREIGN KEY REFERENCES student(id) NOT NULL,
    person_id INT FOREIGN KEY REFERENCES person(id) NOT NULL,
    doorkeeper_id SMALLINT FOREIGN KEY REFERENCES doorkeeper(id) NOT NULL
)

CREATE TABLE issue
(
    id SMALLINT PRIMARY KEY IDENTITY(1, 1),
    date SMALLDATETIME NOT NULL,
    content text NOT NULL,
    student_id INT FOREIGN KEY REFERENCES student(id) NOT NULL,
    doorkeeper_id SMALLINT FOREIGN KEY REFERENCES doorkeeper(id) NOT NULL
)

CREATE TABLE administration_worker
(
    id SMALLINT PRIMARY KEY IDENTITY(1, 1),
    email VARCHAR(50) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    dormitory_id SMALLINT FOREIGN KEY REFERENCES dormitory(id) NOT NULL,
    person_id INT UNIQUE FOREIGN KEY REFERENCES person(id) NOT NULL,
)

CREATE TABLE announcement
(
    id INT PRIMARY KEY IDENTITY(1, 1),
    date SMALLDATETIME NOT NULL,
    content TEXT NOT NULL,
    administration_worker_id SMALLINT FOREIGN KEY REFERENCES administration_worker(id) NOT NULL
)

















