drop view if exists vw_work_days;

drop table if exists tbl_issue_movements;

drop table if exists tbl_issues;

drop table if exists tbl_status_movements;

drop table if exists tbl_statuses;;


create table tbl_statuses (
  id      integer primary key not null,
  name    varchar(64) not null,
  in_work integer not null
);;

create table tbl_status_movements (
  id          integer primary key not null,
  status_from integer not null,
  status_to   integer not null,
  foreign key (status_from) references tbl_statuses(id) on delete restrict on update cascade,
  foreign key (status_to) references tbl_statuses(id) on delete restrict on update cascade
);;

create table tbl_issues (
  id               integer primary key autoincrement not null,
  description      text not null,
  planned_time     float not null,
  last_movement_id integer,
  foreign key (last_movement_id) references tbl_issue_movements(id)
);

drop trigger if exists tbl_issue_ai;

create trigger tbl_issue_ai after insert on tbl_issues for each row
begin
  insert into tbl_issue_movements (
    issue_id,
    status_id
  ) values (
    last_insert_rowid(),
    1
  );
end;;

create table tbl_issue_movements (
  id               integer primary key not null,
  issue_id         integer not null,
  status_id        integer not null,
  movement_date    timestamp default current_timestamp,
  next_movement_id integer null,
  foreign key (issue_id) references tbl_issues(id) on delete cascade on update cascade,
  foreign key (status_id) references tbl_statuses(id) on delete restrict on update cascade,
  foreign key (next_movement_id) references tbl_issue_movements(id) on delete set null on update cascade
);;

drop trigger if exists tbl_issue_movements_ai;

create trigger tbl_issue_movements_ai after insert on tbl_issue_movements for each row
begin
  update
    tbl_issues
  set
    last_movement_id = last_insert_rowid()
  where
    id = new.issue_id;
  update
    tbl_issue_movements 
  set
    next_movement_id = last_insert_rowid()
  where
    issue_id = new.issue_id
    and movement_date = (
      select
        max(pr.movement_date)
      from
        tbl_issue_movements pr
      where
        pr.issue_id = new.issue_id
        and pr.id <> last_insert_rowid()
    );
end;;

insert into tbl_statuses (id, name, in_work) values (1, 'У черзі', 0);
insert into tbl_statuses (id, name, in_work) values (2, 'Узгодження ТЗ', 1);
insert into tbl_statuses (id, name, in_work) values (3, 'У роботі', 1);
insert into tbl_statuses (id, name, in_work) values (4, 'У тестуванні', 0);
insert into tbl_statuses (id, name, in_work) values (5, 'Готово', 0);;

insert into tbl_status_movements (id, status_from, status_to) values (1, 1, 2);
insert into tbl_status_movements (id, status_from, status_to) values (2, 2, 3);
insert into tbl_status_movements (id, status_from, status_to) values (3, 3, 4);
insert into tbl_status_movements (id, status_from, status_to) values (4, 4, 3);
insert into tbl_status_movements (id, status_from, status_to) values (5, 4, 5);;


/*
  Выбирает рабочие периоды за 1000 дней до текущего. Рабочими считаются дни с понедельника по пятницу с 9:00 по 13:00 и с 14:00 по 18:00.
*/
create view vw_work_days as
select
  datetime(days.date, hours.begin) as begin,
  datetime(days.date, hours.end) as end
  ,strftime('%w', days.date) as weekday
from
  (
select 
  date('now', cast(-a.a - 10 * b.a - 100 * c.a as text) || ' days') as date
from 
  (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) a
  cross join (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as b
  cross join (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as c
where strftime('%w', date('now', cast(-a.a - 10 * b.a - 100 * c.a as text) || ' days')) between '1' and '5'
  ) days
  cross join (select time('09:00') as begin, time('13:00') as end union all select time('14:00'), time('18:00')) hours;;

drop view if exists vw_issues;

create view vw_issues as
select
  i.id,
  i.description,
  im.status_id,
  s.name as status,
  i.planned_time,
  (
    select sum(actual_time) from (
      select
        ((
            select
            sum(julianday(min(end, ifnull(imn.movement_date, datetime('now')))) - julianday(max(begin, im1.movement_date) )) * 24
            from
            vw_work_days w
            where
            w.end > im1.movement_date
            and w.begin < ifnull(imn.movement_date, datetime('now'))
        ) * s.in_work) as actual_time
      from
        tbl_issue_movements im1
        inner join tbl_statuses s on im1.status_id = s.id
        left join tbl_issue_movements imn on im1.next_movement_id = imn.id
      where
        im1.issue_id = i.id
    )
  ) as actual_time
from
  tbl_issues i
  inner join tbl_issue_movements im on i.last_movement_id = im.id
  inner join tbl_statuses s on im.status_id = s.id;;

drop view if exists vw_issue_movements;
  
create view vw_issue_movements as
select
  im.id,
  im.issue_id,
  im.movement_date,
  s.name as status,
  ifnull((
    select
      sum(julianday(min(end, ifnull(imn.movement_date, datetime('now')))) - julianday(max(begin, im.movement_date) )) * 24
    from
      vw_work_days w
    where
      w.end > im.movement_date
      and w.begin < ifnull(imn.movement_date, datetime('now'))
  ), 0) as actual_time
from
  tbl_issue_movements im
  inner join tbl_statuses s on im.status_id = s.id
  left join tbl_issue_movements imn on im.next_movement_id = imn.id;;
