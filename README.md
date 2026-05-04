# Proyecto BD: Accidentes de Tránsito en la CDMX

## Integrantes

- Alexis Cuevas — CU: XXXXXX — GitHub: LINK  
- Ben Zimbron — CU: XXXXXX — GitHub: LINK  
- Dominique Ontiveros — CU: XXXXXX — GitHub: LINK  
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

Por ello, es importante interpretar los resultados con responsabilidad y dentro de un contexto adecuado.

---

## Fuente de datos

Los datos utilizados en este proyecto provienen del Portal de Datos Abiertos de la Ciudad de México y son generados por la Secretaría de Seguridad Ciudadana (SSC) en colaboración con el C5 (Centro de Comando, Control, Cómputo, Comunicaciones y Contacto Ciudadano).

Estos datos se recolectan a partir de reportes de emergencia y registros policiales, y se publican con fines de transparencia y análisis estadístico.

Se pueden consultar en el siguiente enlace:

https://datos.cdmx.gob.mx/dataset/hechos-de-transito-reportados-por-ssc-base-ampliada-no-comparativa

Las instrucciones de replicación del proyecto asumen que los datos se encuentran almacenados en formato `CSV` bajo el nombre: `./data/raw_data.csv`

---

## Descripción del conjunto de datos

El conjunto de datos contiene aproximadamente 134,079 registros anuales, con 26 atributos que describen cada incidente.

### Atributos numéricos

- latitud  
- longitud  
- personas_fallecidas  
- personas_lesionadas  

### Atributos categóricos

- zona_vial  
- tipo_evento  
- tipo_de_interseccion  
- interseccion_semaforizada  
- clasificacion_de_la_vialidad  
- sentido_de_circulacion  
- dia  
- prioridad  
- origen  
- trasladado_lesionados  
- tipo_vehiculo  

### Atributos de texto

- folio  
- colonia  
- alcaldia  
- sector  
- unidad_a_cargo  
- unidad_medica_de_apoyo  
- matricula_unidad_medica  
- punto_1  
- punto_2  

### Atributos temporales

- fecha_evento  
- hora_evento  
- fecha_captura 

## Documentación
---
### Estructura del repositorio
El proyecto sigue una estructura modular para facilitar la reproducibilidad del pipeline de datos:}

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

> Esta es una buena sección para documentar los hallazgos del inciso B:
> Carga inicial y análisis preliminar.

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



