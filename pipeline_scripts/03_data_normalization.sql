   --SETUP

DROP SCHEMA IF EXISTS normalization CASCADE;
CREATE SCHEMA normalization;

   --Tabla: alcaldía

CREATE TABLE normalization.alcaldia (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

INSERT INTO normalization.alcaldia (nombre)
SELECT DISTINCT TRIM(LOWER(alcaldia))
FROM clean.datos_transitocdmx
WHERE alcaldia IS NOT NULL;

   --Tabla: colonia

CREATE TABLE normalization.colonia (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    alcaldia_id BIGINT NOT NULL,
    UNIQUE (nombre, alcaldia_id),
    FOREIGN KEY (alcaldia_id) REFERENCES normalization.alcaldia(id)
);

INSERT INTO normalization.colonia (nombre, alcaldia_id)
SELECT DISTINCT
    TRIM(LOWER(d.colonia)),
    a.id
FROM clean.datos_transitocdmx d
JOIN normalization.alcaldia a
    ON TRIM(LOWER(d.alcaldia)) = a.nombre
WHERE d.colonia IS NOT NULL;

   --Tabla: tipo de evento (dimensiones simples)

CREATE TABLE normalization.tipo_evento (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO normalization.tipo_evento (nombre)
SELECT DISTINCT TRIM(LOWER(tipo_evento))
FROM clean.datos_transitocdmx
WHERE tipo_evento IS NOT NULL;

	--Tabla: origen 
CREATE TABLE normalization.origen (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO normalization.origen (nombre)
SELECT DISTINCT TRIM(LOWER(origen))
FROM clean.datos_transitocdmx
WHERE origen IS NOT NULL;

	--Tabla: sector
CREATE TABLE normalization.sector (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

INSERT INTO normalization.sector (nombre)
SELECT DISTINCT TRIM(LOWER(sector))
FROM clean.datos_transitocdmx
WHERE sector IS NOT NULL;

	--Tabla: tipo_intersección
CREATE TABLE normalization.tipo_interseccion (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO normalization.tipo_interseccion (nombre)
SELECT DISTINCT TRIM(LOWER(tipo_de_interseccion))
FROM clean.datos_transitocdmx
WHERE tipo_de_interseccion IS NOT NULL;

	--Tabla: clasificacion_vialidad
CREATE TABLE normalization.clasificacion_vialidad (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

INSERT INTO normalization.clasificacion_vialidad (nombre)
SELECT DISTINCT TRIM(LOWER(clasificacion_de_la_vialidad))
FROM clean.datos_transitocdmx
WHERE clasificacion_de_la_vialidad IS NOT NULL;

	--Tabla: sentido de circulacion
CREATE TABLE normalization.sentido_circulacion (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO normalization.sentido_circulacion (nombre)
SELECT DISTINCT TRIM(LOWER(sentido_de_circulacion))
FROM clean.datos_transitocdmx
WHERE sentido_de_circulacion IS NOT NULL;

/*
   --Tabla: vialidad

CREATE TABLE normalization.vialidad (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE
);

INSERT INTO normalization.vialidad (nombre)
SELECT DISTINCT TRIM(LOWER(nombre))
FROM (
    SELECT punto_1 AS nombre FROM clean.datos_transitocdmx
    UNION
    SELECT punto_2 FROM clean.datos_transitocdmx
) 
WHERE nombre IS NOT NULL;
*/

   	--Intersección semaforizada

CREATE TABLE normalization.interseccion_semaforizada (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(5) NOT NULL UNIQUE
);

INSERT INTO normalization.interseccion_semaforizada (nombre)
SELECT DISTINCT TRIM(LOWER(interseccion_semaforizada))
FROM clean.datos_transitocdmx
WHERE interseccion_semaforizada IS NOT NULL;


	--Tabla: accidente

DROP TABLE IF EXISTS normalization.accidente CASCADE;

CREATE TABLE normalization.accidente (
    id BIGSERIAL PRIMARY KEY,

    latitud NUMERIC,
    longitud NUMERIC,

    fecha_evento DATE,
    hora_evento TIME,
    fecha_captura DATE,

    personas_fallecidas INTEGER,
    personas_lesionadas INTEGER,

    prioridad VARCHAR(20),
    trasladado_lesionados VARCHAR(5),

    colonia_id BIGINT,
    tipo_evento_id BIGINT,
    origen_id BIGINT,
    sector_id BIGINT,
    tipo_interseccion_id BIGINT,
    clasificacion_vialidad_id BIGINT,
    sentido_circulacion_id BIGINT,
    interseccion_semaforizada_id BIGINT,

    FOREIGN KEY (colonia_id)
        REFERENCES normalization.colonia(id),

    FOREIGN KEY (tipo_evento_id)
        REFERENCES normalization.tipo_evento(id),

    FOREIGN KEY (origen_id)
        REFERENCES normalization.origen(id),

    FOREIGN KEY (sector_id)
        REFERENCES normalization.sector(id),

    FOREIGN KEY (tipo_interseccion_id)
        REFERENCES normalization.tipo_interseccion(id),

    FOREIGN KEY (clasificacion_vialidad_id)
        REFERENCES normalization.clasificacion_vialidad(id),

    FOREIGN KEY (sentido_circulacion_id)
        REFERENCES normalization.sentido_circulacion(id),

    FOREIGN KEY (interseccion_semaforizada_id)
        REFERENCES normalization.interseccion_semaforizada(id)
);


INSERT INTO normalization.accidente (
    latitud,
    longitud,
    fecha_evento,
    hora_evento,
    fecha_captura,

    personas_fallecidas,
    personas_lesionadas,

    prioridad,
    trasladado_lesionados,

    colonia_id,
    tipo_evento_id,
    origen_id,
    sector_id,
    tipo_interseccion_id,
    clasificacion_vialidad_id,
    sentido_circulacion_id,
    interseccion_semaforizada_id
)

SELECT
    d.latitud,
    d.longitud,
    d.fecha_evento,
    d.hora_evento,
    d.fecha_captura,

    d.personas_fallecidas,
    d.personas_lesionadas,

    d.prioridad,
    d.trasladado_lesionados,

    c.id,
    t.id,
    o.id,
    s.id,
    ti.id,
    cv.id,
    sc.id,
    isem.id

FROM clean.datos_transitocdmx d

LEFT JOIN normalization.alcaldia a
    ON TRIM(LOWER(d.alcaldia)) = a.nombre

LEFT JOIN normalization.colonia c
    ON TRIM(LOWER(d.colonia)) = c.nombre
   AND c.alcaldia_id = a.id

LEFT JOIN normalization.tipo_evento t
    ON TRIM(LOWER(d.tipo_evento)) = t.nombre

LEFT JOIN normalization.origen o
    ON TRIM(LOWER(d.origen)) = o.nombre

LEFT JOIN normalization.sector s
    ON TRIM(LOWER(d.sector)) = s.nombre

LEFT JOIN normalization.tipo_interseccion ti
    ON TRIM(LOWER(d.tipo_de_interseccion)) = ti.nombre

LEFT JOIN normalization.clasificacion_vialidad cv
    ON TRIM(LOWER(d.clasificacion_de_la_vialidad)) = cv.nombre

LEFT JOIN normalization.sentido_circulacion sc
    ON TRIM(LOWER(d.sentido_de_circulacion)) = sc.nombre

LEFT JOIN normalization.interseccion_semaforizada isem
    ON TRIM(LOWER(d.interseccion_semaforizada)) = isem.nombre;


--PRUEBA

SELECT COUNT(*)
FROM normalization.accidente;