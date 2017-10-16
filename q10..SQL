-- A1 report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q10;

-- You must not change this table definition.
CREATE TABLE q10 (
	group_id integer,
	mark real,
	compared_to_average real,
	status varchar(5)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS A1Rubric CASCADE;
DROP VIEW IF EXISTS TotalA1 CASCADE;
DROP VIEW IF EXISTS A1Avg CASCADE;
DROP VIEW IF EXISTS Result0 CASCADE;
DROP VIEW IF EXISTS Result1 CASCADE;
DROP VIEW IF EXISTS Result2 CASCADE;
DROP VIEW IF EXISTS Result3 CASCADE;

-- Define views for your intermediate steps here.

Create view A1Rubric(each, rubric_id) as select (out_of * weight), rubric_id from RubricItem, Assignment 
where RubricItem.assignment_id = Assignment.assignment_id and description = 'A1';

Create view TotalA1 (A1sum) as select sum(each) from A1Rubric;

Create view A1Avg (A1avg) as select avg(mark) from Result full  natural join AssignmentGroup full natural join Assignment where description = 'A1';

Create view Result0 (group_id, mark, compared) as 
select Result.group_id, (mark / A1sum) * 100, (mark - A1sum) * 100, from Result natural join AssignmentGroup natural join Assignment natural join A1Avg where description = 'A1';

Create view Result1 (group_id, mark, compared_to_average, status) as select group_id, mark , compare,'above' from Result0 where compare > 0;

Create view Result2 (group_id, mark, compared_to_average, status) as select group_id, mark , compare,'at' from Result0 where compare = 0;

Create view Result3 (group_id, mark, compared_to_average, status) as select group_id, mark , compare,'below' from Result0 where compare < 0;

-- Final answer.
INSERT INTO q10 select * from ((select * from Result1) union (select * from Result2) union (select * from Result3));

	-- put a final query here so that its results will go into the table.
