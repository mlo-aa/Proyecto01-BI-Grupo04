# Criterios de aceptación y contrato de origen

| ID | Requisito | Evidencia |
|---|---|---|
| RF01 | Matrícula por carrera de adscripción, curso, sede y periodo | P1, sobre v_resultados y trayectoria |
| RF02 | Aprobación, reprobación y retiro por curso, docente, modalidad y cohorte | P2; denominador de resultados finales; retiros sin nota |
| RF03 | Nota promedio y créditos aprobados por carrera, cohorte y periodo | P3; AVG excluye NULL; créditos solo de aprobaciones |
| RF04 | Demanda y ocupación por curso, horario y sede | P4; capacidad agregada antes de unir; grupos vacíos incluidos |
| RF05 | Propuesta adicional: tasa de demanda no atendida | P5; SIN_CUPO / (ASIGNADA + SIN_CUPO); grupos sin demanda = no aplicable |
| RNF01 | Regeneración reproducible | Semilla 20260925 y manifiesto de hashes |
| RNF02 | Integridad | PK, FK, UNIQUE, CHECK y ocho controles entre tablas |
| RNF03 | Trazabilidad | Identificadores estables y versión del código en GitHub |
| RNF04 | Entrega comprensible | DDL, diagramas, campos, dominios y README coherentes |

## Reglas de extracción

- El origen contiene periodos cerrados; cada grupo tiene un único corte de matrícula. `grupo.capacidad_corte` corresponde a `periodo.corte_matricula`.
- Todos los registros de `matricula` fueron efectivos al corte; los retiros son posteriores. No son matrículas vigentes al cierre final de clases.
- Demanda operativa: solicitudes ASIGNADA y SIN_CUPO. NO_ELEGIBLE y DESISTIDA no forman parte del denominador.
- Solicitudes al corte: no hay múltiples alternativas por estudiante/curso/periodo. La sede y la franja identifican la preferencia única registrada.
- Los códigos de origen son las claves de trazabilidad, no se reasignan al leer CSV.
- Antes de extraer, ejecutar `04_validar.sql`; después de cambios, repetirlo.
- Capacidad por grupo, matrícula por inscripción y demanda por solicitud son procesos distintos. No sumar capacidad en un JOIN con alumnos.
- No sumar conteos de estudiantes únicos ni promediar tasas de grupos para obtener totales.
- Escala y umbral de nota son supuestos del caso ficticio; cualquier cambio requiere modificar CHECK, generador, documento, ETL y consultas.
- El dataset limpio no prueba manejo de errores del ETL. El integrante 3 debe preparar pruebas controladas en una copia y guardar sus resultados si se evalúa ese manejo.

## Acuerdos que debe confirmar el grupo

PostgreSQL como origen; pregunta adicional P5; granularidad y filtros del destino; herramientas/versiones del ETL y analítica; repositorio y accesos. Ninguno de esos acuerdos externos se presenta como ya aprobado.
