--Creamos esquema para limpiar los datos
DROP SCHEMA IF EXISTS clean CASCADE;
CREATE SCHEMA clean;

--Duplicamos la tabla raw
CREATE TABLE clean.datos_transitocdmx
(
    LIKE raw.datos_transitocdmx INCLUDING ALL
);
INSERT INTO clean.datos_transitocdmx
SELECT *
from raw.datos_transitocdmx;

-- DEPURACIÓN DE CADA ATRIBUTO 

-- ELIMINACIÓN DE ATRIBUTOS REPETITIVOS 
--El dia ya esta implicito en los atributos de fecha y no es necesario almacenarlo de manera independiente

ALTER TABLE clean.datos_transitocdmx
    DROP COLUMN dia;
    
--UNIDAD MEDICA: Funciona más como identificador operativo interno que como variable analítica por ello no se tomará en cuenta.

ALTER TABLE clean.datos_transitocdmx
DROP COLUMN matricula_unidad_medica;

--FOLIO: No funciona como llave primaria (7,288 registros con "SD" y folios repetidos). Es un identificador administrativo que no aporta al análisis de patrones de accidentalidad.

ALTER TABLE clean.datos_transitocdmx
DROP COLUMN folio;
    
-- FOLIO: El valor de este atributo no contribuye al análisis del proyecto.
ALTER TABLE clean.datos_transitocdmx
DROP COLUMN folio;


--DEPURACIÓN DE ATRIBUTOS SUCIOS

-- ATRIBUTO: origen
-- Verificación (sirve para ver si la columna de origen está limpia)
SELECT origen, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY origen
ORDER BY total DESC;

--En origen hay datos raros como sábado, inconsistencias por tildes en las palabras policía, cámara y botón. Dice MI C4LLE en vez de MI CALLE

--LIMPIEZA GENERAL DE DATOS
--Borramos espacios innecesarios y pasamos todo a mayúsculas
UPDATE clean.datos_transitocdmx
SET origen = UPPER(TRIM(origen));

-- Homologar variantes con tilde
UPDATE clean.datos_transitocdmx
SET origen = 'POLICIA'
WHERE origen = 'POLICÍA';

UPDATE clean.datos_transitocdmx
SET origen = 'CAMARA'
WHERE origen = 'CÁMARA';

-- Homologar variantes relacionadas con 911.
-- Aquí dejamos LLAMADA DEL 911 separada de 911 CDMX.
START TRANSACTION;
UPDATE clean.datos_transitocdmx
SET origen = '911 CDMX'
WHERE origen ILIKE '%911%';
COMMIT;


-- Homologar la categoría botón ya que mi calle es de acuerdo a los datos parte de la categiría de botón de auxilio
START TRANSACTION;
UPDATE clean.datos_transitocdmx
SET origen = 'BOTON DE AUXILIO'
WHERE origen ILIKE '%BOTON%'
   OR origen ILIKE '%BOTÓN%'
   OR origen ILIKE '%AUXILIO%';
COMMIT;

-- Homologar redes sociales.
UPDATE clean.datos_transitocdmx
SET origen = 'REDES SOCIALES'
WHERE origen IN ('REDES','REDES SOCIALES');


--Reemplazo de categorías sin sentido a NULL (ejemplo: sabado)
START TRANSACTION;
UPDATE clean.datos_transitocdmx
SET origen = NULL
WHERE origen IS NOT NULL
AND origen ILIKE '%SABADO%';
COMMIT;
ROLLBACK;


-- Atributos que se mencionaron menos de 10 veces pasan a categoría de OTROS
-- No se nulearon valores como SD dado que pueda tratarse de algun acrónimo muy particular que represente una categoría válida para origen
START TRANSACTION;
UPDATE clean.datos_transitocdmx
SET origen = 'OTROS'
WHERE origen IN (
    SELECT origen
    FROM clean.datos_transitocdmx
    WHERE origen IS NOT NULL
    GROUP BY origen
    HAVING COUNT(*) < 10
);
COMMIT;
ROLLBACK;





-- ATRIBUTO : tipo_de_interseccion
-- Verificación (sirve para ver si la columna de tipo_de_interseccion está limpia)
SELECT tipo_de_interseccion, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY tipo_de_interseccion
ORDER BY total DESC;


--Una interseccion decia AJUSCO, buscamos las calles y vimos que es interseccion tipo T
UPDATE clean.datos_transitocdmx
SET tipo_de_interseccion = 'T'
WHERE tipo_de_interseccion LIKE 'AJUSCO';



