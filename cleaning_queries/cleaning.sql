--Creamos esquema para limpiar los datos

CREATE SCHEMA clean;

--Duplicamos la tabla raw
CREATE TABLE clean.datos_transitocdmx (LIKE raw.datos_transitocdmx INCLUDING ALL);
INSERT INTO clean.datos_transitocdmx SELECT * from raw.datos_transitocdmx;

select *
from clean.datos_transitocdmx;

SELECT *
FROM clean.datos_transitocdmx
WHERE id = 1;

--Hacer todos los días mayúsculas
UPDATE clean.datos_transitocdmx
SET dia = UPPER(dia);

--Quitar espacios vacíos en dia
UPDATE clean.datos_transitocdmx
SET dia = TRIM(dia);

--En dia hay inconsistencias de tildes y hay días que no existen como S<c3>érco, Calzada Taxqueña,etc...

SELECT DISTINCT dia
from clean.datos_transitocdmx;


UPDATE clean.datos_transitocdmx
SET dia = 'SABADO'
WHERE dia IN ('SÁBADO', 'MÁBADO');

UPDATE clean.datos_transitocdmx
SET dia = 'MIERCOLES'
WHERE dia IN ('S<C3>ÉRCO', 'SIÉRCO', 'MIÉRCO', 'MIÉRCOLES');

UPDATE clean.datos_transitocdmx
SET dia = NULL
WHERE dia NOT IN ('DOMINGO', 'SABADO','JUEVES','MARTES','MIERCOLES','VIERNES','LUNES');

--En origen hay datos raros como sábado, inconsistencias por tildes en las palabras policía, cámara y botón. Dice MI C4LLE en vez de MI CALLE
SELECT DISTINCT origen
FROM clean.datos_transitocdmx;
    --Reemplazo las tildes
UPDATE clean.datos_transitocdmx
SET origen = translate(origen, 'ÁÉÍÓÚ', 'AEIOU');


--Inconsistencias y datos raros en tipo_interseccion
--Clasificacion de la vialidad hay eje vial y ejevial
--sentido de circulación y unidad medica

