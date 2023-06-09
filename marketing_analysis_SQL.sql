-- ПОДГОТОВКА ДАННЫХ
UPDATE in_app_event
SET gross_event_revenue_usd = REPLACE(gross_event_revenue_usd, ',', '.');
UPDATE in_app_event
SET net_event_revenue_usd = REPLACE(net_event_revenue_usd, ',', '.');

ALTER TABLE in_app_events ADD new_net_rev DECIMAL(10,2);
UPDATE in_app_events SET new_net_rev = CAST(net_event_revenue_usd AS DECIMAL(10,2));

ALTER TABLE in_app_event ADD new_gross_rev DECIMAL(10,2);
UPDATE in_app_events SET new_gross_rev = CAST(gross_event_revenue_usd AS DECIMAL(10,2));

ALTER TABLE cost_dataset ADD cost_usd DECIMAL(10,2);
UPDATE cost_dataset SET cost_usd = CAST(cost AS DECIMAL(10,2)) / 100;

select * from cost_dataset;

-- ЗАДАНИЕ 1
-- уникальные установки
SELECT campaign, count(DISTINCT customer_user_id) AS installs
FROM in_app_event
GROUP BY campaign
ORDER BY campaign asc;

-- уникальные покупатели
SELECT campaign, COUNT(DISTINCT customer_user_id) AS unique_buyers
FROM in_app_event
WHERE event_name IN ('purchase')
GROUP BY campaign
ORDER BY campaign asc;

-- количество платежей
SELECT campaign, COUNT(event_name) AS purchases
FROM in_app_event
WHERE event_name IN ('purchase')
GROUP BY campaign
ORDER BY campaign asc;

-- суммарные затраты на проведение рекламных кампаний
SELECT  campaign, SUM(cost_usd) AS cost
FROM cost_dataset
GROUP BY campaign
ORDER BY campaign asc;

-- суммарная выручка привлеченных пользователей
SELECT campaign, ROUND(SUM(new_gross_rev), 2) AS net_revenue
FROM in_app_event
GROUP BY campaign
ORDER BY campaign asc;

-- ЗАДАНИЕ 2
-- конверсия по кампаниям
SELECT 
	campaign, 
	(
	ROUND(COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN customer_user_id END) /
	COUNT(DISTINCT customer_user_id), 3)
	)*100 AS conversion_rate,
	count(DISTINCT customer_user_id) as all_users
FROM in_app_event
GROUP BY campaign
ORDER BY campaign asc, all_users desc;

-- cpa в покупку по кампаниям
SELECT 
	e.campaign, 
	ROUND(c.cost/COUNT(DISTINCT e.customer_user_id), 2)  AS cpa_rate
FROM in_app_event e
JOIN (
  SELECT 
	campaign, 
	SUM(cost_usd) AS cost
  FROM cost_dataset
  GROUP BY campaign
) c
ON e.campaign = c.campaign
WHERE e.event_name = 'purchase'
GROUP BY campaign
ORDER BY campaign asc;


-- ROI
SELECT e.campaign,
 ROUND(((sum(e.new_net_rev)/c.cost)*100), 2) AS ROI_rate
FROM in_app_event e
JOIN (
  SELECT 
    campaign, 
    SUM(cost_usd) AS cost
  FROM cost_dataset
  GROUP BY campaign
) c
ON e.campaign = c.campaign
GROUP BY campaign
ORDER BY campaign asc;

-- ARPU по кампаниям
SELECT
	campaign,
	ROUND((sum(new_gross_rev)/COUNT(DISTINCT customer_user_id)), 2) AS ARPU
FROM in_app_event
GROUP BY campaign
ORDER BY campaign asc;

-- ЗАДАНИЕ 3
-- страна
-- конверсия по странам
SELECT 
	country_code, 
	(
	ROUND(COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN customer_user_id END) /
	COUNT(DISTINCT customer_user_id), 3)
	)*100 AS conversion_rate,
	count(DISTINCT customer_user_id) as all_users
FROM in_app_event
GROUP BY country_code
ORDER BY conversion_rate desc, all_users desc;

-- cpa в покупку по странам
SELECT 
	e.country_code, 
	ROUND(c.cost/COUNT(DISTINCT e.customer_user_id), 2)  AS cpa_rate
