DROP FUNCTION StudentDataByPesel
GO
DROP FUNCTION NonFullRooms
GO


CREATE FUNCTION StudentDataByPesel (@pesel CHAR(11))
RETURNS TABLE
AS
RETURN
(
SELECT * FROM students s WHERE s.PESEL=@pesel
)
GO

CREATE FUNCTION NonFullRooms(@dormitoryName VARCHAR(100))
RETURNS TABLE
AS
RETURN
(
SELECT *, (r.capacity - r.Locators) as 'Available spots'
FROM rooms r WHERE r.name LIKE '%' + @dormitoryName + '%' AND r.capacity > r.Locators
)
GO

SELECT * FROM StudentDataByPesel('95050859964')
SELECT * FROM NonFullRooms('Bratniak')

