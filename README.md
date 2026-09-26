# Proyecto 01 - Inteligencia de Negocios

## Grupo 4 - Institución Universitaria

### Integrantes

- Emilio Alfaro Alfaro
- Génesis Arce Berrocal
- Ernesto Cascante Pérez
- Sebastián Rodríguez González

## Descripción

Solución de Inteligencia de Negocios para el análisis de
matrícula, rendimiento académico y utilización de la oferta
de cursos de una institución universitaria.

## Objetivo

Diseñar e implementar una solución de inteligencia de negocios que integre información de matrícula, rendimiento académico y oferta de cursos de una institución universitaria, mediante un modelo dimensional, un proceso ETL reproducible y una capa analítica que apoye la gestión académica.

## Herramientas

- Fuente operacional: PostgreSQL (implementación propuesta; pendiente de acuerdo e integración grupal).
- Generación de datos sintéticos: Python 3.10+, biblioteca estándar.
- Pruebas de la fuente: PostgreSQL 18.3 embebido en PGlite 0.5.8.
- ETL: pendiente de selección grupal.
- Solución analítica: pendiente de selección grupal.
- Diagramas de la fuente: DOT, SVG y PNG.
- Colaboración: GitHub.

## Estructura del proyecto

| Carpeta o archivo | Contenido |
| --- | --- |
| `database/ddl/` | Estructura operacional, vistas y controles de integridad. |
| `database/dml/` | Inserciones de datos sintéticos. |
| `database/datos/` | Doce CSV y manifiesto de conteos y hashes. |
| `database/05_consultas_negocio.sql` | Consultas P1–P5 de referencia sobre el origen. |
| `docs/requerimientos/` | Criterios de aceptación. |
| `docs/modelo_transaccional/` | Diagramas, campos y restricciones de la fuente. |
| `docs/informe/` | Documentación del integrante 1 y avance del informe. |
| `scripts/` | Generador reproducible y prueba del origen. |
| `validacion/` | Resultados de pruebas del origen en PostgreSQL embebido. |
| `etl/` | Reservada para el proceso ETL del grupo. |
| `analytics/` | Reservada para reportes y dashboard. |
| `presentation/` | Reservada para la presentación. |
| `screenshots/` | Reservada para evidencias de ejecución del grupo. |
| `GUIA_FUENTE.md` | Instrucciones detalladas de ejecución e integración. |

## Ejecución

Consultar [GUIA_FUENTE.md](GUIA_FUENTE.md) para requisitos y comandos completos. En una base PostgreSQL vacía, ejecutar en este orden:

1. `database/ddl/01_fuente.sql`
2. `database/dml/02_datos.sql`
3. `database/ddl/03_vistas_control.sql`
4. `database/ddl/04_validar.sql`
5. `database/05_consultas_negocio.sql`

Los ocho controles deben presentar cero incidencias. Los scripts de creación y carga no son una recarga incremental: no repetirlos sobre una base ya poblada.

Para regenerar los datos: `python scripts/generar_datos.py`. Para la prueba opcional en memoria con Node.js 20+: `npm install` y `npm test`.

La fuente contiene 3.840 solicitudes, 2.295 matrículas y 324 grupos. Los datos son ficticios y reproducibles con la semilla 20260925. La prueba del origen no constituye evidencia de ejecución del ETL ni del servidor del grupo.

## Preguntas de negocio

1. ¿Qué carreras, cursos y sedes concentran la mayor matrícula por periodo académico?
2. ¿Cómo se comportan las tasas de aprobación, reprobación y retiro según curso, docente, modalidad y cohorte?
3. ¿Cómo varían la nota promedio y los créditos aprobados según carrera, cohorte y periodo?
4. ¿Qué cursos, horarios y sedes presentan mayor demanda y nivel de utilización de los cupos disponibles?
5. ¿Qué cursos, horarios y sedes tienen mayor proporción de solicitudes activas y elegibles sin atender por falta de cupo? (Pregunta adicional propuesta).

Los criterios de cálculo se documentan en el informe y en `docs/requerimientos/criterios_aceptacion.md`. Matrícula, oferta y solicitudes tienen distintos niveles de detalle; deben agregarse antes de combinar sus medidas.

## Estado del proyecto

- [x] Desarrollo inicial de requerimientos y criterios (pendiente de acuerdo grupal)
- [x] Fuente transaccional, datos y diagramas (probados en PostgreSQL embebido)
- [ ] Modelo dimensional
- [ ] ETL
- [ ] Solución analítica
- [x] Validación del origen: ocho controles sin incidencias y siete pruebas negativas detectadas
- [ ] Ejecución en el servidor del grupo y conciliación posterior al ETL
- [x] Documentación del integrante 1
- [ ] Integración de la documentación grupal
- [ ] Presentación
