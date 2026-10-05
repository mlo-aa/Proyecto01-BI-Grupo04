/* =========================================================
   08_preguntas_negocio.sql
   Consultas analíticas sobre el Data Warehouse (dw)
   ========================================================= */

/* ---------------------------------------------------------
   P1: ¿Qué carreras, cursos y sedes concentran la mayor 
   matrícula por periodo académico?
   --------------------------------------------------------- */
WITH MatriculaPorPeriodo AS (
    SELECT 
        t.codigo_periodo,
        e.carrera,
        c.nombre AS curso,
        s.nombre AS sede,
        SUM(f.matricula) AS total_matriculas,
        RANK() OVER (
            PARTITION BY t.codigo_periodo 
            ORDER BY SUM(f.matricula) DESC
        ) AS ranking
    FROM dw.fact_academico f
    JOIN dw.dim_tiempo t     ON f.sk_tiempo = t.sk_tiempo
    JOIN dw.dim_estudiante e ON f.sk_estudiante = e.sk_estudiante
    JOIN dw.dim_curso c      ON f.sk_curso = c.sk_curso
    JOIN dw.dim_sede s       ON f.sk_sede = s.sk_sede
    WHERE f.tipo_registro = 'SOLICITUD' 
      AND f.matricula = 1
      AND e.sk_estudiante <> -1 -- Excluir "Sin Asignar" si aplica
    GROUP BY t.codigo_periodo, e.carrera, c.nombre, s.nombre
)
SELECT 
    codigo_periodo, ranking, carrera, curso, sede, total_matriculas
FROM MatriculaPorPeriodo
WHERE ranking <= 10
ORDER BY codigo_periodo, ranking;


/* ---------------------------------------------------------
   P2: ¿Cómo se comportan las tasas de aprobación, reprobación 
   y retiro según curso, docente, modalidad y cohorte?
   --------------------------------------------------------- */
SELECT 
    c.nombre AS curso,
    g.docente,
    g.modalidad,
    e.cohorte,
    SUM(f.matricula) AS total_matriculados,
    ROUND(100.0 * SUM(f.es_aprobado) / NULLIF(SUM(f.matricula), 0), 1) AS pct_aprobacion,
    ROUND(100.0 * SUM(f.es_reprobado) / NULLIF(SUM(f.matricula), 0), 1) AS pct_reprobacion,
    ROUND(100.0 * SUM(f.es_retirado) / NULLIF(SUM(f.matricula), 0), 1) AS pct_retiro
FROM dw.fact_academico f
JOIN dw.dim_curso c      ON f.sk_curso = c.sk_curso
JOIN dw.dim_grupo g      ON f.sk_grupo = g.sk_grupo
JOIN dw.dim_estudiante e ON f.sk_estudiante = e.sk_estudiante
WHERE f.tipo_registro = 'SOLICITUD' 
  AND f.matricula = 1 
  AND g.sk_grupo <> -1 -- Excluir solicitudes sin grupo asignado
GROUP BY c.nombre, g.docente, g.modalidad, e.cohorte
HAVING SUM(f.matricula) > 0
ORDER BY c.nombre, e.cohorte;


/* ---------------------------------------------------------
   P3: ¿Cómo varían la nota promedio y los créditos aprobados 
   según carrera, cohorte y periodo?
   --------------------------------------------------------- */
SELECT 
    t.codigo_periodo,
    e.carrera,
    e.cohorte,
    COUNT(f.nota) AS cantidad_notas_registradas,
    ROUND(AVG(f.nota), 2) AS nota_promedio,
    SUM(f.creditos_aprobados) AS total_creditos_aprobados,
    ROUND(AVG(f.creditos_aprobados), 1) AS promedio_creditos_por_estudiante
FROM dw.fact_academico f
JOIN dw.dim_estudiante e ON f.sk_estudiante = e.sk_estudiante
JOIN dw.dim_tiempo t     ON f.sk_tiempo = t.sk_tiempo
WHERE f.tipo_registro = 'SOLICITUD'
  AND f.matricula = 1
GROUP BY t.codigo_periodo, e.carrera, e.cohorte
ORDER BY t.codigo_periodo, e.carrera, e.cohorte;


/* ---------------------------------------------------------
   P4: ¿Qué cursos, horarios y sedes presentan mayor demanda 
   y nivel de utilización de los cupos disponibles?
   --------------------------------------------------------- */
SELECT 
    c.nombre AS curso,
    s.nombre AS sede,
    h.franja AS horario,
    SUM(f.es_asignada + f.es_sin_cupo) AS demanda_total,
    SUM(f.capacidad_corte) AS cupos_ofertados,
    SUM(f.matricula) AS cupos_utilizados,
    ROUND(100.0 * SUM(f.matricula) / NULLIF(SUM(f.capacidad_corte), 0), 1) AS pct_utilizacion_cupos
FROM dw.fact_academico f
JOIN dw.dim_curso c   ON f.sk_curso = c.sk_curso
JOIN dw.dim_sede s    ON f.sk_sede = s.sk_sede
JOIN dw.dim_horario h ON f.sk_horario = h.sk_horario
WHERE f.sk_horario <> -1 -- Excluir solicitudes sin horario definido
GROUP BY c.nombre, s.nombre, h.franja
ORDER BY pct_utilizacion_cupos DESC, demanda_total DESC
LIMIT 20;


/* ---------------------------------------------------------
   P5: ¿Qué cursos, horarios y sedes tienen mayor proporción 
   de solicitudes activas y elegibles sin atender por falta de cupo?
   --------------------------------------------------------- */
SELECT 
    c.nombre AS curso,
    s.nombre AS sede,
    h.franja AS horario,
    SUM(f.es_asignada + f.es_sin_cupo) AS total_solicitudes_activas,
    SUM(f.es_sin_cupo) AS solicitudes_rechazadas_sin_cupo,
    ROUND(100.0 * SUM(f.es_sin_cupo) / NULLIF(SUM(f.es_asignada + f.es_sin_cupo), 0), 1) AS pct_rechazo_sin_cupo
FROM dw.fact_academico f
JOIN dw.dim_curso c   ON f.sk_curso = c.sk_curso
JOIN dw.dim_sede s    ON f.sk_sede = s.sk_sede
JOIN dw.dim_horario h ON f.sk_horario = h.sk_horario
WHERE f.tipo_registro = 'SOLICITUD'
  AND (f.es_asignada = 1 OR f.es_sin_cupo = 1) -- Excluye NO_ELEGIBLE y DESISTIDA
GROUP BY c.nombre, s.nombre, h.franja
HAVING SUM(f.es_asignada + f.es_sin_cupo) >= 5 -- Filtro de relevancia estadística ajustado
ORDER BY pct_rechazo_sin_cupo DESC, solicitudes_rechazadas_sin_cupo DESC
LIMIT 20;
