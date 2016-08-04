delete from tbl_issues;

delete from sqlite_sequence where name = 'tbl_issues'; -- reset autoincrement

insert into tbl_issues (id, description, planned_time) values (1, 'test bug 1', 8);
insert into tbl_issues (id, description, planned_time) values (2, 'test bug 2', 8);
insert into tbl_issues (id, description, planned_time) values (3, 'test bug 3', 8);
insert into tbl_issues (id, description, planned_time) values (4, 'test bug 4', 8);
insert into tbl_issues (id, description, planned_time) values (5, 'test bug 5', 8);

delete from tbl_issue_movements;

insert into tbl_issue_movements (issue_id, status_id, movement_date) values (1, 1, '2016-05-02 09:30:00');

insert into tbl_issue_movements (issue_id, status_id, movement_date) values (2, 1, '2016-05-03 10:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (2, 2, '2016-05-10 15:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (2, 3, '2016-05-10 16:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (2, 4, '2016-05-10 17:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (2, 5, '2016-05-10 18:00:00');

insert into tbl_issue_movements (issue_id, status_id, movement_date) values (3, 1, '2016-05-05 11:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (3, 2, '2016-05-08 12:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (3, 3, '2016-05-12 13:00:00');

insert into tbl_issue_movements (issue_id, status_id, movement_date) values (4, 1, '2016-05-06 11:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (4, 2, '2016-05-13 12:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (4, 3, '2016-05-15 13:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (4, 4, '2016-05-17 15:00:00');

insert into tbl_issue_movements (issue_id, status_id, movement_date) values (5, 1, '2016-05-11 11:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (5, 2, '2016-05-12 12:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (5, 3, '2016-05-14 13:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (5, 4, '2016-05-15 15:00:00');
insert into tbl_issue_movements (issue_id, status_id, movement_date) values (5, 5, '2016-05-18 16:00:00');

