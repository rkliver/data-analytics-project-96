-- График "Уникальные посетители"
SELECT visit_date AS visit_date,
       sum(count) AS "Уникальные посетители"
FROM
  (select TO_CHAR(visit_date, 'yyyy-mm-dd') as visit_date,
          COUNT(DISTINCT visitor_id)
   from sessions
   group by 1) AS virtual_table
GROUP BY visit_date
ORDER BY "Уникальные посетители" DESC;

-- График "Рекламные переходы"
SELECT visit_date AS visit_date,
       sum(visitors_count) AS "Рекламные переходы"
FROM aggregate_last_paid_click
GROUP BY visit_date
ORDER BY "Рекламные переходы" DESC;

-- Столбатая диаграмма "Рекламные переходы по каналам (в день)"
SELECT visit_date AS visit_date,
       utm_source AS utm_source,
       sum(visitors_count) AS "Рекламные переходы"
FROM aggregate_last_paid_click
GROUP BY visit_date,
         utm_source
ORDER BY "Рекламные переходы" DESC;

-- Столбатая диаграмма "Рекламные переходы по каналам (в неделю)"
SELECT case
           when visit_date between '2023-06-01' and '2023-06-04' then '01.06-04.06'
           when visit_date between '2023-06-05' and '2023-06-11' then '05.06-11.06'
           when visit_date between '2023-06-12' and '2023-06-18' then '12.06-18.06'
           when visit_date between '2023-06-19' and '2023-06-25' then '19.06-25.06'
           when visit_date between '2023-06-26' and '2023-06-30' then '26.06-30.06'
       end AS visit_date,
       utm_source AS utm_source,
       sum(visitors_count) AS "Рекламные переходы"
FROM aggregate_last_paid_click
GROUP BY case
             when visit_date between '2023-06-01' and '2023-06-04' then '01.06-04.06'
             when visit_date between '2023-06-05' and '2023-06-11' then '05.06-11.06'
             when visit_date between '2023-06-12' and '2023-06-18' then '12.06-18.06'
             when visit_date between '2023-06-19' and '2023-06-25' then '19.06-25.06'
             when visit_date between '2023-06-26' and '2023-06-30' then '26.06-30.06'
         end,
         utm_source
ORDER BY "Рекламные переходы" DESC;

-- Круговая диаграмма "Количество лидов по каналам"
SELECT utm_source AS utm_source,
       sum(leads_count) AS "Количество лидов"
FROM aggregate_last_paid_click
GROUP BY utm_source
ORDER BY "Количество лидов" DESC;

-- Таблица "Таблица конверсий"
SELECT utm_source AS utm_source,
       sum(visitors_count) AS "Рекламные переходы",
       sum(leads_count) AS "Количество лидов",
       sum(purchases_count) AS "Количество оплат",
       round(sum(leads_count)*100.0/sum(visitors_count), 2) || '%' AS "Конверсия из клика в лид",
       case
           when sum(leads_count) > 0 then round(sum(purchases_count)*100.0/sum(leads_count), 2) || '%'
           else 0.0 || '%'
       end AS "Конверсия из лида в оплату"
FROM aggregate_last_paid_click
GROUP BY utm_source
ORDER BY "Рекламные переходы" DESC;

-- График "Затраты на рекламу по каналам"
SELECT visit_date AS visit_date,
       utm_source AS utm_source,
       sum(total_cost) AS "SUM(total_cost)"
FROM aggregate_last_paid_click
WHERE total_cost > 0
GROUP BY visit_date,
         utm_source
ORDER BY "SUM(total_cost)" DESC;

-- Столбатая диаграмма "Коэффициент возврата инвестиций в рекламу по каналам ROI (%)"
SELECT case
           when visit_date between '2023-06-01' and '2023-06-30' then 'Июнь'
       end AS visit_date,
       utm_source AS utm_source,
       ROUND((sum(revenue) - sum(total_cost)) * 100 / sum(total_cost), 2) AS "ROI"
FROM aggregate_last_paid_click
WHERE total_cost > 0
GROUP BY case
             when visit_date between '2023-06-01' and '2023-06-30' then 'Июнь'
         end,
         utm_source
ORDER BY "ROI" DESC;

-- Таблица "Сводная таблица"
SELECT utm_source AS utm_source,
       utm_medium AS utm_medium,
       utm_campaign AS utm_campaign,
       COALESCE(SUM(total_cost), 0) AS "Затраты на рекламу",
       COALESCE(SUM(revenue), 0) AS "Суммарный доход",
       COALESCE(SUM(total_cost), 0) / SUM(visitors_count) AS cpu,
       case
           when SUM(leads_count) = 0 then null
           else ROUND(COALESCE(SUM(total_cost), 0) / SUM(leads_count), 2)
       end AS cpl,
       case
           when SUM(purchases_count) = 0 then null
           else ROUND(COALESCE(SUM(total_cost), 0) / SUM(purchases_count), 2)
       end AS cppu,
       case
           when COALESCE(SUM(total_cost), 0) = 0 then null
           else ROUND((COALESCE(SUM(revenue), 0) - SUM(total_cost)) * 100 / SUM(total_cost), 2) || '%'
       end AS roi
FROM aggregate_last_paid_click
GROUP BY utm_source,
         utm_medium,
         utm_campaign
ORDER BY "Затраты на рекламу" DESC;