FROM in_app_event e
JOIN (
SELECT 
	country_code, 
	SUM(cost_usd) AS cost
FROM cost_dataset
GROUP BY country_code
) c
ON e.country_code = c.country_code
WHERE e.event_name = 'purchase'
GROUP BY e.country_code
ORDER BY cpa_rate desc;

-- ARPU по странам
SELECT
	country_code,
	ROUND(sum(new_gross_rev)/(COUNT(DISTINCT customer_user_id)), 2) AS ARPU
FROM in_app_event
GROUP BY country_code
ORDER BY ARPU desc;

-- ROI по странам
SELECT e.country_code,
 ROUND(((sum(e.new_net_rev)/c.cost)*100), 2) AS ROI_rate
FROM in_app_event e
JOIN (
  SELECT 
    country_code, 
    SUM(cost_usd) AS cost
  FROM cost_dataset
  GROUP BY country_code
) c
ON e.country_code = c.country_code
GROUP BY country_code
ORDER BY ROI_rate desc;

-- платформа
-- конверсия по платформам
SELECT 
platform_id, 
	(
	ROUND(COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN customer_user_id END) /
	COUNT(DISTINCT customer_user_id), 3)
	)*100 AS conversion_rate,
	count(DISTINCT customer_user_id) as all_users
FROM in_app_event
GROUP BY platform_id
ORDER BY platform_id desc, all_users desc;

-- cpa в покупку по платформам
SELECT 
	e.platform_id, 
	ROUND((c.cost/COUNT(DISTINCT e.customer_user_id)), 2)  AS cpa_rate
FROM in_app_event e
JOIN (
  SELECT 
	LOWER(platform) as platform, 
	SUM(cost_usd) AS cost
  FROM cost_dataset
  GROUP BY LOWER(platform)
) c
ON e.platform_id = c.platform
WHERE e.event_name = 'purchase'
GROUP BY e.platform_id, c.cost
ORDER BY platform_id desc;

-- ARPU по платформам
SELECT
	platform_id, 
	ROUND((sum(new_gross_rev)/COUNT(DISTINCT customer_user_id)), 2) AS ARPU
FROM in_app_event
GROUP BY platform_id
ORDER BY platform_id desc;

-- ROI по платформам
SELECT e.platform_id,
 ROUND(((sum(e.new_net_rev)/c.cost)*100), 2) AS ROI_rate
FROM in_app_event e
JOIN (
  SELECT 
    platform, 
    SUM(cost_usd) AS cost
  FROM cost_dataset
  GROUP BY platform
) c
ON e.platform_id = c.platform
GROUP BY platform_id
ORDER BY platform_id desc;

-- канал
-- конверсия по каналам
SELECT 
	media_channel, 
	(
	ROUND(COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN customer_user_id END) /
	COUNT(DISTINCT customer_user_id), 3)
	)*100 AS conversion_rate,
	count(DISTINCT customer_user_id) as all_users
FROM in_app_event
GROUP BY media_channel
ORDER BY media_channel desc, all_users desc;

-- cpa в покупку по каналам
SELECT 
	e.media_channel, 
	ROUND((c.cost/COUNT(DISTINCT e.customer_user_id)), 2)  AS cpa_rate
FROM in_app_event e
JOIN (
  SELECT 
	media_channel, 
	SUM(cost_usd) AS cost
  FROM cost_dataset
  GROUP BY media_channel
) c
ON e.media_channel = c.media_channel
WHERE e.event_name = 'purchase'
GROUP BY media_channel
ORDER BY media_channel desc;

-- ARPU по каналам
SELECT
	media_channel,
	ROUND((sum(gross_event_revenue_usd)/COUNT(DISTINCT customer_user_id)), 2) AS ARPU
FROM in_app_event
GROUP BY media_channel
ORDER BY media_channel desc;

-- ROI по каналам
SELECT e.media_channel,
 ROUND(((sum(e.new_net_rev)/c.cost)*100), 2) AS ROI_rate
FROM in_app_event e
JOIN (
  SELECT 
    media_channel, 
    SUM(cost_usd) AS cost
  FROM cost_dataset
  GROUP BY media_channel
) c
ON e.media_channel = c.media_channel
GROUP BY media_channel
ORDER BY media_channel desc;
