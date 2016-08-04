
select
  i.id,
  i.description,
  im.status_id,
  s.name as status,
  i.planned_time,
  (
    select sum(actual_time * in_work) from (
      select
        (
          select
            sum(julianday(min(end, ifnull(imn.movement_date, datetime('now')))) - julianday(max(begin, im.movement_date) )) * 24
          from
            vw_work_days w
          where
            w.end > im.movement_date
            and w.begin < ifnull(imn.movement_date, datetime('now'))
        ) as actual_time,
        s1.in_work
      from
        tbl_issue_movements im
        inner join tbl_statuses s1 on im.status_id = s1.id
        left join tbl_issue_movements imn on im.next_movement_id = imn.id
      where
        im.issue_id = i.id
    )
  ) as actual_time
from
  tbl_issues i
  inner join tbl_issue_movements im on i.last_movement_id = im.id
  inner join tbl_statuses s on im.status_id = s.id;;



select issue_id, sum(actual_time * in_work) as at from
(
select
   im.id,
   im.issue_id,
   (
       select
       	sum(julianday(min(end, ifnull(imn.movement_date, datetime('now')))) - julianday(max(begin, im.movement_date) )) * 24
       from
       	vw_work_days w
       where
       	w.end > im.movement_date
       	and w.begin < ifnull(imn.movement_date, datetime('now'))
   ) as actual_time,
   s.in_work
from
   tbl_issue_movements im
   inner join tbl_statuses s on im.status_id = s.id
   left join tbl_issue_movements imn on im.next_movement_id = imn.id
)
group by issue_id
