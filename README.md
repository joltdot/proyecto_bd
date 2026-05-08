# Proyecto BD: Accidentes de Tránsito en la CDMX

## Integrantes

- Alexis Cuevas — CU: 219050 — GitHub: https://github.com/alexiscuevasheras  
- Ben Zimbron — CU: XXXXXX — GitHub: https://github.com/benbenutoravioli
- Dominique Ontiveros — CU: 220552 — GitHub: https://github.com/Domdimad0m 
- Fernando Gutiérrez — CU:  216761 — GitHub: https://github.com/ferdgm
- Juan Pablo Montiel — CU: 220172 — GitHub: https://github.com/joldot  

---

## Introducción

Este proyecto utiliza un conjunto de datos que contiene información detallada sobre incidentes de tránsito ocurridos en la Ciudad de México. Cada registro describe un siniestro vial e incluye información sobre su ubicación geográfica, características del evento, condiciones del entorno, vehículos involucrados y consecuencias humanas.

El análisis de estos datos permite identificar patrones de accidentalidad urbana y contribuir al diseño de estrategias para mejorar la seguridad vial en la ciudad.

En particular, este proyecto busca:

- Identificar puntos críticos con alta incidencia de accidentes  
- Analizar patrones temporales (horas y días con mayor frecuencia)  
- Detectar factores de riesgo predominantes por alcaldía  

Estos resultados pueden apoyar la toma de decisiones en:

- Planeación de infraestructura vial  
- Asignación de recursos de emergencia  
- Diseño de campañas de concientización  

### Consideraciones éticas

El uso de este conjunto de datos implica ciertas consideraciones éticas. Aunque no contiene información personal directa, existe el riesgo de identificación indirecta en casos específicos. Además, el análisis podría contribuir a la estigmatización de ciertas zonas con alta incidencia de accidentes o ser utilizado por terceros (por ejemplo, aseguradoras) para tomar decisiones que afecten a la población.

Adicionalmente, es importante considerar el sesgo de exclusión presente en los datos. Al provenir exclusivamente de reportes de emergencia y registros policiales, el conjunto de datos sub-representa aquellas zonas o poblaciones donde los incidentes no se reportan, ya sea por falta de acceso a servicios de emergencia, desconfianza hacia las instituciones o porque los involucrados resuelven el incidente sin intervención oficial. Esto implica que las conclusiones derivadas del análisis podrían invisibilizar necesidades reales de infraestructura vial o atención en zonas con bajo reporte, perpetuando la concentración de recursos hacia las áreas que ya cuentan con mayor cobertura institucional.

Por ello, es importante interpretar los resultados con responsabilidad y dentro de un contexto adecuado, con el conocimiento a priori de que la ausencia de datos no equivale a la ausencia de riesgo.

---

## Fuente de datos

Los datos utilizados en este proyecto provienen del Portal de Datos Abiertos de la Ciudad de México y son generados por la Secretaría de Seguridad Ciudadana (SSC) en colaboración con el C5 (Centro de Comando, Control, Cómputo, Comunicaciones y Contacto Ciudadano).

Estos datos se recolectan a partir de reportes de emergencia y registros policiales, y se publican con fines de transparencia y análisis estadístico. Su frecuencia de actualización es mensual, aunque la última actualización disponible fue publicada el 23 de febrero de 2024 con información hasta el 31 de diciembre de 2023.

Se pueden consultar en el siguiente enlace:

https://datos.cdmx.gob.mx/dataset/hechos-de-transito-reportados-por-ssc-base-ampliada-no-comparativa/resource/0555dd20-d921-4f76-aa8c-1a0689f48bce

Las instrucciones de replicación del proyecto asumen que los datos se encuentran almacenados en formato `CSV` bajo el nombre: `./data/raw_data.csv`

---

## Descripción del conjunto de datos

El conjunto de datos contiene aproximadamente 134,079 registros anuales, con 26 atributos que describen cada incidente.

