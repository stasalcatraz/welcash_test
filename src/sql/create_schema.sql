/* Execute with SYSDBA privileges */
/* Удаляем предыдущую версию схемы, пользователя и роли */
--drop user bugtracker cascade;
--drop user bt_user cascade;
--drop role bugtracker_user;
/* Создание схемы */
create user bugtracker identified by bugtracker quota unlimited on USERS;
/
/* Создание объектов схемы */

/*
  Таблица tbl_statuses - состояния, в которых может находиться задача.
  Словарь состояний не изменяется в программе, 
  редактируется только администратором БД.
*/
create table bugtracker.tbl_statuses (
  id      number(19) primary key not null,
  name           varchar2(64) not null,
  in_work        number(19) not null -- Признак нахождение в работе для подсчёта часов. 0 - не учитывается, 1 - учитывается.
);
/
insert into bugtracker.tbl_statuses (id, name, in_work) values (1, 'У черзі', 0);
insert into bugtracker.tbl_statuses (id, name, in_work) values (2, 'Узгодження ТЗ', 1);
insert into bugtracker.tbl_statuses (id, name, in_work) values (3, 'У роботі', 1);
insert into bugtracker.tbl_statuses (id, name, in_work) values (4, 'У тестуванні', 0);
insert into bugtracker.tbl_statuses (id, name, in_work) values (5, 'Готово', 0);
/

/*
  Таблица tbl_status_movements - возможные переходы по состояниям.
  Не изменяется в программе.
*/

create table bugtracker.tbl_status_movements (
  id          number(19) not null constraint pk_status_movements primary key,
  status_from number(19) not null constraint fk_status_mvmnts_status_from references bugtracker.tbl_statuses(id),
  status_to   number(19) not null constraint fk_status_mvmnts_status_to references bugtracker.tbl_statuses(id)
);
/
insert into bugtracker.tbl_status_movements (id, status_from, status_to) values (1, 1, 2); -- В очереди -> Согласование ТЗ
insert into bugtracker.tbl_status_movements (id, status_from, status_to) values (2, 2, 3); -- Согласование ТЗ -> В работе
insert into bugtracker.tbl_status_movements (id, status_from, status_to) values (3, 3, 4); -- В работе -> Тестирование
insert into bugtracker.tbl_status_movements (id, status_from, status_to) values (4, 4, 3); -- Тестирование -> В работе
insert into bugtracker.tbl_status_movements (id, status_from, status_to) values (5, 4, 5); -- Тестирование -> Готово
/

/*
  Таблица tbl_issues - задачи. Добавляются в программе, после записи в базу 
  редактирование и удаление из программы не возможно.
*/
create table bugtracker.tbl_issues (
  id               number(19) not null constraint pk_issues primary key,
  description      varchar2(1000) not null,
  planned_time     float not null,
  last_movement_id number(19)
);
/
/* Триггер на присвоение нового id, если не задан. */
create sequence bugtracker.seq_issues;
/
create or replace trigger bugtracker.tbl_issues_bi before insert on bugtracker.tbl_issues for each row
begin
  if :new.id is null then 
     select seq_issues.nextval into :new.id from dual; 
  end if; 
end;
/
/*
  Таблица tbl_issue_movements - переходы задачи по состояниям. Из программы 
  доступны переходы только в состояния, заданные в таблице tbl_status_movements.
  Время перехода ставится автоматически при записи в базу и из программы не 
  меняется.
*/
create table bugtracker.tbl_issue_movements (
  id               number(19) primary key not null,
  issue_id         number(19) not null constraint fk_issue_mvmnts_issue_id references bugtracker.tbl_issues(id) on delete cascade,
  status_id        number(19) not null constraint fk_issue_mvmnts_status_id references bugtracker.tbl_statuses(id),
  movement_date    timestamp default current_timestamp,
  next_movement_id number(19) null constraint fk_issue_mvmnts_next_mvmnt_id references bugtracker.tbl_issue_movements(id) on delete set null
);
/
alter table bugtracker.tbl_issues add constraint fk_issues_last_mv_id foreign key (last_movement_id) references bugtracker.tbl_issue_movements(id);
/
/* Триггер на присвоение нового id, если не задан. */
create sequence bugtracker.seq_issue_movements;
/
create or replace trigger bugtracker.tbl_issue_movements_bi before insert on bugtracker.tbl_issue_movements for each row
begin
  if :new.id is null then 
     select seq_issue_movements.nextval into :new.id from dual; 
  end if; 
end;
/

/*
  Представление vw_work_days. Выбирает рабочие периоды за 1000 дней до текущего.
  Рабочими считаются дни с понедельника по пятницу с 9:00 по 13:00 и с 14:00 по 
  18:00. Заменяет редактируемый словарик рабочих дней.
*/
create or replace view bugtracker.vw_work_days as
select
  to_date(to_char("days"."date", 'MM-DD-YYYY') || ' ' || hours."begin", 'MM-DD-YYYY HH24:MI') as "begin",
  to_date(to_char("days"."date", 'MM-DD-YYYY') || ' ' || hours."end", 'MM-DD-YYYY HH24:MI') as "end"
