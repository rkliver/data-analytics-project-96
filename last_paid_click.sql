with last_click as (
    select
        visitor_id,
        MAX(visit_date) as visit_date
    from sessions
    where medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
    group by visitor_id
)

select
    l_c.visitor_id,
    TO_CHAR(l_c.visit_date, 'yyyy-mm-dd HH24:MI:SS.MS') as visit_date,
    s.source as utm_source,
    s.medium as utm_medium,
    s.campaign as utm_campaign,
    l.lead_id,
    TO_CHAR(l.created_at, 'yyyy-mm-dd HH24:MI:SS.MS') as created_at,
    l.amount,
    l.closing_reason,
    l.status_id
from last_click as l_c
inner join sessions as s
    on
        l_c.visitor_id = s.visitor_id
        and l_c.visit_date = s.visit_date
left join leads as l
    on l_c.visitor_id = l.visitor_id
order by
    l.amount desc nulls last,
    visit_date asc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc;
