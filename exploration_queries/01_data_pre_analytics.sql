-- Análisis exploratorio de los datos.


-- Conteo total de registros
SELECT COUNT(*) AS total_registros
FROM raw.datos_transitocdmx;



-- Conteo de valores únicos


SELECT 'folio' AS columna, COUNT(DISTINCT folio) AS valores_unicos
FROM raw.datos_transitocdmx

UNION ALL

SELECT 'tipo_evento', COUNT(DISTINCT tipo_evento)
FROM raw.datos_transitocdmx

UNION ALL

SELECT 'alcaldia', COUNT(DISTINCT alcaldia)
FROM raw.datos_transitocdmx

UNION ALL

SELECT 'colonia', COUNT(DISTINCT colonia)
FROM raw.datos_transitocdmx

UNION ALL

SELECT 'sector', COUNT(DISTINCT sector)
FROM raw.datos_transitocdmx

UNION ALL

SELECT 'origen', COUNT(DISTINCT origen)
FROM raw.datos_transitocdmx

ORDER BY valores_unicos DESC;

-- Ver si folio funciona como llave 
SELECT folio, COUNT(*) AS repeticiones
FROM raw.datos_transitocdmx
WHERE folio IS NOT NULL AND TRIM(folio) != ''
GROUP BY folio
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC;


-- Mínimos y máximos de fechas
SELECT
    MIN(fecha_evento) AS fecha_evento_minima,
    MAX(fecha_evento) AS fecha_evento_maxima
FROM raw.datos_transitocdmx;




-- Mínimos, máximos y promedios de valores numéricos
SELECT
    MIN(zona_vial) AS zona_vial_minima,
    MAX(zona_vial) AS zona_vial_maxima,
    AVG(zona_vial) AS zona_vial_promedio,

    MIN(personas_fallecidas) AS fallecidas_minimo,
    MAX(personas_fallecidas) AS fallecidas_maximo,
    AVG(personas_fallecidas) AS fallecidas_promedio,

    MIN(personas_lesionadas) AS lesionadas_minimo,
    MAX(personas_lesionadas) AS lesionadas_maximo,
    AVG(personas_lesionadas) AS lesionadas_promedio
FROM raw.datos_transitocdmx;


--  Conteo de eventos por tipo
SELECT
    tipo_evento,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY tipo_evento
ORDER BY total DESC;


--  Conteo de eventos por alcaldía
SELECT
    alcaldia,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY alcaldia
ORDER BY total DESC;


--  Conteo de eventos por día
SELECT
    dia,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY dia
ORDER BY total DESC;


--  Conteo por prioridad
SELECT
    prioridad,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY prioridad
ORDER BY total DESC;


-- Conteo por origen del reporte
SELECT
    origen,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY origen
ORDER BY total DESC;


-- Conteo por traslado de lesionados
SELECT
    trasladado_lesionados,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY trasladado_lesionados
ORDER BY total DESC;


--  Duplicados en atributos categóricos 

SELECT
    zona_vial AS zona_pura,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY zona_vial
ORDER BY total DESC;

SELECT
    LOWER(TRIM(tipo_evento)) AS tipo_evento_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(tipo_evento))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(tipo_de_interseccion)) AS interseccion_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(tipo_de_interseccion))
ORDER BY total DESC;


SELECT
    LOWER(TRIM(clasificacion_de_la_vialidad)) AS clasificacion_vial_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(clasificacion_de_la_vialidad))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(sentido_de_circulacion)) AS sentido_de_circulacion_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(sentido_de_circulacion))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(dia)) AS dia_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(dia))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(prioridad)) AS prioridad_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(prioridad))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(origen)) AS origen_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(origen))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(trasladado_lesionados)) AS trasladado_lesionados_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(trasladado_lesionados))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(unidad_medica_de_apoyo)) AS unidad_medica_de_apoyo_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(unidad_medica_de_apoyo))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(alcaldia)) AS alcaldia_pura,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(alcaldia))
ORDER BY total DESC;


SELECT
    LOWER(TRIM(colonia)) AS colonia_pura,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(colonia))
ORDER BY total DESC;

SELECT
    LOWER(TRIM(sector)) AS sector_puro,
    COUNT(*) AS total
FROM raw.datos_transitocdmx
GROUP BY LOWER(TRIM(sector))
ORDER BY total DESC;

-- 16. Filas posiblemente duplicadas
SELECT
    fecha_evento,
    hora_evento,
    tipo_evento,
    folio,
    latitud,
    longitud,
    alcaldia,
    COUNT(*) AS repeticiones
FROM raw.datos_transitocdmx
GROUP BY
    fecha_evento,
    hora_evento,
    tipo_evento,
    folio,
    latitud,
    longitud,
    alcaldia
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC;


-- Conteo de nulos por atributo

SELECT 'fecha_evento' AS columna, COUNT(*) AS nulos
FROM raw.datos_transitocdmx
WHERE fecha_evento IS NULL

UNION ALL

SELECT 'hora_evento', COUNT(*)
FROM raw.datos_transitocdmx
WHERE hora_evento IS NULL OR TRIM(hora_evento) = ''
-- Las variables tipo TEXT pueden contener espacios vacíos.

UNION ALL

SELECT 'tipo_evento', COUNT(*)
FROM raw.datos_transitocdmx
WHERE tipo_evento IS NULL OR TRIM(tipo_evento) = ''

