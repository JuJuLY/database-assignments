-- Steady work

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q6;

-- You must not change this table definition.
CREATE TABLE q6 (
	group_id integer,
	first_file varchar(25),
	first_time timestamp,
	first_submitter varchar(25),
	last_file varchar(25),
	last_time timestamp, 
	last_submitter varchar(25),
	elapsed_time interval
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS A1GroupSub CASCADE;
DROP VIEW IF EXISTS FirstSubmit CASCADE;
DROP VIEW IF EXISTS LastSubmit CASCADE;

-- Define views for your intermediate steps here.


Create view A1GroupSub as 
Select group_id, file_name, submission_date, username, first_submitter 
From Assignment, AssignmentGroup, Submissions 
Where description = 'A1' and Assignment.assignment_id = AssignmentGroup.assignment_id and Submissions.group_id = AssignmentGroup.group_id);

Create View FirstSubmit (group_id, first_file, first_time, first_submitter) as 
Select A1.group_id, A1.file_name, A1.submission_date, A1.username 
From A1GroupSub A1, (Select group_id, min(submission_date) as submission_date From A1GroupSub Group by group_id) A2 
Where A1.group_id = A2.group_id and A1.submission_date = A2.submission_date;

Create view LastSubmit (group_id, last_file, last_time, last_submitter) as 
Select A3.group_id, A3.file_name, A3.submission_date, A3.username 
From A1GroupSub A3, (Select group_id, max(submission_date) as submission_date From A1GroupSub Group by group_id) A4 
Where A3.group_id = A4.group_id and A3.submission_date = A4.submission_date;


-- Final answer.
INSERT INTO q6 ( 
Select FirstSubmit.group_id, first_file, first_time, first_submitter, last_file, last_time, last_submitter, (last_time - first_time) as elapsed_time 
From FirstSubmit, LastSubmit 
Where FirstSubmit.group_id = LastSubmit.group_id) ;


	-- put a final query here so that its results will go into the table.