--Otra interseccion decía CRUZO en vez de CRUZ (verificamos con Maps)
    START TRANSACTION;
UPDATE clean.datos_transitocdmx
    SET tipo_de_interseccion = 'CRUZ'
WHERE tipo_de_interseccion = 'CRUZO';
COMMIT;






-- ATRIBUTO: clasificacion_de_la_vialidad 
-- Verificación (sirve para ver si la columna de clasificacion_de_la_vialidad está limpia)
SELECT clasificacion_de_la_vialidad, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY clasificacion_de_la_vialidad
ORDER BY total DESC;

-- Homologar eje vial y ejevial

UPDATE clean.datos_transitocdmx
    SET clasificacion_de_la_vialidad = 'EJE VIAL'
    WHERE clasificacion_de_la_vialidad = 'EJEVIAL';
    
   

-- ATRIBUTO: fecha_captura
-- Verificación (sirve para ver si la columna de fecha_captura está limpia)
SELECT fecha_captura, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY fecha_captura
ORDER BY total DESC;

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
WHERE fecha_captura::date<fecha_evento::date --los casteos solo son preventivos
AND NOT extract(DAY FROM fecha_captura) >12
AND fecha_captura = '2018-01-04';

--Por ultimo, quedaban 4 tuplas con fecha_captura y fecha_evento intercambiados

UPDATE clean.datos_transitocdmx
SET fecha_captura =  fecha_evento,
    fecha_evento = fecha_captura
WHERE fecha_captura<fecha_evento
AND NOT extract(DAY FROM fecha_captura) >12;


SELECT id, fecha_evento,
       fecha_captura
FROM clean.datos_transitocdmx
    WHERE fecha_captura<fecha_evento
    AND extract(DAY FROM fecha_captura) >12;

--Quedaban 4 donde fecha_captura, fecha_evento están flipeados
UPDATE clean.datos_transitocdmx
SET fecha_captura =  fecha_evento,
    fecha_evento = fecha_captura
WHERE fecha_captura<fecha_evento;



-- ATRIBUTO: interseccion_semaforizada
-- Verificación (sirve para ver si la columna de XXXX está limpia)
SELECT interseccion_semaforizada, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY interseccion_semaforizada
ORDER BY total DESC;

-- Homologar N como NO
UPDATE clean.datos_transitocdmx
SET interseccion_semaforizada =  'NO'
WHERE interseccion_semaforizada ILIKE '%N%';

-- ATRIBUTO: sentido_de_circulacion
-- Verificación (sirve para ver si la columna de sentido_de_circulacion está limpia)
SELECT sentido_de_circulacion, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY sentido_de_circulacion
ORDER BY total DESC;
   
   

--Nullificar sentidos de circulación ambiguos y corregir Typo
UPDATE clean.datos_transitocdmx
SET sentido_de_circulacion = 'P-O'
WHERE sentido_de_circulacion LIKE 'P O';

UPDATE clean.datos_transitocdmx
SET sentido_de_circulacion = NULL
WHERE sentido_de_circulacion IN ('N', 'NO', 'PO');


-- ATRIBUTO: alcaldia
-- Verificación (sirve para ver si la columna de alcaldia está limpia)
SELECT alcaldia, COUNT(*) AS total
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



-- ATRIBUTO: unidad_medica_de_apoyo
-- Verificación (sirve para ver si la columna de unidad_medica_de_apoyo está limpia)
SELECT zona_vial, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY zona_vial
ORDER BY total DESC;



SELECT DISTINCT unidad_a_cargo
FROM clean.datos_transitocdmx
WHERE unidad_a_cargo NOT SIMILAR TO ('%MX%');



-- ATRIBUTO: sector
-- Verificación (sirve para ver si la columna de sector está limpia)
SELECT sector, COUNT(*) AS total
FROM clean.datos_transitocdmx
GROUP BY sector
ORDER BY total DESC;

--LIMPIEZA GENERAL DE DATOS
--Borramos espacios innecesarios y pasamos todo a mayúsculas
UPDATE clean.datos_transitocdmx
SET sector = UPPER(TRIM(sector));

--Corregimos los typos observados de los sectores y los agrupamos a su correspondiente valor
START TRANSACTION;

UPDATE clean.datos_transitocdmx
SET sector = 'TLATELOLCO'
WHERE sector IN ('TLALTELOLCO', 'TLATALOLCO');