UNION ALL

SELECT 'fecha_captura', COUNT(*)
FROM raw.datos_transitocdmx
WHERE fecha_captura IS NULL OR TRIM(fecha_captura) = ''

UNION ALL

SELECT 'folio', COUNT(*)
FROM raw.datos_transitocdmx
WHERE folio IS NULL OR TRIM(folio) = ''

UNION ALL

SELECT 'latitud', COUNT(*)
FROM raw.datos_transitocdmx
WHERE latitud IS NULL OR TRIM(latitud) = ''

UNION ALL

SELECT 'longitud', COUNT(*)
FROM raw.datos_transitocdmx
WHERE longitud IS NULL OR TRIM(longitud) = ''

UNION ALL

SELECT 'punto_1', COUNT(*)
FROM raw.datos_transitocdmx
WHERE punto_1 IS NULL OR TRIM(punto_1) = ''

UNION ALL

SELECT 'punto_2', COUNT(*)
FROM raw.datos_transitocdmx
WHERE punto_2 IS NULL OR TRIM(punto_2) = ''

UNION ALL

SELECT 'colonia', COUNT(*)
FROM raw.datos_transitocdmx
WHERE colonia IS NULL OR TRIM(colonia) = ''

UNION ALL

SELECT 'alcaldia', COUNT(*)
FROM raw.datos_transitocdmx
WHERE alcaldia IS NULL OR TRIM(alcaldia) = ''

UNION ALL

SELECT 'zona_vial', COUNT(*)
FROM raw.datos_transitocdmx
WHERE zona_vial IS NULL

UNION ALL

SELECT 'sector', COUNT(*)
FROM raw.datos_transitocdmx
WHERE sector IS NULL OR TRIM(sector) = ''

UNION ALL

SELECT 'unidad_a_cargo', COUNT(*)
FROM raw.datos_transitocdmx
WHERE unidad_a_cargo IS NULL OR TRIM(unidad_a_cargo) = ''

UNION ALL

SELECT 'tipo_de_interseccion', COUNT(*)
FROM raw.datos_transitocdmx
WHERE tipo_de_interseccion IS NULL OR TRIM(tipo_de_interseccion) = ''

UNION ALL

SELECT 'interseccion_semaforizada', COUNT(*)
FROM raw.datos_transitocdmx
WHERE interseccion_semaforizada IS NULL OR TRIM(interseccion_semaforizada) = ''

UNION ALL

SELECT 'clasificacion_de_la_vialidad', COUNT(*)
FROM raw.datos_transitocdmx
WHERE clasificacion_de_la_vialidad IS NULL OR TRIM(clasificacion_de_la_vialidad) = ''

UNION ALL

SELECT 'sentido_de_circulacion', COUNT(*)
FROM raw.datos_transitocdmx
WHERE sentido_de_circulacion IS NULL OR TRIM(sentido_de_circulacion) = ''

UNION ALL

SELECT 'dia', COUNT(*)
FROM raw.datos_transitocdmx
WHERE dia IS NULL OR TRIM(dia) = ''

UNION ALL

SELECT 'prioridad', COUNT(*)
FROM raw.datos_transitocdmx
WHERE prioridad IS NULL OR TRIM(prioridad) = ''

UNION ALL

SELECT 'origen', COUNT(*)
FROM raw.datos_transitocdmx
WHERE origen IS NULL OR TRIM(origen) = ''

UNION ALL

SELECT 'unidad_medica_de_apoyo', COUNT(*)
FROM raw.datos_transitocdmx
WHERE unidad_medica_de_apoyo IS NULL OR TRIM(unidad_medica_de_apoyo) = ''

UNION ALL

SELECT 'matricula_unidad_medica', COUNT(*)
FROM raw.datos_transitocdmx
WHERE matricula_unidad_medica IS NULL OR TRIM(matricula_unidad_medica) = ''

UNION ALL

SELECT 'trasladado_lesionados', COUNT(*)
FROM raw.datos_transitocdmx
WHERE trasladado_lesionados IS NULL OR TRIM(trasladado_lesionados) = ''

UNION ALL

SELECT 'personas_fallecidas', COUNT(*)
FROM raw.datos_transitocdmx
WHERE personas_fallecidas IS NULL

UNION ALL

SELECT 'personas_lesionadas', COUNT(*)
FROM raw.datos_transitocdmx
WHERE personas_lesionadas IS NULL

ORDER BY nulos DESC;



-- Inconsistencias numéricas
-- Personas fallecidas o lesionadas negativas
SELECT *
FROM raw.datos_transitocdmx
WHERE personas_fallecidas < 0
   OR personas_lesionadas < 0;


-- Accidentes con fallecidos o lesionados pero sin tipo de evento
SELECT *
FROM raw.datos_transitocdmx
WHERE (personas_fallecidas > 0 OR personas_lesionadas > 0)
  AND (tipo_evento IS NULL OR TRIM(tipo_evento) = '');


-- Registros sin ubicación
SELECT *
FROM raw.datos_transitocdmx
WHERE latitud IS NULL
   OR longitud IS NULL;


-- Fechas de captura inconsistentes

SELECT fecha_captura, COUNT(*) AS total
FROM raw.datos_transitocdmx
WHERE fecha_captura < fecha_evento;
