with visitors as (
    select
        DATE_TRUNC('Day', visit_date) as visit_date,
        source as utm_source,
        medium as utm_medium,
        campaign as utm_campaign,
        COUNT(visitor_id) as visitors_count
    from sessions
    where medium != 'organic'
    group by 1, 2, 3, 4
),

ads as (
    select
        DATE_TRUNC('Day', campaign_date) as campaign_date,
        utm_source,
        utm_medium,
        utm_campaign,
        SUM(daily_spent) as total_cost
    from vk_ads
    group by 1, 2, 3, 4
    union
    select
        DATE_TRUNC('Day', campaign_date) as campaign_date,
        utm_source,
        utm_medium,
        utm_campaign,
        SUM(daily_spent) as total_cost
    from ya_ads
    group by 1, 2, 3, 4
),

leads_agg as (
    select
        DATE_TRUNC('Day', s.visit_date) as visit_date,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        COUNT(s.visitor_id) as leads_count,
        COUNT(s.visitor_id) filter (
            where
            l.closing_reason = 'Успешно реализовано'
            or l.status_id = 142
        ) as purchases_count,
        SUM(l.amount) as revenue
    from sessions as s
    inner join leads as l
        on s.visitor_id = l.visitor_id
    where s.medium != 'organic'
    group by 1, 2, 3, 4
)

select
    vbm.visit_date,
    vbm.utm_source,
    vbm.utm_medium,
    vbm.utm_campaign,
    vbm.visitors_count,
    ads.total_cost,
    l_a.leads_count,
    l_a.purchases_count,
    l_a.revenue
from visitors as vbm
inner join ads
    on
        vbm.visit_date = ads.campaign_date
        and vbm.utm_source = ads.utm_source
        and vbm.utm_medium = ads.utm_medium
        and vbm.utm_campaign = ads.utm_campaign
inner join leads_agg as l_a
    on
        vbm.visit_date = l_a.visit_date
        and vbm.utm_source = l_a.utm_source
        and vbm.utm_medium = l_a.utm_medium
        and vbm.utm_campaign = l_a.utm_campaign
order by
    l_a.revenue desc nulls last,
    vbm.visit_date asc,
    vbm.visitors_count desc,
    vbm.utm_source asc,
    vbm.utm_medium asc,
    vbm.utm_campaign asc;
