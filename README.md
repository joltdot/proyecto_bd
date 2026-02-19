# Introducción al Conjunto de Datos: Accidentes de Tránsito CDMX
### Alexis Cuevas, Ben Zimbron, Dominique Ontiveros, Fernando Gutierrez, Juan Pablo Montiel
---
Este conjunto de datos contiene información detallada sobre incidentes viales ocurridos en la Ciudad de México, incluyendo ubicación geográfica, características del siniestro, vehículos involucrados, víctimas y condiciones del entorno. Los datos permiten analizar patrones de accidentalidad urbana para mejorar políticas de seguridad vial. Estos son recolectados por la Secretaría de Seguridad Ciudadana (SSC) de la Ciudad de México en colaboración con el C5 (Centro de Comando, Control, Cómputo, Comunicaciones y Contacto Ciudadano) a través de reportes de emergencia y trabajo policial. Esta información se publica en el Portal de Datos Abiertos de la CDMX (https://datos.cdmx.gob.mx/dataset/hechos-de-transito-reportados-por-ssc-base-ampliada-no-comparativa) con actualizaciones mensuales que pararon en marzo de 2024. El objetivo principal es generar transparencia gubernamental y proporcionar información estadística para:

>- Políticas públicas de prevención vial
>- Asignación de recursos de emergencia
>- Estudios académicos sobre movilidad urbana
>- Auditoría ciudadana sobre seguridad pública
----
El conjunto de datos contiene 215,079 registros anuales con 26 atributos que describen cada incidente, cada uno de los cuales ayuda a analizar cada siniestro individualmente así como ver la relación entre cada registro.

### Atributos Numéricos:
>- folio
>- latitud
>- longitud

### Atributos Categóricos:
>- zona_vial
>- tipo_evento
>- tipo_de_interseccion
>- interseccion_semaforizada
>- clasificacion_de_la_vialidad
>- sentido_de_circulacion
>- dia
>- prioridad
>- origen (cómo se reportó el incidente)
>- trasladado_lesionados
>- no_vehiculo (dice si es el vehículo implicado #1 o #2)
>- tipo_vehiculo

### Atributos de Texto:
>- colonia
>- alcaldia
>- sector
>- unidad_a_cargo
>- unidad_medica_de_apoyo
>- matricula_unidad_medica
>- punto_1 (calle de cruce 1)
>- punto_2 (calle de cruce 2)
### Atributos Temporales/Fecha:
>- fecha_evento
>- hora_evento
>- fecha_captura


Utilizaremos este dataset para identificar zonas de alto riesgo vial en la CDMX mediante análisis geoespacial y temporal. Específicamente buscaremos:
>- Puntos críticos (calles/intersecciones con mayor incidencia)
>- Patrones horarios (horas pico de accidentalidad)
>- Factores de riesgo predominantes por alcaldía

Y así poder informar toma de decisiones sobre:

>- Colocación de semáforos o reductores de velocidad
>- Horarios de vigilancia policial
>- Campañas de concientización dirigidas

Aunque estos datos son muy valiosos, es importante considerar algunas implicaciones éticas como la privacidad de los involucrados (pues, aunque no hay detalles de los individuos, los registros individuales podrían permitir su identificación indirecta), la posible estigmatización de zonas por tener mayores siniestros e incluso el uso por aseguradoras para no cubrir todos los gastos de un accidente en ciertas zonas.
