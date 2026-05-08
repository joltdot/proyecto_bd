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

--El dia ya esta implicito en los atributos de fecha y no es necesario almacenarlo de manera independiente

ALTER TABLE clean.datos_transitocdmx DROP COLUMN dia;


--En origen hay datos raros como sábado, inconsistencias por tildes en las palabras policía, cámara y botón. Dice MI C4LLE en vez de MI CALLE
SELECT DISTINCT origen
FROM clean.datos_transitocdmx;
    --Reemplazo las tildes
UPDATE clean.datos_transitocdmx
SET origen = TRANSLATE(origen, 'ÁÉÍÓÚ', 'AEIOU');


--Inconsistencias y datos raros en tipo_interseccion
--Clasificacion de la vialidad hay eje vial y ejevial
--sentido de circulación y unidad medica

-- Contexto
SELECT
    alcaldia,
    COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY alcaldia
ORDER BY total DESC;

SELECT colonia
FROM clean.datos_transitocdmx
WHERE alcaldia = 'AV INSURGENTES';

-- Gustavo A Madero está repetido
UPDATE clean.datos_transitocdmx
SET alcaldia = 'GUSTAVO A MADERO'
WHERE alcaldia = 'GUSTAVO A. MADERO';
-- Un caso donde Av Insurgentes se cuenta como alcaldía (checar la primer exploration query)
UPDATE clean.datos_transitocdmx
SET alcaldia = 'CUAUHTEMOC'
WHERE alcaldia = 'AV INSURGENTES';
