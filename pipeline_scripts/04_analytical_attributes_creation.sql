-- 04: Atributos analíticos y georreferenciación
-- Requiere la extensión PostGIS.

CREATE EXTENSION IF NOT EXISTS postgis;

-- Agregar columna de geometría a la tabla de accidentes
ALTER TABLE normalization.accidente
ADD COLUMN IF NOT EXISTS geom geometry(Point, 4326);

UPDATE normalization.accidente
SET geom = ST_Point(longitud, latitud, 4326)
WHERE geom IS NULL
  AND longitud IS NOT NULL
  AND latitud IS NOT NULL;

-- Puntos críticos con alta incidencia de accidentes
SELECT
    nac.latitud,
    nac.longitud,
    col.nombre AS colonia,
    al.nombre AS alcaldia,
    COUNT(*) AS total_accidentes
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
GROUP BY nac.latitud, nac.longitud, col.nombre, al.nombre
ORDER BY total_accidentes DESC;

-- Horas con mayor número de accidentes
SELECT
    EXTRACT(HOUR FROM nac.hora_evento) AS hora,
    COUNT(*) AS total_accidentes
FROM normalization.accidente AS nac
WHERE nac.hora_evento IS NOT NULL
GROUP BY hora
ORDER BY total_accidentes DESC;


-- Alcaldías con mayor incidencia de accidentes
SELECT
    al.nombre AS alcaldia,
    COUNT(*) AS total_accidentes
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
GROUP BY al.nombre
ORDER BY total_accidentes DESC;


-- Factores de riesgo predominantes por alcaldía
SELECT
    al.nombre AS alcaldia,
    cv.nombre AS clasificacion_vialidad,
    ti.nombre AS tipo_interseccion,
    isem.nombre AS interseccion_semaforizada,
    COUNT(*) AS total_accidentes
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
LEFT JOIN normalization.clasificacion_vialidad AS cv
    ON nac.clasificacion_vialidad_id = cv.id
LEFT JOIN normalization.tipo_interseccion AS ti
    ON nac.tipo_interseccion_id = ti.id
LEFT JOIN normalization.interseccion_semaforizada AS isem
    ON nac.interseccion_semaforizada_id = isem.id
GROUP BY al.nombre, cv.nombre, ti.nombre, isem.nombre
ORDER BY al.nombre, total_accidentes DESC;

-- Tipos de accidente más frecuentes
SELECT
    te.nombre AS tipo_accidente,
    COUNT(*) AS total_accidentes
FROM normalization.accidente AS nac
LEFT JOIN normalization.tipo_evento AS te
    ON nac.tipo_evento_id = te.id
GROUP BY te.nombre
ORDER BY total_accidentes DESC;

-- Relación entre intersecciones semaforizadas y accidentes
SELECT
    isem.nombre AS interseccion_semaforizada,
    COUNT(*) AS total_accidentes,
    SUM(nac.personas_lesionadas) AS total_lesionados,
    SUM(nac.personas_fallecidas) AS total_fallecidos
FROM normalization.accidente AS nac
LEFT JOIN normalization.interseccion_semaforizada AS isem
    ON nac.interseccion_semaforizada_id = isem.id
GROUP BY isem.nombre
ORDER BY total_accidentes DESC;

-- Clasificación de vialidad con mayor riesgo
SELECT
    cv.nombre AS clasificacion_vialidad,
    COUNT(*) AS total_accidentes,
    SUM(nac.personas_lesionadas) AS total_lesionados,
    SUM(nac.personas_fallecidas) AS total_fallecidos
FROM normalization.accidente AS nac
LEFT JOIN normalization.clasificacion_vialidad AS cv
    ON nac.clasificacion_vialidad_id = cv.id
GROUP BY cv.nombre
ORDER BY total_accidentes DESC;


-- Colonias con mayor número de personas lesionadas
SELECT
    col.nombre AS colonia,
    al.nombre AS alcaldia,
    SUM(nac.personas_lesionadas) AS total_lesionados,
    COUNT(*) AS total_accidentes
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
GROUP BY col.nombre, al.nombre
ORDER BY total_lesionados DESC;

-- Intersecciones más peligrosas por número de fallecidos
SELECT
    ti.nombre AS tipo_interseccion,
    isem.nombre AS interseccion_semaforizada,
    cv.nombre AS clasificacion_vialidad,
    al.nombre AS alcaldia,
    SUM(nac.personas_fallecidas) AS total_fallecidos,
    COUNT(*) AS total_accidentes
FROM normalization.accidente AS nac
LEFT JOIN normalization.tipo_interseccion AS ti
    ON nac.tipo_interseccion_id = ti.id
LEFT JOIN normalization.interseccion_semaforizada AS isem
    ON nac.interseccion_semaforizada_id = isem.id
