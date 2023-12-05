-- График "Уникальные посетители"
select
    virtual_table.visit_date,
    sum(virtual_table.count_visitor_id) as unique_count
from
    (select
        to_char(visit_date, 'yyyy-mm-dd') as visit_date,
        count(distinct visitor_id) as count_visitor_id
    from sessions
    group by 1) as virtual_table
group by 1;

-- График "Рекламные переходы"
select
    visit_date,
    sum(visitors_count) as visitors_count
from aggregate_last_paid_click
group by 1
order by 2 desc;

-- Столбчатая диаграмма "Рекламные переходы по каналам (в день)"
select
    visit_date as visit_date,
    utm_source as utm_source,
    sum(visitors_count) as visitors_count
from aggregate_last_paid_click
group by 1, 2
order by 3 desc;

-- Таблица "Таблица конверсий"
select
    utm_source as utm_source,
    sum(visitors_count) as visitors_count,
    sum(leads_count) as leads_count,
    sum(purchases_count) as purchases_count,
    round(
        sum(leads_count) * 100.0 / sum(visitors_count), 2
    ) as click_to_lead_rate,
    case
        when
            sum(leads_count) > 0
            then round(sum(purchases_count) * 100.0 / sum(leads_count), 2)
        else 0.0
    end as lead_to_purchase_rate
from aggregate_last_paid_click
group by 1
order by 2 desc;

-- Столбчатая диаграмма "Рекламные переходы по каналам (в неделю)"
select
    utm_source as utm_source,
    case
        when visit_date between '2023-06-01' and '2023-06-04' then '01.06-04.06'
        when visit_date between '2023-06-05' and '2023-06-11' then '05.06-11.06'
        when visit_date between '2023-06-12' and '2023-06-18' then '12.06-18.06'
        when visit_date between '2023-06-19' and '2023-06-25' then '19.06-25.06'
        when visit_date between '2023-06-26' and '2023-06-30' then '26.06-30.06'
    end as visit_date,
    sum(visitors_count) as visitors_count
from aggregate_last_paid_click
group by 2, 1
order by 3 desc;

-- Круговая диаграмма "Количество лидов по каналам"
select
    utm_source as utm_source,
    sum(leads_count) as leads_count
from aggregate_last_paid_click
group by 1
order by 2 desc;

-- График "Затраты на рекламу по каналам"
select
    visit_date as visit_date,
    utm_source as utm_source,
    sum(total_cost) as total_cost
from aggregate_last_paid_click
where total_cost > 0
group by 1, 2
order by 3 desc;

-- Столбчатая диаграмма 
-- "Коэффициент возврата инвестиций в рекламу по каналам ROI (%)"
select
    utm_source as utm_source,
    case
        when
            visit_date between '2023-06-01' and '2023-06-30'
            then june
    end
    as visit_date,
    ROUND((SUM(revenue) - SUM(total_cost)) * 100 / SUM(total_cost), 2) as roi
from aggregate_last_paid_click
where
    utm_source in ('vk', 'yandex')
group by 1, 2
order by 3 desc;

-- Таблица "Сводная таблица"
select
    utm_source as utm_source,
    utm_medium as utm_medium,
    utm_campaign as utm_campaign,
    COALESCE(SUM(total_cost), 0) as total_cost,
    COALESCE(SUM(revenue), 0) as revenue,
    COALESCE(SUM(total_cost), 0) / SUM(visitors_count) as cpu,
    case
        when SUM(leads_count) = 0 then null
        else ROUND(COALESCE(SUM(total_cost), 0) / SUM(leads_count), 2)
    end as cpl,
    case
        when SUM(purchases_count) = 0 then null
        else ROUND(COALESCE(SUM(total_cost), 0) / SUM(purchases_count), 2)
    end as cppu,
    case
        when COALESCE(SUM(total_cost), 0) = 0 then null
        else ROUND(
            (COALESCE(SUM(revenue), 0) - SUM(total_cost)) * 100
            /
            SUM(total_cost), 2
        )
    end as roi
from aggregate_last_paid_click
group by 1, 2, 3;

-- Столбчатая диаграмма "ROI по каналам (%)"
select
    utm_source as utm_source,
    utm_medium as utm_medium,
    utm_campaign as utm_campaign,
    case
        when visit_date between '2023-06-01' and '2023-06-30' then june
    end as visit_date,
    case
        when COALESCE(SUM(total_cost), 0) = 0
            then null
        else ROUND(
            (COALESCE(SUM(revenue), 0) - SUM(total_cost)) * 100
            /
            SUM(total_cost), 2
        )
    end as roi
from aggregate_last_paid_click
where total_cost > 0
group by 4, 1, 2, 3
order by 5 desc;

-- Столбчатая диаграмма "Выручка по каналам"
select
    utm_source as utm_source,
    utm_medium as utm_medium,
    utm_campaign as utm_campaign,
    SUM(revenue) as revenue,
    case
        when visit_date between '2023-06-01' and '2023-06-30'
            then june
    end as visit_date
from aggregate_last_paid_click
where revenue > 0
group by 5, 1, 2, 3
order by 4 desc;
