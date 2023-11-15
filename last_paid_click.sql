with last_paid as (
    select *
    from sessions
    where medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
    order by visit_date desc
)

select
    lp.visitor_id,
    coalesce(lp.visit_date) as visit_date,
    lp.source as utm_source,
    lp.medium as utm_medium,
    lp.campaign as utm_campaign,
    l.lead_id,
    l.created_at,
    l.amount,
    l.closing_reason,
    l.status_id
from last_paid as lp
left join leads as l
    on lp.visitor_id = l.visitor_id
order by
    amount desc nulls last, visit_date asc, utm_source asc, utm_medium asc, utm_campaign asc;