LEFT JOIN normalization.clasificacion_vialidad AS cv
    ON nac.clasificacion_vialidad_id = cv.id
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia al
    ON col.alcaldia_id = al.id
GROUP BY ti.nombre, isem.nombre, cv.nombre, al.nombre
ORDER BY total_fallecidos DESC, total_accidentes DESC;

-- Días con mayor número de accidentes
SELECT
    TO_CHAR(nac.fecha_evento, 'Day') AS dia_semana,
    COUNT(*) AS total_accidentes
FROM normalization.accidente AS nac
WHERE nac.fecha_evento IS NOT NULL
GROUP BY dia_semana
ORDER BY total_accidentes DESC;

-- Mayor y menor tiempo entre accidente y captura
WITH tiempos_captura AS (
    SELECT AGE(fecha_captura, fecha_evento) AS tiempo_hasta_captura
    FROM normalization.accidente
)

SELECT MAX(tiempos_captura.tiempo_hasta_captura),
       'Maximo' AS tiempo_hasta_captura
FROM tiempos_captura

UNION

SELECT MIN(tiempos_captura.tiempo_hasta_captura),
       'Minimo'
FROM tiempos_captura

UNION

SELECT AVG(tiempos_captura.tiempo_hasta_captura),
'Promedio'
FROM tiempos_captura
;


-- FUNCIONES DE VENTANA

-- Ranking de alcaldías por total de accidentes
SELECT
    al.nombre AS alcaldia,
    COUNT(*) AS total_accidentes,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
WHERE al.nombre IS NOT NULL
GROUP BY al.nombre;


/* -- Accidentes acumulados por mes
SELECT
    TO_CHAR(fecha_evento, 'YYYY-MM') AS mes,
    COUNT(*) AS accidentes_mes,
    SUM(COUNT(*)) OVER (ORDER BY TO_CHAR(fecha_evento, 'YYYY-MM')) AS acumulado
FROM normalization.accidente
WHERE fecha_evento IS NOT NULL
GROUP BY TO_CHAR(fecha_evento, 'YYYY-MM')
ORDER BY mes; */


-- Promedio de lesionados por alcaldía vs gravedad (lesionados) de accidente
SELECT
    nac.id,
    al.nombre AS alcaldia,
    nac.personas_lesionadas,
    AVG(nac.personas_lesionadas) OVER (PARTITION BY al.nombre) AS promedio_lesionados_alcaldia
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
WHERE al.nombre IS NOT NULL
  AND nac.personas_lesionadas IS NOT NULL;


-- Diferencia de accidentes entre horas consecutivas
WITH accidentes_por_hora AS (
    SELECT
        EXTRACT(HOUR FROM hora_evento) AS hora,
        COUNT(*) AS total_accidentes
    FROM normalization.accidente
    WHERE hora_evento IS NOT NULL
    GROUP BY EXTRACT(HOUR FROM hora_evento)
)
SELECT
    hora,
    total_accidentes,
    LAG(total_accidentes, 1) OVER (ORDER BY hora) AS hora_anterior,
    total_accidentes - LAG(total_accidentes, 1) OVER (ORDER BY hora) AS diferencia
FROM accidentes_por_hora
ORDER BY hora;


-- Clasificar colonias en cuartiles de riesgo por número de accidentes
WITH accidentes_por_colonia AS (
    SELECT
        col.nombre AS colonia,
        al.nombre AS alcaldia,
        COUNT(*) AS total_accidentes
    FROM normalization.accidente AS nac
    LEFT JOIN normalization.colonia AS col
        ON nac.colonia_id = col.id
    LEFT JOIN normalization.alcaldia AS al
        ON col.alcaldia_id = al.id
    WHERE col.nombre IS NOT NULL
    GROUP BY col.nombre, al.nombre
)
SELECT
    colonia,
    alcaldia,
    total_accidentes,
    NTILE(4) OVER (ORDER BY total_accidentes DESC) AS cuartil_riesgo
FROM accidentes_por_colonia;


-- Ranking de tipos de evento por alcaldía
SELECT
    al.nombre AS alcaldia,
    te.nombre AS tipo_evento,
    COUNT(*) AS total,
    DENSE_RANK() OVER (PARTITION BY al.nombre ORDER BY COUNT(*) DESC) AS ranking_en_alcaldia
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
LEFT JOIN normalization.tipo_evento AS te
    ON nac.tipo_evento_id = te.id
WHERE al.nombre IS NOT NULL
  AND te.nombre IS NOT NULL
GROUP BY al.nombre, te.nombre;


-- QUERIES PARA GEORREFERENCIACIÓN

