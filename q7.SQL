-- High coverage

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q7;

-- You must not change this table definition.
CREATE TABLE q7 (
	ta varchar(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS ShouldGradeAllAssign CASCADE;
DROP VIEW IF EXISTS Reality1 CASCADE;
DROP VIEW IF EXISTS NotGradeAll CASCADE;
DROP VIEW IF EXISTS GradeAllAssign CASCADE;
DROP VIEW IF EXISTS ShouldGradeAllStud CASCADE;
DROP VIEW IF EXISTS Reality2 CASCADE;
DROP VIEW IF EXISTS NotGradeAllStud CASCADE;
DROP VIEW IF EXISTS GradeAllStud CASCADE;

-- Define views for your intermediate steps here. 

Create view ShouldGradeAllAssign (username, assignment_id) as 
Select username, assignment_id 
From Assignment, MarkusUser 
Where type = 'instructor' or type = 'TA';

Create view Reality1 (username, assignment_id) as 
Select username, assignment_id From Grader natural join AssignmentGroup;

Create view notGradeAll as ((select * from ShouldGradeAllAssign) Except All (select * from Reality1));

Create view GradeAllAssign (ta) as 
Select distinct username From ((select * from ShouldGradeAllAssign) Except All (select * from NotGradeAll));

Create view ShouldGradeAllStud(ta, stud) as 
Select M1.username as ta, M2.username as stud 
From MarkusUser M1, MarkusUser M2 
Where M1.type = 'instructor' or M1.type = 'TA' and M2.type = 'student';

Create view Reality2 (ta, stud) as 
Select Grader.username as ta, Membership.username as stud From Grader join Membership on Grader.group_id = Memberhsip.group_id;

Create view notGradeAllStud as ((select * from ShouldGradeAllStud) Except All (select * from Reality2));

Create view GradeAllStud as 
Select distinct ta From ((select * from ShouldGradeAllStud) Except All (select * from NotGradeAllStud));



-- Final answer.
INSERT INTO q7 (Select * from (GradeAllAssign union GradeAllStud));
	-- put a final query here so that its results will go into the table.