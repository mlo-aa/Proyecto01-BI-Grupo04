# Proyecto 01 - Inteligencia de Negocios

## Grupo 4 - Institución Universitaria

### Integrantes

- Emilio Alfaro Alfaro
- Génesis Arce Berrocal
- Ernesto Cascante Pérez
- Sebastián Rodríguez González

## Descripción

Solución integral de Inteligencia de Negocios para el análisis de matrícula, rendimiento académico y utilización de la oferta de cursos de una institución universitaria.

## Problema de Negocio

Para tomar decisiones eficientes sobre la oferta académica, la institución necesita distinguir claramente entre una oferta ocupada y una oferta insuficiente. Confundir los distintos niveles de detalle (solicitudes de estudiantes, matrículas efectivas y capacidad de los grupos ofertados) puede llevar a duplicar cupos o a ignorar la demanda real. Esta solución busca integrar dicha información bajo reglas comunes de cálculo, permitiendo analizar dónde se concentra la matrícula, cómo varían los resultados académicos y qué cursos no logran atender todas las solicitudes elegibles.

## Objetivo

Diseñar e implementar una solución de inteligencia de negocios que integre información de matrícula, rendimiento académico y oferta de cursos de una institución universitaria, mediante un modelo dimensional, un proceso ETL reproducible y una capa analítica que apoye la gestión académica.

## Herramientas Utilizadas

- **Fuente operacional y Data Warehouse:** PostgreSQL 18.3.
- **Proceso ETL:** Pentaho Data Integration (PDI / Spoon).
- **Solución analítica (Dashboard):** Power BI Desktop.
- **Generación de datos sintéticos:** Python 3.10+, biblioteca estándar.
- **Pruebas de la fuente:** PostgreSQL embebido en PGlite 0.5.8.
- **Diagramas de la fuente:** DOT, SVG y PNG.
- **Colaboración y versionamiento:** GitHub.

## Estructura del proyecto

| Carpeta o archivo | Contenido |
| --- | --- |
| `database/ddl/` | Estructura operacional, vistas y controles de integridad. |
| `database/dml/` | Inserciones de datos sintéticos. |
| `database/datos/` | Doce CSV y manifiesto de conteos y hashes. |
| `database/05_consultas_negocio.sql` | Consultas P1–P5 de referencia sobre el origen. |
| `docs/requerimientos/` | Criterios de aceptación y definiciones del negocio. |
| `docs/modelo_transaccional/` | Diagramas, campos y restricciones de la fuente. |
| `docs/informe/` | Documento final del proyecto y diccionarios de datos. |
| `scripts/` | Generador reproducible y prueba del origen. |
| `validacion/` | Resultados de pruebas del origen y scripts de validación del DW. |
| `etl/` | Transformaciones (`.ktr`) y Jobs (`.kjb`) desarrollados en Pentaho. |
| `analytics/` | Archivo `.pbix` del dashboard en Power BI y reportes exportados. |
| `presentation/` | Archivo de la presentación final del proyecto. |
| `screenshots/` | Evidencias de ejecución del ETL y validaciones visuales. |
| `GUIA_FUENTE.md` | Instrucciones detalladas de ejecución e integración. |

## Ejecución

Consultar [GUIA_FUENTE.md](GUIA_FUENTE.md) para requisitos y comandos completos. En una base PostgreSQL vacía, ejecutar en este orden:

1. `database/ddl/01_fuente.sql`
2. `database/dml/02_datos.sql`
3. `database/ddl/03_vistas_control.sql`
4. `database/ddl/04_validar.sql`
5. `database/05_consultas_negocio.sql`

Los ocho controles deben presentar cero incidencias. Los scripts de creación y carga no son una recarga incremental: no repetirlos sobre una base ya poblada.

Para regenerar los datos originales: ejecutar `python scripts/generar_datos.py`. Para la prueba opcional en memoria con Node.js 20+: utilizar `npm install` y `npm test`.

La fuente contiene 3.840 solicitudes, 2.295 matrículas y 324 grupos. Los datos son ficticios y reproducibles con la semilla `20260925`. 

## Preguntas de Negocio Resueltas

1. ¿Qué carreras, cursos y sedes concentran la mayor matrícula por periodo académico?
2. ¿Cómo se comportan las tasas de aprobación, reprobación y retiro según curso, docente, modalidad y cohorte?
3. ¿Cómo varían la nota promedio y los créditos aprobados según carrera, cohorte y periodo?
4. ¿Qué cursos, horarios y sedes presentan mayor demanda y nivel de utilización de los cupos disponibles?
5. **(Pregunta adicional propuesta):** ¿Qué cursos, horarios y sedes tienen mayor proporción de solicitudes activas y elegibles sin atender por falta de cupo? 

> **Nota sobre cálculos:** Los criterios de cálculo detallados se documentan en el informe y en `docs/requerimientos/criterios_aceptacion.md`. La matrícula, oferta y solicitudes poseen distintos niveles de detalle, por lo que el modelo dimensional y las medidas DAX gestionan sus agregaciones correspondientes antes de combinar las medidas, asegurando cálculos exactos y sin duplicaciones.
