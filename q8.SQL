-- Never solo by choice

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q8;

-- You must not change this table definition.
CREATE TABLE q8 (
	username varchar(25),
	group_average real,
	solo_average real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS SoloGroup CASCADE;
DROP VIEW IF EXISTS NeverWorkedSolo CASCADE;
DROP VIEW IF EXISTS ShouldSubmitEvery CASCADE;
DROP VIEW IF EXISTS AllSubmitted CASCADE;
DROP VIEW IF EXISTS NotEvery CASCADE;
DROP VIEW IF EXISTS SubmittedEvery CASCADE;
DROP VIEW IF EXISTS AvgInGroup CASCADE;
DROP VIEW IF EXISTS SoloAvg CASCADE;




-- Define views for your intermediate steps here.
Create view SoloGroup as select group_id, assignment_id 
From Assignment full natural join AssignmentGroup full natural join Membership where group_max > 1
Group by group_id, assignment_id Having count(username) = 1;

Create view NeverWorkedSolo as select * from ((select username from MarkusUser where type='student') except (select username from Membership, SoloGroup where Membership.group_id = SoloGroup.group_id));

Create view ShouldSubmitEvery (username, assignment_id) as 
select NeverWorkedSolo.username, assignment_id
From NeverWorkedSolo, Assignment;

Create view AllSubmitted (username, assignment_id) as 
Select distinct username, Assignment.assignment_id 
From Submissions natural join AssignmentGroup natural join Assignment;

Create view NotEvery as select * from ((Select * from ShouldSubmitEvery) except all (select * from AllSubmitted));

Create view SubmittedEvery as select * from ((Select * from NeverWorkedSolo) except (select username from NotEvery));

Create view AvgInGroup (username, group_average) as 
select username, avg(mark) from Assignment natural join Assignment Group natural join Membership natural join Result natural join SubmittedEvery where group_max > 1 group by username;

Create view SoloAvg (username, solo_average) as 
select username, avg(mark) from Assignment natural join Assignment Group natural join Membership natural join Result natural join SubmittedEvery where group_max = 1 group by username;


-- Final answer.
INSERT INTO q8 select AvgInGroup.username, group_average, solo_average from AvgInGroup, SoloAvg where AvgInGroup.username = SoloAvg.username;

	-- put a final query here so that its results will go into the table.