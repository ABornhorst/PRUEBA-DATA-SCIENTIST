SELECT 
monthh,
weekofmonth,
dayofweek,
ROUND(AVG(SUM(FraudFound_P) * 100.0 / COUNT(*)) OVER (PARTITION BY monthh), 2) AS percentage_fraud_month_week,
ROUND(AVG(SUM(FraudFound_P) * 100.0 / COUNT(*)) OVER (PARTITION BY weekofmonth), 2) AS percentage_fraud_month_week,
ROUND(SUM(FraudFound_P) * 100.0 / COUNT(*),2) AS percentage_fraud_month_week_day
FROM fraudes
GROUP BY monthh, weekofmonth, dayofweek
ORDER BY monthh, weekofmonth



