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


--
--Ignorar por ahora
-- UPDATE clean.datos_transitocdmx
-- SET colonia = c.nomdt
-- FROM clean.colonia_geometria AS c
-- WHERE ST_Within(clean.datos_transitocdmx.geom, c.geom);
--
-- WITH  geometrias AS (
--     SELECT geom
--     FROM clean.colonia_geometria
-- )
-- SELECT *
-- FROM clean.datos_transitocdmx
-- WHERE NOT ST_Within(clean.datos_transitocdmx.geom, geometrias.geom);
--
-- SELECT DISTINCT colonia
-- FROM clean.datos_transitocdmx;
