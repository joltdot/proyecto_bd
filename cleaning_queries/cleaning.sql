--Creamos esquema para limpiar los datos
CREATE SCHEMA clean;

--Duplicamos la tabla raw
CREATE TABLE clean.datos_transitocdmx
(
    LIKE raw.datos_transitocdmx INCLUDING ALL
);
INSERT INTO clean.datos_transitocdmx
SELECT *
from raw.datos_transitocdmx;

select *
from clean.datos_transitocdmx;

SELECT *
FROM clean.datos_transitocdmx;

--Hacer todos los días mayúsculas
UPDATE clean.datos_transitocdmx
SET dia = UPPER(dia);

--Quitar espacios vacíos en dia
UPDATE clean.datos_transitocdmx
SET dia = TRIM(dia);

--El dia ya esta implicito en los atributos de fecha y no es necesario almacenarlo de manera independiente

ALTER TABLE clean.datos_transitocdmx
    DROP COLUMN dia;


--En origen hay datos raros como sábado, inconsistencias por tildes en las palabras policía, cámara y botón. Dice MI C4LLE en vez de MI CALLE
SELECT DISTINCT origen
FROM clean.datos_transitocdmx;
--Reemplazo las tildes
UPDATE clean.datos_transitocdmx
SET origen = TRANSLATE(origen, 'ÁÉÍÓÚ', 'AEIOU');


--Inconsistencias y datos raros en tipo_interseccion


select distinct tipo_de_interseccion, count(tipo_de_interseccion)
FROM clean.datos_transitocdmx
group by tipo_de_interseccion;

--Una interseccion decia AJUSCO, buscamos las calles y vimos que es interseccion tipo T
UPDATE clean.datos_transitocdmx
SET tipo_de_interseccion = 'T'
WHERE tipo_de_interseccion LIKE 'AJUSCO';

SELECT *
    from clean.datos_transitocdmx
        where tipo_de_interseccion LIKE 'CRUZO';

--Otra interseccion decía CRUZO en vez de CRUZ (verificamos con Maps)

    START TRANSACTION;
UPDATE clean.datos_transitocdmx
    SET tipo_de_interseccion = 'CRUZ'
WHERE tipo_de_interseccion = 'CRUZO';
COMMIT;

--Clasificacion de la vialidad hay eje vial y ejevial

--Corregir formato dia-mes invertido




--En algunos casos, mes y dia estaban intercambiados
UPDATE clean.datos_transitocdmx
SET fecha_captura =  make_date(
    EXTRACT(YEAR FROM fecha_captura)::int,
    EXTRACT(DAY FROM fecha_captura)::int, -- Day becomes Month
    EXTRACT(MONTH FROM fecha_captura)::int -- Month becomes Day
)
  WHERE fecha_captura<fecha_evento
AND NOT extract(DAY FROM fecha_captura) >12;

--Despues de arreglar mes y dia, vimos que el año de algunas tuplas en fecha_captura era incorrecto entonces lo cambiamos
UPDATE clean.datos_transitocdmx
    SET fecha_captura = make_date(2019,
                        EXTRACT(MONTH FROM fecha_captura)::int,
                        EXTRACT(DAY FROM fecha_captura)::int)
WHERE fecha_captura<fecha_evento
AND NOT extract(DAY FROM fecha_captura) >12
AND fecha_captura = '2018-01-04';

--Por ultimo, quedaban 4 tuplas con fecha_captura y fecha_evento intercambiados

UPDATE clean.datos_transitocdmx
SET fecha_captura =  fecha_evento,
    fecha_evento = fecha_captura
WHERE fecha_captura<fecha_evento
AND NOT extract(DAY FROM fecha_captura) >12;


START TRANSACTION;
ROLLBACK;
Commit;

SELECT id, fecha_evento,
       fecha_captura
FROM clean.datos_transitocdmx
    WHERE fecha_captura<fecha_evento
    AND extract(DAY FROM fecha_captura) >12
;

--Quedaban 4 donde fecha_captura, fecha_evento están flipeados
UPDATE clean.datos_transitocdmx
SET fecha_captura =  fecha_evento,
    fecha_evento = fecha_captura
WHERE fecha_captura<fecha_evento;
--unidad medica

--Nullificar sentidos de circulación ambiguos y corregir Typo

UPDATE clean.datos_transitocdmx
SET sentido_de_circulacion = 'P-O'
WHERE sentido_de_circulacion LIKE 'P O';

UPDATE clean.datos_transitocdmx
SET sentido_de_circulacion = NULL
WHERE sentido_de_circulacion IN ('N', 'NO', 'PO');

SELECT *
FROM clean.datos_transitocdmx
WHERE sentido_de_circulacion LIKE 'PO';

-- Contexto
SELECT alcaldia,
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
