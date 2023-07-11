# PRUEBA-DATA-SCIENTIST

## Reducir perdidas por fraude en las reclamaciones de siniestro

Para realizar esta prueba primero se creo la base de datos en PostgreSql (local) que contiene la tabla "fraudes" con la información del archivo fraude.csv. Al cargar la base de datos, se escribe el siguiente query de SQL que replica la siguiente salida.

``` r
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

```

<img src="SQL/Salida query.png" width="100%" />