-- Top 20 intersecciones NO semaforizadas con más accidentes (petición de semaforización)
SELECT
    nac.latitud,
    nac.longitud,
    col.nombre AS colonia,
    al.nombre AS alcaldia,
    ti.nombre AS tipo_interseccion,
    COUNT(*) AS total_accidentes,
    SUM(nac.personas_lesionadas) AS total_lesionados,
    SUM(nac.personas_fallecidas) AS total_fallecidos
FROM normalization.accidente AS nac
LEFT JOIN normalization.interseccion_semaforizada AS isem
    ON nac.interseccion_semaforizada_id = isem.id
LEFT JOIN normalization.tipo_interseccion AS ti
    ON nac.tipo_interseccion_id = ti.id
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
WHERE isem.nombre = 'no'
  AND nac.latitud IS NOT NULL
  AND nac.longitud IS NOT NULL
GROUP BY nac.latitud, nac.longitud, col.nombre, al.nombre, ti.nombre
ORDER BY total_accidentes DESC
LIMIT 20;


-- Tasa de letalidad por colonia (para mapa coropético)
SELECT
    col.nombre AS colonia,
    al.nombre AS alcaldia,
    COUNT(*) AS total_accidentes,
    SUM(nac.personas_fallecidas) AS total_fallecidos,
    ROUND(SUM(nac.personas_fallecidas)::NUMERIC / COUNT(*), 4) AS tasa_letalidad
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
WHERE col.nombre IS NOT NULL
GROUP BY col.nombre, al.nombre
HAVING COUNT(*) >= 5
ORDER BY tasa_letalidad DESC;


-- Coordenadas de todos los accidentes (para mapa de calor)
SELECT
    nac.latitud,
    nac.longitud
FROM normalization.accidente AS nac
WHERE nac.latitud IS NOT NULL
  AND nac.longitud IS NOT NULL;


-- Tiempo promedio de respuesta (captura - evento) por colonia (para mapa coropético)
SELECT
    col.nombre AS colonia,
    al.nombre AS alcaldia,
    COUNT(*) AS total_accidentes,
    AVG(nac.fecha_captura - nac.fecha_evento) AS promedio_dias_respuesta
FROM normalization.accidente AS nac
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
WHERE col.nombre IS NOT NULL
  AND nac.fecha_captura IS NOT NULL
  AND nac.fecha_evento IS NOT NULL
GROUP BY col.nombre, al.nombre
HAVING COUNT(*) >= 5
ORDER BY promedio_dias_respuesta ASC;


-- Accidentes diurnos (7:00-18:59) para mapa comparativo día/noche
SELECT nac.latitud, nac.longitud
FROM normalization.accidente AS nac
WHERE nac.latitud IS NOT NULL
  AND nac.longitud IS NOT NULL
  AND nac.hora_evento IS NOT NULL
  AND EXTRACT(HOUR FROM nac.hora_evento) BETWEEN 7 AND 18;


-- Accidentes nocturnos (19:00-6:59) para mapa comparativo día/noche
SELECT nac.latitud, nac.longitud
FROM normalization.accidente AS nac
WHERE nac.latitud IS NOT NULL
  AND nac.longitud IS NOT NULL
  AND nac.hora_evento IS NOT NULL
  AND (EXTRACT(HOUR FROM nac.hora_evento) >= 19
       OR EXTRACT(HOUR FROM nac.hora_evento) < 7);


-- Intersecciones no semaforizadas con accidentes nocturnos
SELECT
    nac.latitud,
    nac.longitud,
    col.nombre AS colonia,
    al.nombre AS alcaldia,
    ti.nombre AS tipo_interseccion,
    COUNT(*) AS total_accidentes,
    SUM(nac.personas_lesionadas) AS total_lesionados,
    SUM(nac.personas_fallecidas) AS total_fallecidos
FROM normalization.accidente AS nac
LEFT JOIN normalization.interseccion_semaforizada AS isem
    ON nac.interseccion_semaforizada_id = isem.id
LEFT JOIN normalization.tipo_interseccion AS ti
    ON nac.tipo_interseccion_id = ti.id
LEFT JOIN normalization.colonia AS col
    ON nac.colonia_id = col.id
LEFT JOIN normalization.alcaldia AS al
    ON col.alcaldia_id = al.id
WHERE isem.nombre = 'no'
  AND nac.latitud IS NOT NULL
  AND nac.longitud IS NOT NULL
  AND nac.hora_evento IS NOT NULL
  AND (EXTRACT(HOUR FROM nac.hora_evento) >= 19
       OR EXTRACT(HOUR FROM nac.hora_evento) < 7)
GROUP BY nac.latitud, nac.longitud, col.nombre, al.nombre, ti.nombre
ORDER BY total_accidentes DESC
LIMIT 20;