from
  (
    select 
      current_date - (c.a + 10 * b.a + 100 * a.a) as "date"
    from 
      (select 0 as a from dual union all select 1 from dual union all select 2 from dual union all select 3 from dual union all select 4 from dual union all select 5 from dual union all select 6 from dual union all select 7 from dual union all select 8 from dual union all select 9 from dual) a
      cross join (select 0 as a from dual union all select 1 from dual union all select 2 from dual union all select 3 from dual union all select 4 from dual union all select 5 from dual union all select 6 from dual union all select 7 from dual union all select 8 from dual union all select 9 from dual) b
      cross join (select 0 as a from dual union all select 1 from dual union all select 2 from dual union all select 3 from dual union all select 4 from dual union all select 5 from dual union all select 6 from dual union all select 7 from dual union all select 8 from dual union all select 9 from dual) c
    where
      to_char(current_date - (c.a + 10 * b.a + 100 * a.a), 'DY', 'nls_date_language=american') in ('MON', 'TUE', 'WED', 'THU', 'FRI')
  ) "days"
  cross join (select '09:00' as "begin", '13:00' as "end" from dual union all select '14:00', '18:00' from dual) hours;
/
/*
  Представление vw_issues. Показывает все задачи, их текущие состояния и время,
  затраченное на каждую задачу. Учитывать время, проведенное в каждом состоянии 
  или нет - определяется признаком in_work в таблице состояний tbl_statuses 
  (1 - учитывать, 0 - не учитывать). Рабочие часы берутся из представления 
  vw_work_days.
*/
create or replace view bugtracker.vw_issues as
select
  i.id,
  i.description,
  im.status_id,
  s.name as status,
  i.planned_time,
  cast(nvl((
    select sum(actual_time) from (
      select
        ((
            select
              sum(least("end", nvl(imn.movement_date, current_date)) - greatest("begin", im1.movement_date))  * 24
            from
              vw_work_days w
            where
              w."end" > im1.movement_date
            and w."begin" < nvl(imn.movement_date, current_date)
        ) * s.in_work) as actual_time
      from
        tbl_issue_movements im1
        left join tbl_statuses s on im1.status_id = s.id
        left join tbl_issue_movements imn on im1.next_movement_id = imn.id
      where
        im1.issue_id = i.id
    )
  ), 0) as float) as actual_time
from
  tbl_issues i
  inner join tbl_issue_movements im on i.last_movement_id = im.id
  inner join tbl_statuses s on im.status_id = s.id;
/
/*
  Представление vw_issue_movements. Движения задач по состояниям и рабочее время,
  в течение которого задачча находилась в каждом состоянии. Рабочие часы берутся 
  из представления vw_work_days.
*/
create or replace view bugtracker.vw_issue_movements as
select
  im.id,
  im.issue_id,
  im.movement_date,
  s.name as status,
  cast(nvl((
    select
      sum(least("end", nvl(imn.movement_date, current_date)) - greatest("begin", im.movement_date)) * 24
    from
      vw_work_days w
    where
      w."end" > im.movement_date
      and w."begin" < nvl(imn.movement_date, current_date)
  ), 0) as float) as actual_time
from
  tbl_issue_movements im
  inner join tbl_statuses s on im.status_id = s.id
  left join tbl_issue_movements imn on im.next_movement_id = imn.id;
/

/* Хранимые процедуры, через которые программа работает с данными. */

/*
  Процедура sp_issues. Выбирает задачи, имеющие состояние, отличное от "Готово" на 
  начало периода, или поменявшие свое состояние в заданный период. Задачи, 
  закрытые до начала периода, или открытые после его окончания в результат не 
  попадают.
*/
create or replace procedure bugtracker.sp_issues(date_from date, date_to date, res out sys_refcursor) as
begin
  open res for
    select
      i.id,
      i.description,
      i.status_id,
      i.status,
      i.planned_time,
      i.actual_time
    from
      vw_issues i
    where
      exists(
        select 1 from tbl_issue_movements im
        where
          issue_id = i.id
          and im.movement_date >= trunc(sp_issues.date_from)
          and im.movement_date < trunc(sp_issues.date_to) + 1
      ) or (select im1.status_id from tbl_issue_movements im1
        where im1.issue_id = i.id and im1.movement_date =
          (select max(im2.movement_date) from tbl_issue_movements im2 where im2.issue_id = i.id
             and im2.movement_date < trunc(sp_issues.date_from) and rownum = 1)
         ) < 5
    order by i.id;
end;
/
/*
  Процедура sp_issues_ins. Добавляет задачу с описанием description и планируемым 
  количеством часов planned_time и присваеивает ей состояние "В очереди".
*/
create or replace procedure bugtracker.sp_issues_ins(description varchar2, planned_time float) as
  iss_id number;
  mv_id number;
