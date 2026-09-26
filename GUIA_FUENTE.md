# Proyecto 01 — Fuente operacional universitaria

Paquete del **integrante 1**. Incluye requerimientos, modelo operacional, datos sintéticos y consultas de control. PostgreSQL es una propuesta pendiente de confirmar con el grupo. No contiene el modelo dimensional, un ETL ni un dashboard.

## Qué incorporar al informe

El Word `docs/informe/Integrante1_Requerimientos_y_Fuente.docx` contiene una página inicial de instrucciones. Copiar desde el título **1. Caso de negocio y requerimientos** hasta el final de la sección 2. Añadir las referencias a la bibliografía general. Sustituye el desarrollo inicial de requerimientos anterior para evitar duplicar apartados o conservar fórmulas diferentes. El punto 1.8 documenta PostgreSQL como propuesta para la fuente; completar las herramientas del ETL y la analítica cuando el grupo las seleccione.

## Reproducción en PostgreSQL

Requisitos: PostgreSQL con cliente `psql` y acceso a una base vacía. Probado mediante PostgreSQL 18.3 embebido en PGlite 0.5.8. Falta repetir en el servidor concreto del grupo. La opción `-W` solicitará contraseña; no guardarla en el repositorio.

1. Descomprimir el paquete y abrir una terminal en esta carpeta.
2. Crear una base vacía con pgAdmin o `createdb -h localhost -U postgres -W universidad_origen`.
3. Ejecutar, en este orden:

```bash
psql -h localhost -U postgres -W -d universidad_origen -v ON_ERROR_STOP=1 -f database/ddl/01_fuente.sql
psql -h localhost -U postgres -W -d universidad_origen -v ON_ERROR_STOP=1 -f database/dml/02_datos.sql
psql -h localhost -U postgres -W -d universidad_origen -v ON_ERROR_STOP=1 -f database/ddl/03_vistas_control.sql
psql -h localhost -U postgres -W -d universidad_origen -v ON_ERROR_STOP=1 -f database/ddl/04_validar.sql
psql -h localhost -U postgres -W -d universidad_origen -v ON_ERROR_STOP=1 -f database/05_consultas_negocio.sql
```

También pueden ejecutarse los archivos SQL en pgAdmin, respetando ese orden. No volver a ejecutar 01 o 02 sobre la misma base: fallarán por objetos/llaves existentes, sin ser una recarga incremental. Crear otra base vacía para repetir. El paquete no incluye comandos que borren bases existentes.

Para guardar la evidencia del servidor: agregar `-L validacion/servidor_grupo.log` a la ejecución de 04. Las ocho filas de `v_controles` deben mostrar cero incidencias; el bloque final aborta si encuentra alguna. Volver a validar después de cualquier modificación. Las reglas entre tablas (capacidad, fechas y compatibilidad) se comprueban por lote; no están protegidas por triggers concurrentes. Este origen es un conjunto de datos para BI, no un sistema de matrícula en producción.

## Datos sintéticos

Los CSV ya están generados. Los campos vacíos de nota y fecha_retiro representan NULL; leer fechas como ISO YYYY-MM-DD y texto como UTF-8. Los identificadores se asignan explícitamente por el generador; no usar filas del CSV como identificadores nuevos.

```bash
python scripts/generar_datos.py
```

Python 3.10+; solo biblioteca estándar. Semilla fija **20260925**. Sobrescribe los CSV y `02_datos.sql` de este paquete; no modifica una base conectada. `database/datos/manifest.json` registra conteos y hashes SHA-256. Generador separado del ETL: crea la fuente cruda; integrante 3 debe usar una herramienta ETL específica para cargar el destino dimensional.

## Prueba opcional sin servidor

Con Node.js 20+ y npm:

```bash
npm install
npm test
```

Esta prueba crea PostgreSQL en memoria, ejecuta el SQL, las cinco consultas y siete pruebas negativas, luego revierte sus cambios. No instala ni sustituye PostgreSQL del grupo. Los resultados quedan en `validacion/resultado_pruebas.json`. La estructura y restricciones se exportan desde el motor a `docs/modelo_transaccional/`.

## Distribución del paquete

- `database/ddl/`: estructura, vistas y controles.
- `database/dml/`: inserciones reproducibles.
- `database/datos/`: 12 CSV y manifiesto.
- `scripts/`: generación y prueba reproducibles.
- `docs/modelo_transaccional/`: diagramas completos y por proceso en DOT, SVG y PNG; campos y restricciones extraídos del motor.
- `docs/requerimientos/`: criterios de aceptación e integración.
- `validacion/`: resultados de la prueba técnica del origen.

## Entrega a los compañeros

**Integrante 2:** SQL 01, diagramas y campos; acordar hechos separados para matrícula, capacidad y demanda. Mantener matrícula por inscripción, capacidad por grupo y demanda por solicitud. Las llaves de origen se conservan para trazabilidad; no confundirlas con llaves subrogadas del destino.

**Integrante 3:** datos o conexión al esquema `universidad`, orden de carga, dominios y controles. Extraer las tablas y/o `v_resultados` según el mapeo acordado. `v_resultados` no contiene solicitudes rechazadas/sin cupo ni grupos vacíos: extraer además `solicitud` y `grupo` para P4/P5.

**Integrante 4:** cinco consultas de fuente como referencia numérica. Construir medidas sobre el modelo dimensional después del ETL. No hacer del reporte conectado directamente a esta fuente la solución final.

## Trabajo pendiente antes del cierre personal

1. Acordar PostgreSQL y el KPI de demanda no atendida con el grupo.
2. Revisar que estos supuestos encajen con la solución conjunta: escala ficticia 0–100, umbral 70, cuatro periodos cerrados, horario agregado en franjas, un docente y una carrera por estudiante-periodo.
3. Ejecutar y guardar evidencia en el entorno del grupo.
4. Coordinar cambios de esquema con integrantes 2 y 3.
5. Subir archivos al repositorio real con la cuenta propia. Los archivos del integrante 1 se incorporan en este repositorio; cada integrante deberá registrar sus propios aportes.
6. Preparar exposición de la fuente y contribuir a conclusiones basadas en los resultados finales.

Los commits deben corresponder a aportes reales. Una secuencia razonable es documentar requerimientos, añadir esquema y diagrama, añadir generación y validaciones y luego registrar correcciones de integración. No fabricar historial ni atribuirse trabajo de otros.

## Limitaciones

Datos ficticios, sin nombres ni expedientes reales. Mismos 240 estudiantes presentes en los cuatro periodos; no se simula deserción institucional. La adscripción académica puede cambiar entre periodos en el modelo, pero la muestra la mantiene estable. Curso.créditos permanece constante. Las repeticiones de cursos se contabilizan como actividad académica, no como créditos únicos de graduación. Una solicitud por estudiante/curso/periodo; no se simulan preferencias alternativas ni cambios de grupo. La franja representa mañana/tarde/noche, no un horario detallado de aula. No se infiere causalidad ni calidad docente de diferencias generadas aleatoriamente.

## Fuentes técnicas

PostgreSQL Global Development Group. (s. f.). Constraints. https://www.postgresql.org/docs/current/ddl-constraints.html

PostgreSQL Global Development Group. (s. f.). psql. https://www.postgresql.org/docs/current/app-psql.html

Consigna proporcionada: Proyecto_1.pdf. Distribución del grupo: capturas adjuntas.
