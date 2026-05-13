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
    ise.nombre AS interseccion_semaforizada,
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
    ON nac.interseccion_semaforizada_id = ise.id
GROUP BY al.nombre, cv.nombre, ti.nombre, ise.nombre
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
    ise.nombre AS interseccion_semaforizada,
    COUNT(*) AS total_accidentes,
    SUM(nac.personas_lesionadas) AS total_lesionados,
    SUM(nac.personas_fallecidas) AS total_fallecidos
FROM normalization.accidente AS nac
LEFT JOIN normalization.interseccion_semaforizada AS ise
    ON nac.interseccion_semaforizada_id = ise.id
GROUP BY ise.nombre
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