UPDATE clean.datos_transitocdmx
SET sector = 'ABASTO REFORMA'
WHERE sector IN (
    'ABASTOS REFORMA',
    'ABASTO-REFORMA',
    'REFORMA ABASTOS',
    'REFORMA ABASTO',
    'ABASTO/REFORMA',
    'BASTO REFORMA',
    'ABSTO REFORMA',
    'ABASTO REFORMS',
    'ABASTO REFROMA'
);

UPDATE clean.datos_transitocdmx
SET sector = 'NARVARTE ALAMOS'
WHERE sector IN (
    'NARVATE ALAMO',
    'NARVARTE ALAMO',
    'NARVATE ALAMOS', 'NARVANTE'
);

UPDATE clean.datos_transitocdmx
SET sector = 'HUIPULCO HOSPITALES'
WHERE sector IN (
    'HUIPULCO-HOSPITALES',
    'HIUPULCO HOSPITALES'
);

UPDATE clean.datos_transitocdmx
SET sector = 'IZTACCIHUATL'
WHERE sector IN (
    'IZTACCIHUAT',
    'IZTACCIHUAL',
    'IZACCIHUATL',
    'IZACIHUATL',
    'AZTACCIHUATL',
    'IZTACCIHIATL'
);

UPDATE clean.datos_transitocdmx
SET sector = 'PANTITLAN'
WHERE sector = 'PATITLAN';

UPDATE clean.datos_transitocdmx
SET sector = 'PLATEROS'
WHERE sector = 'PALTEROS';

UPDATE clean.datos_transitocdmx
SET sector = 'CLAVERIA'
WHERE sector = 'CALVERIA';

UPDATE clean.datos_transitocdmx
SET sector = 'COYOACAN'
WHERE sector = 'COYOACON';

UPDATE clean.datos_transitocdmx
SET sector = 'DEL VALLE'
WHERE sector = 'DEL VALE';

UPDATE clean.datos_transitocdmx
SET sector = 'BUENAVISTA'
WHERE sector = 'BUENA VISTA';

UPDATE clean.datos_transitocdmx
SET sector = 'PORTALES'
WHERE sector = 'PORTLES';

UPDATE clean.datos_transitocdmx
SET sector = 'TOPILEJO'
WHERE sector = 'TIPOLEJO';

UPDATE clean.datos_transitocdmx
SET sector = 'TAXQUEÑA'
WHERE sector IN ('TAXQUENA', 'TAXQUEÑES', 'TAXQUEÑA');

UPDATE clean.datos_transitocdmx
SET sector = 'TEPEYAC'
WHERE sector IN ('TEPAYAC', 'TEPEYA');

UPDATE clean.datos_transitocdmx
SET sector = 'MIXQUIC'
WHERE sector = 'MIXQUI';

UPDATE clean.datos_transitocdmx
SET sector = 'GRANJAS'
WHERE sector IN ('GRANJA', 'GRNAJAS');

UPDATE clean.datos_transitocdmx
SET sector = NULL
WHERE sector = 'SD';

COMMIT;
-- ROLLBACK;

--Se corrigieron únicamente errores ortográficos evidentes en sectores policiales. Categorías raras o de baja frecuencia se conservaron para evitar introducir agrupaciones artificiales o perder info.

/*
COMENTARIO AL MARGEN (BORRAR DESPUES):
FALTAN POR LIMPIAR: COLONIA, UNIDAD A CARGO Y UNIDAD MEDICA

COLONIA ES LA MAS DIFICIL DE LIMPIAR: INFO MUY PARECIDA PERO DEMASIADAS VARIACIONES DE ELLA COMO PARA PONER ENLISTAR.
UNIDAD MEDICA: DEMASIADAS VARIANTES DE CRUZ ROJA Y ERUM A VECES ESTAN AMBAS JUNTAS Y LAS VARACIONES SON MUCHAS PARA PODERSE ENLISTAR, TAMPOCO SE SABE LA REPERCUSIÓN DE
-- MODIFICAR ESOS DATOS Y ORGANIZARLOS EN UN TIPO PARTICULAR
UNIDAD A CARGO: VARIAS UNIDADES NO TIENEN SENTIDO O MANEJAN ABREVIACIONES NO COMPRENSIBLES

*/

ALTER TABLE clean.datos_transitocdmx
ADD COLUMN geom geometry(Point, 4326);
UPDATE clean.datos_transitocdmx
SET geom = ST_Point(longitud, latitud, 4326)
WHERE geom IS NULL;


--
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
