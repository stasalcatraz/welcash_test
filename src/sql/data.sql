delete from bugtracker.tbl_issues;
/
drop sequence bugtracker.seq_issues;
create sequence bugtracker.seq_issues start with 6;
drop sequence bugtracker.seq_issue_movements;
create sequence bugtracker.seq_issue_movements start with 19;
/
alter table bugtracker.tbl_issues disable constraint fk_issues_last_mv_id;
/
insert into bugtracker.tbl_issues (id, description, planned_time, last_movement_id) values (1, 'test bug 1', 8, 1);
insert into bugtracker.tbl_issues (id, description, planned_time, last_movement_id) values (2, 'test bug 2', 8, 6);
insert into bugtracker.tbl_issues (id, description, planned_time, last_movement_id) values (3, 'test bug 3', 8, 9);
insert into bugtracker.tbl_issues (id, description, planned_time, last_movement_id) values (4, 'test bug 4', 8, 13);
insert into bugtracker.tbl_issues (id, description, planned_time, last_movement_id) values (5, 'test bug 5', 8, 18);
/
alter table bugtracker.tbl_issue_movements disable constraint fk_issue_mvmnts_next_mvmnt_id;
/
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (1, 1, 1, to_date('2016-08-01 09:30:00', 'YYYY-MM-DD HH24:MI:SS'), null);

insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (2, 2, 1, to_date('2016-08-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (3, 2, 2, to_date('2016-08-03 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (4, 2, 3, to_date('2016-08-04 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (5, 2, 4, to_date('2016-08-05 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (6, 2, 5, to_date('2016-08-05 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), null);

insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (7, 3, 1, to_date('2016-08-03 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 8);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (8, 3, 2, to_date('2016-08-04 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 9);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (9, 3, 3, to_date('2016-08-05 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), null);

insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (10, 4, 1, to_date('2016-08-04 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 11);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (11, 4, 2, to_date('2016-08-04 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 12);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (12, 4, 3, to_date('2016-08-05 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 13);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (13, 4, 4, to_date('2016-08-05 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), null);

insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (14, 5, 1, to_date('2016-08-05 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 15);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (15, 5, 2, to_date('2016-08-05 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 16);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (16, 5, 3, to_date('2016-08-05 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 17);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (17, 5, 4, to_date('2016-08-05 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 18);
insert into bugtracker.tbl_issue_movements (id, issue_id, status_id, movement_date, next_movement_id) values (18, 5, 5, to_date('2016-08-05 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), null);
/
alter table bugtracker.tbl_issues enable constraint fk_issues_last_mv_id;
alter table bugtracker.tbl_issue_movements enable constraint fk_issue_mvmnts_next_mvmnt_id;

/*
update bugtracker.tbl_issues i set i.last_movement_id = (
  select max(m.id) from bugtracker.tbl_issue_movements m where m.issue_id = i.id and rownum=1 and m.movement_date = (
    select max(mm.movement_date) from bugtracker.tbl_issue_movements mm where mm.issue_id = i.id
  )
);

update bugtracker.tbl_issue_movements im set im.next_movement_id = (
  select min(im1.id) from bugtracker.tbl_issue_movements im1 where im.issue_id = im1.issue_id and im1.movement_date = (
    select min(im2.movement_date) from bugtracker.tbl_issue_movements im2 where im.issue_id = im2.issue_id and im.movement_date < im2.movement_date
  )
);
*/