|Atributo|Tipo|Descripción|
|--------|-----|----------|
|latitud|Numérico|Coordenada de latitud del incidente|
|longitud|Numérico|Coordenada de longitud del incidente|
|personas_fallecidas|Numérico|Número de personas fallecidas en el incidente|
|personas_lesionadas|Numérico|Número de personas lesionadas en el incidente|
|zona_vial|Categórico|Zona vial donde ocurrió el incidente (valores del 1 al 6)|
|tipo_evento|Categórico|Clasificación del accidente (choque, atropellado, derrapado, volcadura, caída de ciclista, caída de pasajero)|
|tipo_de_interseccion|Categórico|Geometría de la intersección donde ocurrió el incidente (cruz, Y, glorieta, curva, desnivel, etc.)|
|interseccion_semaforizada|Categórico|Indica si la intersección cuenta con semáforo (SI/NO)|
|clasificacion_de_la_vialidad|Categórico|Tipo de vialidad donde ocurrió el incidente (vía primaria, vía secundaria, eje vial, acceso carretero, etc.)|
|sentido_de_circulacion|Categórico|Sentido cardinal de circulación de la vialidad donde ocurrió el incidente|
|dia|Categórico|Día de la semana en que ocurrió el incidente|
|prioridad|Categórico|Nivel de prioridad asignado al incidente (alta, media, baja)|
|origen|Categórico|Canal por el cual se reportó el incidente (llamada 911, radio, cámara, botón de auxilio, etc.)|
|trasladado_lesionados|Categórico|Indica si los lesionados fueron trasladados a una unidad médica (SI/NO)|
|colonia|Categórico|Colonia donde ocurrió el incidente|
|alcaldia|Categórico|Alcaldía de la Ciudad de México donde ocurrió el incidente|
|sector|Categórico|Sector policial que atendió el incidente|
|folio|Texto|Identificador alfanumérico asignado al reporte del incidente|
|unidad_a_cargo|Texto|Matrícula de la unidad policial que atendió el incidente|
|unidad_medica_de_apoyo|Texto|Identificador de la unidad médica que brindó apoyo|
|matricula_unidad_medica|Texto|Matrícula de la unidad médica que atendió el incidente|
|punto_1|Texto|Nombre de la primera vialidad de referencia del incidente|
|punto_2|Texto|Nombre de la segunda vialidad de referencia|
|fecha_evento|Temporal|Fecha en que ocurrió el incidente|
|hora_evento|Temporal|Hora en que ocurrió el incidente|
|fecha_captura|Temporal|Fecha en que se capturó el registro en el sistema|

## Documentación
---
### Estructura del repositorio
El proyecto sigue una estructura modular para facilitar la reproducibilidad del pipeline de datos:

```
├── README.md                                         <- Documentación para desarrolladores de este proyecto (i.e., reporte escrito)
├── data
│   ├── .gitignore
│   └── raw_data.csv                                  <- Datos en formato CSV como vienen de la fuente original
│
├── pipeline_scripts                                  <- Scripts de SQL para ejecución del pipeline de datos
│   ├── 01_raw_data_schema_creation_and_load.sql      <- Script de carga inicial (i.e., actividad B)
│   ├── 02_data_cleaning.sql                          <- Script de limpieza de datos (i.e., actividad C)
│   ├── 03_data_normalization.sql                     <- Script de normalización de relaciones (i.e., actividad D)
│   └── 04_analytical_attributes_creation.sql         <- Script de creación de atributos analíticos (i.e., actividad E)
│
└── exploration_queries                               <- Scripts de SQL para exploración de datos
    ├── 01_raw_data_exploration.sql                   <- Consultas de exploración de datos en bruto (i.e., soporte de actividad B)
    ├── ⋅⋅⋅                                           <- Otras consultas en caso de ser requeridas
    └── 0N_analytical_queries.sql                     <- Consultas de interés sobre los datos normalizados (i.e., soporte de actividad E)
```

### Requerimientos para replicación del proyecto

Para replicar este proyecto es necesario:

1. Descargar los datos en bruto de acuerdo con la sección de **Fuente de datos**.
2. Contar con PostgreSQL 16 o superior instalado.
3. Crear una base de datos exclusiva para el proyecto.
4. Contar con acceso a una terminal con `psql` o un cliente compatible (por ejemplo, TablePlus).
5. Ejecutar los comandos desde la raíz del repositorio.

## Carga inicial

En primer lugar, se debe crear una base de datos exclusiva para este proyecto. Para ello, ejecutar el siguiente comando en `psql`:

```{psql}
CREATE DATABASE vialcdmx;
```

Posteriormente, debemos conectarnos a dicha base de datos empleado:

```{psql}
\c vialcdmx
```

Finalmente, para cargar los datos en bruto se debe ejecutar el siguiente comando en una sesión de línea de comandos `psql`:

```{psql}
\i pipeline_scripts/01_raw_data_schema_creation_and_load.sql
```

### Hallazgos del análisis preliminar

El script de exploración se encuentra en `exploration_queries/01_data_pre_analytics.sql`. A continuación se resumen los hallazgos principales:

**Registros totales:** 134,079 tuplas cargadas exitosamente.

**Rango temporal:** Los datos abarcan del 1 de enero de 2018 al 31 de diciembre de 2023.

**Valores únicos en columnas relevantes:**

| Columna | Valores únicos |
|---------|---------------|
| folio | 126,472 |
| colonia | 4,250 |
| sector | 237 |
| origen | 29 |
| alcaldia | 18 |
| tipo_evento | 6 |

