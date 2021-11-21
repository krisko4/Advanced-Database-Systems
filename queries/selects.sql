select person.first_name, person.last_name, person.pesel, room.number as 'Room number', room.capacity as  'Room capacity', dormitory.name as 'Dormitory name' from student 
inner join room on room.id = room_id
 inner join dormitory on dormitory.id = room.dormitory_id
 inner join person on person.id = person_id where room_id in (
    select id from room where capacity = 2 
) order by dormitory.name ASC


select count(room.id) as 'Issues', dormitory.name as 'Dormitory name' from issue 
inner join student on student.id=student_id
 inner join room on room.id=student.room_id
 inner join dormitory on dormitory.id=room.dormitory_id
 where year(date) = '2021'
 group by dormitory.name

