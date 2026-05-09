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

SELECT * FROM clean.datos_transitocdmx;


-- DEPURACIÓN DE CADA ATRIBUTO 

-- ELIMINACIÓN DE ATRIBUTOS REPETITIVOS 
--El dia ya esta implicito en los atributos de fecha y no es necesario almacenarlo de manera independiente

ALTER TABLE clean.datos_transitocdmx
    DROP COLUMN dia;
    


--DEPURACIÓN DE ATRIBUTOS SUCIOS

-- ATRIBUTO: ORIGEN
--En origen hay datos raros como sábado, inconsistencias por tildes en las palabras policía, cámara y botón. Dice MI C4LLE en vez de MI CALLE
SELECT DISTINCT origen
FROM clean.datos_transitocdmx;

--Reemplazo las tildes
UPDATE clean.datos_transitocdmx
SET origen = TRANSLATE(origen, 'ÁÉÍÓÚ', 'AEIOU');

--Reemplazo de categorías sin sentido a NA (ejemplo: sabado, pm )
UPDATE clean.datos_transitocdmx
SET origen = NULL
WHERE origen IN ('NA', 'N/A', 'SD', '', 'sábado', 'PM');

-- Homologar la categoría 911: pues hay variantes inecesarias como "911CDMX" o "LLAMADA A 911"
UPDATE clean.datos_transitocdmx
SET origen = 'BOTON DE AUXILIO'
WHERE origen IN ('BOTÓN DE AUXILIO','BOTON DE AUXILIO','MI CALLE(BOTON)','MI C911E', 'MI CALLE'); --DOMDOM: LO QUE ENTENDÍ ES QUE CUANDO DICEN MI CALLE SE REFIERE AL BOTON ASI QUE HOMOLOGUE

-- Homologar variantes de camara / cámara
UPDATE clean.datos_transitocdmx
SET origen = 'CAMARA'
WHERE origen IN ('CÁMARA','CAMARA');

-- Homologar variantes relacionadas con 911.
-- Aquí dejamos LLAMADA DEL 911 separada de 911 CDMX, porque la llamada pudo realizarse fuera de la ciudad.
UPDATE clean.datos_transitocdmx
SET origen = '911 CDMX'
WHERE origen IN ('911CDMX','APP 911CDMX','911 CDMX CHAT');


-- Homologar redes sociales.
UPDATE clean.datos_transitocdmx
SET origen = 'REDES SOCIALES'
WHERE origen IN ('REDES','REDES SOCIALES');


-- Homologar errores por tilde en policía.
UPDATE clean.datos_transitocdmx
SET origen = 'MI POLICIA NEGOCIO'
WHERE origen IN ('MI POLICIA NEGOCIO','MI POLICÍA NEGOCIO');


-- Verificación (sirve para ver si la columna de origen está limpia
SELECT origen, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY origen
ORDER BY total DESC;



--Inconsistencias y datos raros en tipo_interseccion

--Una interseccion decia AJUSCO, buscamos las calles y vimos que es interseccion tipo T
UPDATE clean.datos_transitocdmx
SET tipo_de_interseccion = 'T'
WHERE tipo_de_interseccion LIKE 'AJUSCO';

--Otra interseccion decía CRUZO en vez de CRUZ (verificamos con Maps)

UPDATE clean.datos_transitocdmx
    SET tipo_de_interseccion = 'CRUZ'
WHERE tipo_de_interseccion = 'CRUZO';

-- Finalmente, renombramos para mayor facilidad de trabajo con esta columna ya que no hay problema de interpretación
ALTER TABLE clean.datos_transitocdmx RENAME COLUMN tipo_de_interseccion TO interseccion;

--Clasificacion de la vialidad hay eje vial y ejevial

UPDATE clean.datos_transitocdmx
    SET clasificacion_de_la_vialidad = 'EJE VIAL'
    WHERE clasificacion_de_la_vialidad = 'EJEVIAL';

-- Finalmente, renombramos para mayor facilidad de trabajo con esta columna ya que no hay problema de interpretación
ALTER TABLE clean.datos_transitocdmx RENAME COLUMN clasificacion_de_la_vialidad TO vialidad;


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

--Quedaban 4 donde fecha_captura, fecha_evento están flipeados
UPDATE clean.datos_transitocdmx
SET fecha_captura =  fecha_evento,
    fecha_evento = fecha_captura
WHERE fecha_captura<fecha_evento;

--unidad medica

ALTER TABLE clean.datos_transitocdmx
DROP COLUMN matricula_unidad_medica;


--Nullificar sentidos de circulación ambiguos y corregir Typo

UPDATE clean.datos_transitocdmx
SET sentido_de_circulacion = 'P-O'
WHERE sentido_de_circulacion LIKE 'P O';

UPDATE clean.datos_transitocdmx
SET sentido_de_circulacion = NULL
WHERE sentido_de_circulacion IN ('N', 'NO', 'PO');

-- Gustavo A Madero está repetido
UPDATE clean.datos_transitocdmx
SET alcaldia = 'GUSTAVO A MADERO'
WHERE alcaldia = 'GUSTAVO A. MADERO';
-- Un caso donde Av Insurgentes se cuenta como alcaldía (checar la primer exploration query)
UPDATE clean.datos_transitocdmx
SET alcaldia = 'CUAUHTEMOC'
WHERE alcaldia = 'AV INSURGENTES';