**Folio como posible llave:** El atributo 'folio' no es candidato a llave primaria ya que existen 7,288 registros con valor "SD" (sin dato) y algunos folios repetidos (hasta 5 veces).

**Estadísticas numéricas:**

| Atributo | Mínimo | Máximo | Promedio |
|----------|--------|--------|----------|
| zona_vial | 1 | 6 | 2.99 |
| personas_fallecidas | 0 | 10 | 0.0195 |
| personas_lesionadas | 0 | 25 | 1.1634 |

No se encontraron valores negativos en personas fallecidas ni lesionadas.

**Distribución por tipo de evento:**

| Tipo evento | Total |
|-------------|-------|
| CHOQUE | 76,907 |
| DERRAPADO | 24,940 |
| ATROPELLADO | 24,844 |
| CAIDA DE CICLISTA | 3,151 |
| VOLCADURA | 2,296 |
| CAIDA DE PASAJERO | 1,941 |

**Distribución por alcaldía (top 5):**

| Alcaldía | Total |
|----------|-------|
| CUAUHTEMOC | 19,669 |
| IZTAPALAPA | 19,262 |
| GUSTAVO A MADERO | 14,762 |
| BENITO JUAREZ | 10,753 |
| VENUSTIANO CARRANZA | 10,055 |

**Valores nulos relevantes:**

| Columna | Nulos |
|---------|-------|
| matricula_unidad_medica | 82,187 |
| hora_evento | 5,009 |
| latitud | 7 |
| longitud | 4 |
| trasladado_lesionados | 3 |
| unidad_medica_de_apoyo | 2 |
| folio | 1 |

**Colonias con mayor incidencia (top 10):**

| Colonia | Total |
|---------|-------|
| CENTRO | 3,719 |
| MORELOS | 1,432 |
| DOCTORES | 1,424 |
| AGRICOLA ORIENTAL | 1,419 |
| JUAREZ | 1,217 |
| ROMA NTE | 1,176 |
| GUERRERO | 1,134 |
| OBRERA | 1,014 |
| AGRICOLA PANTITLAN | 877 |
| NARVARTE PTE | 858 |

**Distribución por prioridad:**

| Prioridad | Total |
|-----------|-------|
| BAJA | 103,200 |
| MEDIA | 28,125 |
| ALTA | 2,754 |

**Origen del reporte (top 5):**

| Origen | Total |
|--------|-------|
| LLAMADA DEL 911 | 65,167 |
| (vacío) | 35,043 |
| RADIO | 14,680 |
| 911 CDMX | 10,769 |
| BOTON DE AUXILIO | 4,628 |

**Inconsistencias detectadas en atributos categóricos:**

- En `dia` se encontraron 19 valores distintos cuando solo debería haber 7. Existen errores tipográficos como "Mábado", "Siérco", "S<c3>érco" y valores que no corresponden a días como "Ruben leñero", "Taxqueña", "Coruña" y "1° de mayo".
- En `alcaldia` aparecen 18 valores cuando la CDMX tiene 16 alcaldías. Se detectó "AV INSURGENTES" (que no es una alcaldía) y una duplicación por diferencia en puntuación: "GUSTAVO A MADERO" vs "GUSTAVO A. MADERO".
- En `origen` se detectó duplicación por diferencia de tilde: "BOTON DE AUXILIO" vs "BOTÓN DE AUXILIO". Además, 35,043 registros (26%) no tienen origen registrado.
- Se encontraron 9,221 registros donde `fecha_captura` es anterior a `fecha_evento`, lo cual es lógicamente imposible. El patrón sugiere una inversión de día y mes en el parseo de las fechas (formato DD/MM interpretado como MM/DD).
- No se encontraron filas completamente duplicadas al comparar por fecha, hora, tipo de evento, folio, latitud, longitud y alcaldía.

## Limpieza de datos

El proceso de limpieza sigue una metodología de refresh destructivo, por lo que cada vez que se corra se generará desde
cero el esquema y las tablas correspondientes. Para ejecutar el proceso de limpieza de datos se debe ejecutar el siguiente 
comando en `psql`:

```{psql}
\i pipeline_scripts/02_data_cleaning.sql
```

> Aquí es una buena sección para documentar las actividades realizadas
> de acuerdo a lo mencionado en el inciso C: Limpieza de datos

## Normalización

La normalización se realiza también mediante la estrategia de refresh destructivo. Para ejecutar el proceso de
normalización se puede emplear el siguiente comando en `psql`:

```{psql}
\i pipeline_scripts/03_data_normalization.sql
```

>  Aquí es una buena sección para documentar la descomposición intuitiva de las tablas.
> También un ERD del diseño final debe ser incluido.



