# Introducción al Conjunto de Datos: Accidentes de Tránsito CDMX
### Alexis Cuevas, Ben Zimbron, Dominique Ontiveros, Fernando Gutierrez, Juan Pablo Montiel
---
Este conjunto de datos contiene información detallada sobre incidentes viales ocurridos en la Ciudad de México, incluyendo ubicación geográfica, características del siniestro, vehículos involucrados, víctimas y condiciones del entorno. Los datos permiten analizar patrones de accidentalidad urbana para mejorar políticas de seguridad vial. Estos son recolectados por la Secretaría de Seguridad Ciudadana (SSC) de la Ciudad de México en colaboración con el C5 (Centro de Comando, Control, Cómputo, Comunicaciones y Contacto Ciudadano) a través de reportes de emergencia y trabajo policial. Esta información se publica en el Portal de Datos Abiertos de la CDMX (https://datos.cdmx.gob.mx/dataset/hechos-de-transito-reportados-por-ssc-base-ampliada-no-comparativa) con actualizaciones mensuales que pararon en marzo de 2024. El objetivo principal es generar transparencia gubernamental y proporcionar información estadística para:

>- Políticas públicas de prevención vial
>- Asignación de recursos de emergencia
>- Estudios académicos sobre movilidad urbana
>- Auditoría ciudadana sobre seguridad pública
----
El conjunto de datos contiene 215,079 registros anuales con 26 atributos que describen cada incidente, cada uno de los cuales ayuda a analizar cada siniestro individualmente así como ver la relación entre cada registro.

### Atributos Numéricos:
>- folio
>- latitud
>- longitud

### Atributos Categóricos:
>- zona_vial
>- tipo_evento
>- tipo_de_interseccion
>- interseccion_semaforizada
>- clasificacion_de_la_vialidad
>- sentido_de_circulacion
>- dia
>- prioridad
>- origen (cómo se reportó el incidente)
>- trasladado_lesionados
>- no_vehiculo (dice si es el vehículo implicado #1 o #2)
>- tipo_vehiculo

### Atributos de Texto:
>- colonia
>- alcaldia
>- sector
>- unidad_a_cargo
>- unidad_medica_de_apoyo
>- matricula_unidad_medica
>- punto_1 (calle de cruce 1)
>- punto_2 (calle de cruce 2)
### Atributos Temporales/Fecha:
>- fecha_evento
>- hora_evento
>- fecha_captura


Utilizaremos este dataset para identificar zonas de alto riesgo vial en la CDMX mediante análisis geoespacial y temporal. Específicamente buscaremos:
>- Puntos críticos (calles/intersecciones con mayor incidencia)
>- Patrones horarios (horas pico de accidentalidad)
>- Factores de riesgo predominantes por alcaldía

Y así poder informar toma de decisiones sobre:

>- Colocación de semáforos o reductores de velocidad
>- Horarios de vigilancia policial
>- Campañas de concientización dirigidas

Aunque estos datos son muy valiosos, es importante considerar algunas implicaciones éticas como la privacidad de los involucrados (pues, aunque no hay detalles de los individuos, los registros individuales podrían permitir su identificación indirecta), la posible estigmatización de zonas por tener mayores siniestros e incluso el uso por aseguradoras para no cubrir todos los gastos de un accidente en ciertas zonas.

### Estructura del repositorio

```
├── README.md                                         <- Documentación para desarrolladores 
├── datos
│   ├── .gitignore
│   └── nuevo_acumulado_hechos_de_transito_2023_12.csv          <- Datos en formato CSV (originales)
│
├── pipeline_scripts                                  <- Ejecución del pipeline de datos
│   ├── nuevo_acumulado_hechos_de_transito_2023_12.sql     <- Carga inicial (i.e., actividad B)
│   ├── 02_data_cleaning.sql                          <- Limpieza de datos (i.e., actividad C)
│
└── exploration_queries                               <- Exploración de datos
```

## Carga inicial

El documento con la información originial de la página está en csv pero para recrearlo puedes descargar el siguiente link 
donde los datos están en sql: 

[➥ Descargar SQL](./datos/nuevo_acumulado_hechos_de_transito_2023_12.sql)

En el siguiente apartado hay una descripción paso a paso para crear la base de datos con el sql del proyecto. 
Favor de escribir los siguientes comandos en `psql`:

```{psql}
CREATE DATABASE vialcdmx;
```

Nos conectamos a la base de datos con la siguiente instrucción:

```{psql}
\c vialcdmx
```

**Importante** para cargar los datos a la base creada se debe ejecutar lo siguiente...
 En TablePlus o cualquier otro GUI client: 

```{psql}
-- PROYECTO: Accidentes de Tránsito CDMX
CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE raw.datos_transitocdmx (
    fecha_evento DATE, 
    hora_evento TIME, 
    tipo_evento TEXT, -- categoría del accidente
    fecha_captura DATE,
    folio TEXT,

    latitud DOUBLE PRECISION, -- coordenada respecto norte-sur
    longitud DOUBLE PRECISION, -- coordenada respecto a este-oeste

    punto_1 TEXT, -- primera calle
    punto_2 TEXT, -- segunda calle
    colonia TEXT, 
    alcaldia TEXT, 

    zona_vial INT, -- zona vial numérica
    sector TEXT, 
    unidad_a_cargo TEXT, 

    tipo_de_interseccion TEXT, -- forma del cruce: cruz, T, recta, curva, glorieta, entre otros
    interseccion_semaforizada TEXT, 
    clasificacion_de_la_vialidad TEXT, -- tipo de vialidad: eje vial, vía primaria, secundaria,
    sentido_de_circulacion TEXT, 

    dia TEXT, 
    prioridad TEXT, -- nivel de prioridad del incidente
    origen TEXT, -- medio por el cual se reportó el evento: radio, 911, etc.

    unidad_medica_de_apoyo TEXT, -- institución o servicio médico que apoyó
    matricula_unidad_medica TEXT, 
    trasladado_lesionados TEXT, -- indica si hubo traslado de lesionados: SI/NO

    personas_fallecidas INT, -- número de personas fallecidas
    personas_lesionadas INT -- número de personas lesionadas
);
```
 En psql ejecutar lo siguiente...
> 1. Para asegurar que se carguen bien los datos:
```{psql}
SET CLIENT_ENCODING TO 'UTF8';
```
> 2. Para cargar los datos:
```{psql}
SET CLIENT_ENCODING TO 'UTF8';
```

> 3. Para copiar los datos del csv (el formato de la dirección del csv es relativa al read-me)
 ```{psql}
\copy raw.datos_transitocdmx(fecha_evento,hora_evento,tipo_evento,fecha_captura,folio,latitud,longitud,punto_1,punto_2,colonia,alcaldia,zona_vial,sector,unidad_a_cargo,tipo_de_interseccion,interseccion_semaforizada,clasificacion_de_la_vialidad,sentido_de_circulacion,dia,prioridad,origen,unidad_medica_de_apoyo,matricula_unidad_medica,trasladado_lesionados,personas_fallecidas,personas_lesionadas)
FROM 'nuevo_acumulado_hechos_de_transito_2023_12.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');
```
## Limpieza de datos

