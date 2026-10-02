-- ASIGNADA debe coincidir exactamente con tener matrícula (CHECK matricula = es_asignada)
SELECT s.resultado, count(*) AS total, count(m.id_matricula) AS con_matricula
FROM universidad.solicitud s
LEFT JOIN universidad.matricula m ON m.id_solicitud = s.id_solicitud
GROUP BY s.resultado;

-- Una solicitud con más de una matrícula duplicaría filas (UNIQUE id_solicitud_origen)
SELECT id_solicitud, count(*) FROM universidad.matricula
GROUP BY id_solicitud HAVING count(*) > 1;

-- Grupos que no cumplen capacidad > 0
SELECT count(*) FROM universidad.grupo WHERE capacidad_corte  IS NULL OR capacidad_corte  <= 0;



SELECT tipo_registro, count(*) FROM dw.fact_academico GROUP BY 1;
-- GRUPO     = grupos con capacidad > 0
-- SOLICITUD = COUNT(*) de universidad.solicitud

SELECT count(*) FROM dw.fact_academico WHERE sk_grupo = -1;
-- debe ser igual a las solicitudes sin matrícula


SELECT 'solicitudes (esperado 3840)'            AS control, count(*) AS origen
FROM universidad.solicitud
UNION ALL
SELECT 'grupos con capacidad > 0 (esperado 324)', count(*)
FROM universidad.grupo WHERE capacidad_corte  > 0
UNION ALL
SELECT 'solicitudes sin matrícula (esperado 1545)', count(*)
FROM universidad.solicitud s
WHERE NOT EXISTS (SELECT 1 FROM universidad.matricula m WHERE m.id_solicitud = s.id_solicitud)
UNION ALL
SELECT 'solicitudes ASIGNADA (esperado 2295)', count(*)
FROM universidad.solicitud WHERE resultado = 'ASIGNADA';




-- En el DW
SELECT
  sum(es_asignada)        AS asignadas,
  sum(es_sin_cupo)        AS sin_cupo,
  sum(es_no_elegible)     AS no_elegibles,
  sum(es_desistida)       AS desistidas,
  sum(es_aprobado)        AS aprobados,
  sum(es_reprobado)       AS reprobados,
  sum(es_retirado)        AS retirados,
  sum(creditos_aprobados) AS creditos_aprobados,
  count(nota)             AS filas_con_nota
FROM dw.fact_academico
WHERE tipo_registro = 'SOLICITUD';

-- En el origen
SELECT
  count(*) FILTER (WHERE s.resultado = 'ASIGNADA')    AS asignadas,
  count(*) FILTER (WHERE s.resultado = 'SIN_CUPO')    AS sin_cupo,
  count(*) FILTER (WHERE s.resultado = 'NO_ELEGIBLE') AS no_elegibles,
  count(*) FILTER (WHERE s.resultado = 'DESISTIDA')   AS desistidas,
  count(*) FILTER (WHERE m.estado = 'APROBADO')       AS aprobados,
  count(*) FILTER (WHERE m.estado = 'REPROBADO')      AS reprobados,
  count(*) FILTER (WHERE m.estado = 'RETIRADO')       AS retirados,
  sum(c.creditos) FILTER (WHERE m.estado = 'APROBADO') AS creditos_aprobados,
  count(m.nota)                                       AS filas_con_nota
FROM universidad.solicitud s
JOIN universidad.curso c          ON c.id_curso = s.id_curso
LEFT JOIN universidad.matricula m ON m.id_solicitud = s.id_solicitud;

-- Control de grupos duplicados
SELECT count(*) AS grupos_duplicados
FROM (SELECT sk_grupo FROM dw.fact_academico
      WHERE tipo_registro = 'GRUPO'
      GROUP BY sk_grupo HAVING count(*) > 1) x;



SELECT 'dim_estudiante' AS tabla, count(*) FROM dw.dim_estudiante
UNION ALL SELECT 'dim_grupo',   count(*) FROM dw.dim_grupo
UNION ALL SELECT 'dim_curso',   count(*) FROM dw.dim_curso
UNION ALL SELECT 'dim_sede',    count(*) FROM dw.dim_sede
UNION ALL SELECT 'dim_horario', count(*) FROM dw.dim_horario
UNION ALL SELECT 'dim_tiempo',  count(*) FROM dw.dim_tiempo;


-- Demanda vs. oferta por curso
SELECT c.codigo, c.nombre,
       sum(f.solicitudes)     AS solicitudes,
       sum(f.es_asignada)     AS asignadas,
       sum(f.es_sin_cupo)     AS sin_cupo,
       sum(f.capacidad_corte) AS cupos_ofertados
FROM dw.fact_academico f
JOIN dw.dim_curso c ON c.sk_curso = f.sk_curso
GROUP BY c.codigo, c.nombre
ORDER BY sin_cupo DESC
LIMIT 10;

-- Rendimiento académico por período
SELECT t.codigo_periodo,
       sum(f.matricula)    AS matriculas,
       sum(f.es_aprobado)  AS aprobados,
       sum(f.es_reprobado) AS reprobados,
       sum(f.es_retirado)  AS retirados,
       round(100.0 * sum(f.es_aprobado) /
             NULLIF(sum(f.es_aprobado + f.es_reprobado + f.es_retirado), 0), 1) AS pct_aprobacion
FROM dw.fact_academico f
JOIN dw.dim_tiempo t ON t.sk_tiempo = f.sk_tiempo
WHERE f.tipo_registro = 'SOLICITUD'
GROUP BY t.codigo_periodo
ORDER BY t.codigo_periodo;