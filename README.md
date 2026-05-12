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

**Desglose de limpieza de datos:**
| Atributo(s) | Operación(es) | Justificación | Observación  |
|-------------|---------------|---------------|--------------|
| `fecha_evento`, `fecha_captura` | `UPDATE` | Se detectaron 9,221 registros donde `fecha_captura < fecha_evento`, lo cual es lógicamente imposible (no se puede capturar un evento antes de que ocurra). El patrón (no hay ninguna ocurrencia donde día sea mayor a 12) sugiere intercambiar día/mes en el parseo original. | Se corrigió la inversión día/mes, se arregló el año incorrecto en un subconjunto de tuplas y se intercambiaron las fechas en los casos donde ambas estaban invertidas. |
| `dia`  | `DROP COLUMN`  | El día de la semana ya está implícito en `fecha_evento`. Mantenerlo introduce redundancia y riesgo de inconsistencia. | Si llega a ser necesario se extraerá de `fecha_evento`. |
| `tipo_de_interseccion` | `UPDATE`, `RENAME COLUMN` | Se encontraron valores inconsistentes: "AJUSCO" (verificado en Maps como intersección tipo T) y "CRUZO" (typo de "CRUZ"), se renombró a `intersección` para facilidad de manipulación. Cuando el valor es "RECTO", no es una intersección. | Se corrigieron los valores erróneos a sus equivalentes correctos. Se nullificaron cuando este atributo es igual a "RECTA" |
| `clasificacion_de_la_vialidad` | `UPDATE`, `RENAME COLUMN` | Existía duplicación por diferencia de espaciado: "EJEVIAL" vs "EJE VIAL", se renombró a `vialidad` para facilidad de manipulación.  | Se homologó a "EJE VIAL". |
| `interseccion_semaforizada` | `UPDATE` | Existían valores "N" que debían ser "NO" para mantener consistencia con el dominio SI/NO del atributo. | Se homologó "N" a "NO". |
| `sentido_de_circulacion` | `UPDATE` |  Se encontraron typos ("P O" en vez de "P-O") y valores ambiguos ("N", "NO", "PO") que no representan sentidos cardinales válidos. | Corrección de escritura y nullificación de valores ambiguos. |
| `alcaldia` | `UPDATE` | Se detectaron 18 valores únicos cuando la CDMX solo tiene 16 alcaldías. "GUSTAVO A. MADERO" duplicaba a "GUSTAVO A MADERO" y "AV INSURGENTES" no es una alcaldía (la colonia asociada pertenece a Cuauhtémoc). | Se homologaron ambos casos a sus valores correctos. |
| `origen` | `UPDATE` | Se encontraron inconsistencias por tildes ("POLICÍA"/"POLICIA", "CÁMARA"/"CAMARA", "BOTÓN"/"BOTON"), variantes de 911 dispersas, y valores sin sentido como "SABADO". | Se homologaron variantes con tilde, se agruparon categorías de 911 y botón de auxilio, se nullearon valores sin sentido y se agruparon categorías con menos de 10 ocurrencias en "OTROS". |
| `sector` | `UPDATE` | Se encontraron múltiples errores ortográficos en nombres de sectores policiales ("TLALTELOLCO", "PALTEROS", "CALVERIA") y variantes de escritura para un mismo sector (9 variantes de "ABASTO REFORMA"). | Se corrigieron errores ortográficos evidentes. Categorías raras o de baja frecuencia se conservaron para evitar agrupaciones artificiales. Se nulleó "SD" (sin dato). |
| `matricula_unidad_medica` | `DROP COLUMN` | 82,187 nulos de 134,079 registros y no aporta valor analítico al estudio de patrones de accidentalidad. | Eliminada. |
| `folio` | `DROP COLUMN` | No funciona como llave primaria (7,288 registros con valor "SD" y folios repetidos). Es un identificador administrativo que no aporta al análisis de patrones de accidentalidad. | Eliminado. |

**Atributos no limpiados (decisión consciente):**

Los siguientes atributos presentan inconsistencias pero se decidió no modificarlos por el riesgo de introducir agrupaciones incorrectas:

| Atributo | Justificación de no intervención |
|----------|----------------------------------|
| `colonia` | Presenta más de 4,250 valores únicos con variaciones sutiles de escritura (abreviaciones, tildes, espacios). La homologación automatizada requeriría una fuente externa de referencia y una agrupación manual podría llevar a pérdida de información. |
| `unidad_a_cargo` | Contiene matrículas de unidades policiales con abreviaciones internas no documentadas. Sin un catálogo oficial, cualquier modificación podría alterar información. |
| `unidad_medica_de_apoyo` | Presenta múltiples variantes de instituciones (CRUZ ROJA, ERUM) combinadas con identificadores específicos. |

