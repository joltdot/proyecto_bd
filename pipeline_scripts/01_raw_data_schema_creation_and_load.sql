-- Eliminar esquema previo si existe (refresh destructivo)
DROP SCHEMA IF EXISTS raw CASCADE;

-- Crear esquema
CREATE SCHEMA raw;

-- Crear tabla de datos en bruto
CREATE TABLE raw.datos_transitocdmx (
    
    fecha_evento DATE, 
    hora_evento TIME, 
    tipo_evento TEXT,
    fecha_captura DATE,
    folio TEXT,

    latitud DOUBLE PRECISION,
    longitud DOUBLE PRECISION,

    punto_1 TEXT,
    punto_2 TEXT,
    colonia TEXT, 
    alcaldia TEXT, 

    zona_vial INT,
    sector TEXT, 
    unidad_a_cargo TEXT, 

    tipo_de_interseccion TEXT,
    interseccion_semaforizada TEXT, 
    clasificacion_de_la_vialidad TEXT,
    sentido_de_circulacion TEXT, 

    dia TEXT, 
    prioridad TEXT,
    origen TEXT,

    unidad_medica_de_apoyo TEXT,
    matricula_unidad_medica TEXT, 
    trasladado_lesionados TEXT,

    personas_fallecidas INT,
    personas_lesionadas INT
);

-- Asegurar encoding correcto
SET CLIENT_ENCODING TO 'UTF8';

-- Cargar datos desde CSV
\COPY raw.datos_transitocdmx (fecha_evento,hora_evento,tipo_evento,fecha_captura,folio,latitud,longitud,punto_1,punto_2,colonia,alcaldia,zona_vial,sector, unidad_a_cargo, tipo_de_interseccion, interseccion_semaforizada, clasificacion_de_la_vialidad, sentido_de_circulacion, dia, prioridad, origen, unidad_medica_de_apoyo, matricula_unidad_medica, trasladado_lesionados, personas_fallecidas, personas_lesionadas ) FROM './data/raw_data.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', NULL 'NA');