DROP FUNCTION IF EXISTS NonFullRooms; 
DROP FUNCTION IF EXISTS StudentDataByPesel;

CREATE OR REPLACE FUNCTION StudentDataByPesel (pesel CHAR(11))
RETURNS SETOF students
AS
$$
BEGIN
RETURN QUERY(SELECT * FROM students s WHERE s."PESEL"=pesel);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION NonFullRooms(dormitoryName VARCHAR(100))
RETURNS TABLE (
	id INT,
	number VARCHAR(10),
	capacity SMALLINT,
	dormitory VARCHAR(100),
	locators BIGINT,
	"available spots" BIGINT
)
AS
$$
BEGIN
RETURN QUERY(SELECT *, (r."capacity" - r."locators")
FROM rooms r WHERE r."dormitory" LIKE ('%' || dormitoryName || '%') AND r."capacity" > r."locators")
;
END;
$$
LANGUAGE plpgsql;

SELECT * FROM StudentDataByPesel('95050859964');
SELECT * FROM NonFullRooms('Bratniak')