## Normalización

La normalización se realiza también mediante la estrategia de refresh destructivo. Para ejecutar el proceso de
normalización se puede emplear el siguiente comando en `psql`:

```{psql}
\i pipeline_scripts/03_data_normalization.sql
```


## Normalización del dataset de incidentes viales (CDMX)

El proceso de normalización transforma el conjunto de datos original en un modelo relacional estructurado, eliminando redundancia y asegurando consistencia mediante la separación de atributos categóricos en catálogos independientes.
Esta es una normalización intuitiva, por lo que no forzosamente está en FNBC o 4FN.

---

## Estructura general del modelo

El modelo se organiza en:

### Entidad central (hechos)
- `accidente`

**Justificación:**
Representa el evento principal del sistema (incidente vial). Se mantiene como tabla central porque concentra las variables cuantitativas y temporales del fenómeno. Todas las demás entidades se relacionan con esta tabla.

---

### Dimensiones geográficas
- `alcaldia`
- `colonia`

**Justificación:**
Se separan debido a que representan una estructura jerárquica y altamente repetitiva dentro de los registros.
- Permite análisis geoespacial consistente.
- Evita la duplicación de nombres de ubicación en cada incidente.
- Una alcaldía puede contener múltiples colonias (relación 1:N). Se implementa mediante:
  ```{psql}
  AND c.alcaldia_id = a.id
  ```

---

### Relaciones respecto a la clasificación del evento
- `tipo_evento`
- `tipo_interseccion`
- `clasificacion_vialidad`
- `sentido_circulacion`

**Justificación:**
Se modelan como catálogos independientes porque:
- Tienen un conjunto limitado de valores posibles.
- Se repiten constantemente en los registros.
- Separarlos evita inconsistencias de escritura y facilita la estandarización del análisis.

---

### Catálogos operativos
- `origen`
- `sector`

**Justificación:**
Estos atributos describen la operación del sistema de atención del incidente.
- Representan entidades administrativas o de respuesta.
- Su normalización permite mantener consistencia en la captura de datos.
- Facilita análisis sobre eficiencia y cobertura operativa.

---

### Infraestructura vial
- `vialidad (compuesta por las columnas punto_1 y punto_2)`

**Justificación:**
Se define a partir de dos atributos del dataset original que representan referencias espaciales del incidente.
- Se unifican para evitar duplicación de nombres de calles o avenidas.
- Facilita futuros análisis de intersecciones y relaciones espaciales entre vías.

---

```mermaid
erDiagram
    ubicacion ||--|{ accidente : " "
    reporte || -- |{ accidente : " "
    alcaldia ||--|{ colonia : " "
    vialidad ||--o| interseccion : " "
    vialidad ||--|| ubicacion : " "
    
    
    
    accidente {
        bigint id PK
        varchar(32) tipo
        smallint no_lesionados
        smallint no_fallecidos
        bigint ubicacion_id FK
        bigint reporte_id FK
    }
    alcaldia {
        bigint id PK
        varchar(32) nombre
    }
    colonia {
        bigint id PK
        varchar(32) colonia
        bigint alcaldia_id FK
    }
    interseccion {
        bigint id PK
        varchar(16) tipo
        varchar(32) calle_1
        varchar(32) calle_2
        varchar(5) sentido_circulacion
        bool semaforizada
    }
    vialidad {
        bigint id PK
        varchar(16) clasificacion
        varchar(32) calle
        bigint interseccion_id FK
    }
    ubicacion {
        bigint id PK
        float latitud
        float longitud
        bigint colonia_id FK
        bigint vialidad_id FK
        
    }
    reporte {
        bigint id PK
        varchar(32) origen
        varchar(32) sector
        varchar(5) prioridad
    }

```

-----
-----
# Shapefile
Primero, desde la terminal en postgres hay que correr `SELECT * FROM pg_available_extensions WHERE name = 'postgis';`
Si no existe la extensión, hay que instalarla siguiendo los pasos de [este link](https://postgis.net/documentation/getting_started/).

Luego, desde la base de datos en la terminal hay que correr `CREATE EXTENSION postgis;`
Para poder usarla.

Después, desde la terminal hay que correr `shp2pgsql -s 4326 -I data/colonias_iecm.shp clean.colonia_geometria | psql -d vialcdmx`

Aquí, 4326 es el sistema de coordenadas.
Este comando crea una tabla nueva clean.colonia_geometria con los datos del shapefile en data.
