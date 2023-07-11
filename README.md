# PRUEBA-DATA-SCIENTIST

## Reducir perdidas por fraude en las reclamaciones de siniestro

#  Consulta en SQL
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


## Análisis descriptivo

Para realizar el análisis descriptivo se hizo la conexión desde R a la tabla fraudes, con la librería DBI y RPostgres. 

Se identificó que el 6% de los incidentes registrados fueron fraudulentos, en donde la mayoría de estos accidentes ocurrieron en áreas urbanas. Al analizar la combinación de tipo de auto y tipo de póliza, se observó que los autos Sedan destacaron como los autos más involucrados en fraudes. Específicamente, el 3% de los Sedan tenían pólizas contra todo riesgo, mientras que el 2% solo cubría daños al vehículo del propietario. 

Un aspecto importante es el intervalo de tiempo entre la adquisición del seguro y la denuncia del accidente. En general, suele transcurrir mas de 30 días, antes de que se reporte el accidente a la aseguradora. Al analizar los incidentes fraudulentos, se observó que estos ocurren con mayor frecuencia en vehículos que tienen entre 5 y 7 años, y en la mayoría de casos no se realizó una denuncia policial sobre el accidente ni se contó con testigos. Además, todos los casos de fraude fueron llevados a cabo por personas externas, es decir fraudes en los que el seguro es engañado por personas independientes. 

<img src="Analisis descriptivo/Analisis cuantitativo.png" width="100%" />

<img src="Analisis descriptivo/graficos cualitativos.png" width="100%" />

Por último las variables que mas influyen en el estudio de fraude son la clasificación del tipo de auto y el tipo de póliza,  son los factores que mas impacto tienen en la ocurrencia de estos incidentes. Al analizar los datos, se identificaron 4 grupos distintos en las reclamaciones realizadas. El grupo 1 se caracteriza por los accidentes en áreas urbanas, con autos Sedan y pólizas contra todo riesgo. En este grupo es notable la ausencia de reportes policiales y con fraudes realizados por externos. El grupo 2 se caracteriza por abarcar las categorías de vehículos Utility con pólizas contra todo riesgo. Al igual que en el primer grupo, no se encontraron reportes a la policía, pero sí se detectaron fraudes cometidos por personas externas. En el grupo 3 se presentan principalmente vehículos Sport, aunque en su mayoría sigue siendo del tipo Sedan, estos vehículos están cubiertos por un tipo de póliza que incluye daños al vehículo del propietario. Por último, el grupo 4, se caracteriza por vehículos Sedan con póliza contra terceros, en la categoría de vehiculos Sport. Por lo tanto, los grupos conformados en los datos dependen del tipo de póliza que presenten y tipo de vehículo. 

<img src="Analisis descriptivo/cluster.png" width="100%" />


# Recomendaciones para reducir fraudes

Para reducir las pérdidas por fraude en las reclamaciones de siniestro, se recomienda identificar patrones sospechosos y comportamientos inusuales que puedan indicar posibles casos de fraude. Dado que la mayoría de los incidentes fraudulentos ocurrieron en áreas urbanas, se aconseja analizar detalladamente los reclamos provenientes de esa área. Del mismo modo, se debe prestar especial atención a los reclamos relacionados con vehículos tipo Sedan. Además, es importante tener en cuenta que la falta de reportes policiales está muy asociado con un alto porcentaje de fraudes, por lo tanto se recomienda tener un informe policial o alguna constancia que demuestre que el incidente si ha sido reportado. 
Como el seguro es engañado por personas independientes, se necesita fortalecer el proceso de verificación y validación de los reclamantes, también validar la información del accidente con la policía y de testigos. 


## Modelo de machine learning

Se entrena un algoritmo de máquina de soporte vectorial (SVM) ya que es un algoritmo flexible. Antes de entrenar el modelo se realiza la división de los datos, el 80% son datos de entrenamiento del modelo y el 20% son datos para testear. Esto se utiliza con el fin de evaluar los resultados del modelo.

Este modelo SVM es eficaz para clasificar los datos en las dos categorías distintas, en este caso si presenta fraude o no. Además, es eficiente cuando se tiene un espacio de alta dimensión, las variables de estudio en su mayoría son categoricas por lo que se tiene una alta dimensión. 

Al ajustar este modelo, se obtienen los indicadores de correcta clasificación, los cuales permiten medir el desempeño de este. Este modelo es un clasificador de buena calidad, clasifica los fraudes en las reclamaciones en un 94% y predice con un 100% las reclamaciones no fraudulentas. 




## Tablero interactivo

(Se adjunta archivo de Power BI)

<img src="Tablero Power BI/Tablero.png" width="100%" />



## Acciones a tomar para reducir fraudes


En conclusión, los insights obtenidos relevan patrones y factores que pueden contribuir a la reducción de fraudes en las reclamaciones de siniestro. Para mitigar este problema se recomienda implementar las siguientes acciones:

1. Reforzar la detección temprana de los incidentes de fraude. Es muy importante establecer algunos mecanismos de control y vigilancia en los accidentes que ocurren en las áreas urbanas, en donde el tipo de vehículo es Sedan y además no se presenta una denuncia policial, ya que se identifica una mayor concentracion de fraudes en esos casos. Para ello se podría incluir el uso de tecnologías avanzadas como sistemas de monitoreo y algoritmos automatizados que identifiquen esos comportamientos fraudulentos, especialmente cuando se presenten las condiciones mencionadas anteriormente. 

2. Fomentar la denuncia policial y concientización. Como la mayoría de los incidentes fraudulentos no se denuncian a la policía ni se cuenta con testigos, es esencial promover una mayor conciencia sobre la importancia de informar los accidentes a las autoridades. La aseguradora podría colaborar con organismos policiales y realizar campañas para destacar la importancia de la denuncia y la cooperación en la investigación de reclamaciones. También se podría realizar un estudio para ver la viabilidad de exigir una denuncia policial en las reclamaciones que sobrepasen cierto monto. Con esta medida se puede llevar a cabo una revisión más exhaustiva, incluyendo la verificación de la información proporcionada en la denuncia, lo que puede ayudar a detectar posibles irregularidades. 

3. Fortalecer los controles internos. Establecer procedimientos claros para la gestión de las reclamaciones, incluyendo la verificación de la documentación requerida. También es importante capacitar al personal encargado de la gestión de reclamaciones en la detección de fraudes y en la identificación de signos de reclamaciones sospechosas. Adicionalmente, al combinar los algoritmos de detección de fraudes con la intervención humana en la verificación de los casos identificados, se puede fortalecer la efectividad de los controles internos y reducir la incidencia de fraudes en las reclamaciones. 