begin
  select seq_issues.nextval into iss_id from dual;
  select seq_issue_movements.nextval into mv_id from dual;

  insert into tbl_issues(id, description, planned_time)
  values (iss_id, sp_issues_ins.description, sp_issues_ins.planned_time);

  insert into tbl_issue_movements (id, issue_id, status_id)
  values (mv_id, iss_id,
    1 -- В очереди
  );
  update tbl_issues set last_movement_id = mv_id where id = iss_id;
end;
/
/*
  Процедура sf_issues_fetch_row. Возвращает одну строку представления vw_issues.
  Используется для обновления строки в гриде задач после изменения состояния 
  задачи.
*/
create or replace function bugtracker.sf_issues_fetch_row(id number) return sys_refcursor as
  res sys_refcursor;
begin
  open res for
    select
      id,
      description,
      status_id,
      status,
      planned_time,
      actual_time
    from
      vw_issues
    where
      id = sf_issues_fetch_row.id;
  return res;
end;
/
/*
  Процедура sp_issue_movements. Возвращает перемещения одной задачи из 
  представления vw_issue_movements.
*/
create or replace procedure bugtracker.sp_issue_movements(id number, res out sys_refcursor) as
begin
  open res for
    select
      id,
      issue_id,
      cast(movement_date as date) as movement_date,
      status,
      actual_time
    from
      vw_issue_movements
    where
      issue_id = sp_issue_movements.id
    order by movement_date;
end;
/
/*
  Процедура sp_issue_movements_ins. Вызывается при нажатии кнопки перехода в
  какое-либо состояние на форме задачи. Переводит задачу issue_id в состояние
  status_id. Перед этим выполняется проверка на доступность перехода по таблице
  tbl_status_movements. Если переход не возможен, выбрасывается исключение с 
  кодом -20001.
*/
create or replace procedure bugtracker.sp_issue_movements_ins(issue_id number, status_id number) as
  tst number;
  new_mvmnt_id number;
begin
  select case when (sp_issue_movements_ins.status_id in (select sm.status_to from
    tbl_issues i
    inner join tbl_issue_movements im on i.last_movement_id = im.id
    inner join tbl_status_movements sm on im.status_id = sm.status_from
  where
     i.id = sp_issue_movements_ins.issue_id)) then 1 else 0 end into tst from dual;
  if tst = 0 then
    raise_application_error(-20001, 'Can not move issue #' || sp_issue_movements_ins.issue_id || ' into state ' || sp_issue_movements_ins.status_id);
  end if;

  select seq_issue_movements.nextval into new_mvmnt_id from dual;
  insert into tbl_issue_movements (
    id,
    issue_id,
    status_id
  ) values (
    new_mvmnt_id,
    sp_issue_movements_ins.issue_id,
    sp_issue_movements_ins.status_id
  );

  update
    tbl_issue_movements
  set
    next_movement_id = new_mvmnt_id
  where
    id = (select i.last_movement_id from tbl_issues i where i.id = sp_issue_movements_ins.issue_id);

  update
    tbl_issues
  set
    last_movement_id = new_mvmnt_id
  where
    id=sp_issue_movements_ins.issue_id;
end;
/
/*
  Процедура sp_next_statuses. Возвращает состояния, в которые может перейти 
  задача в состоянии status_id.
*/
create or replace procedure bugtracker.sp_next_statuses(status_id number, res out sys_refcursor) as
begin
  open res for
    select
      sm.status_from as status_id,
      s.id,
      s.name
    from
      tbl_statuses s
      inner join tbl_status_movements sm on sm.status_to = s.id
    where
      sm.status_from = sp_next_statuses.status_id
    order by 
      s.id;
end;
/
/*
  Процедура sp_status_buttons. Возвращает все возможные состояния, в которые 
  может перейти задача (кроме начального "В очереди", которое присваивается 
  при создании задачи). Используется для создания кнопок перехода в форме задач.
*/
create or replace procedure bugtracker.sp_status_buttons(res out sys_refcursor) as
begin
  open res for
    select distinct
      s.id,
      s.name
    from
      tbl_statuses s
      inner join tbl_status_movements sm on s.id = sm.status_to
    order by
      s.id;
end;
/
/* Роль для пользователя схемы */
create role bugtracker_user;
/* Права на выполнение процедур для пользователя */
grant create session to bugtracker_user;
grant execute on bugtracker.sp_issues to bugtracker_user;
grant execute on bugtracker.sp_issues_ins to bugtracker_user;
grant execute on bugtracker.sf_issues_fetch_row to bugtracker_user;
grant execute on bugtracker.sp_issue_movements to bugtracker_user;
grant execute on bugtracker.sp_issue_movements_ins to bugtracker_user;
grant execute on bugtracker.sp_next_statuses to bugtracker_user;
grant execute on bugtracker.sp_status_buttons to bugtracker_user;
/
/* Создание пользователя программы и делегирование ему роли пользователя */
create user bt_user identified by bt_user;
grant bugtracker_user to bt_user;