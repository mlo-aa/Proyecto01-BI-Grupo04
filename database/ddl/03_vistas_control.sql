SET search_path TO universidad, public;
CREATE VIEW v_resultados AS
SELECT m.*, s.id_estudiante, s.id_periodo, s.id_curso, g.id_sede,
 g.id_docente,g.id_modalidad,g.id_horario,t.id_carrera,t.cohorte,c.creditos
FROM matricula m JOIN solicitud s USING(id_solicitud)
JOIN grupo g USING(id_grupo)
JOIN trayectoria t ON t.id_estudiante=s.id_estudiante AND t.id_periodo=s.id_periodo
JOIN curso c ON c.id_curso=s.id_curso;
-- Cada control debe arrojar cero incidencias ANTES de permitir extracción al ETL.
CREATE VIEW v_controles AS
SELECT 'solicitud_asignacion' AS control, count(*) AS incidencias
FROM solicitud s LEFT JOIN matricula m USING(id_solicitud)
WHERE (s.resultado='ASIGNADA' AND m.id_matricula IS NULL)
 OR (s.resultado<>'ASIGNADA' AND m.id_matricula IS NOT NULL)
UNION ALL
SELECT 'grupo_compatible',count(*) FROM matricula m
JOIN solicitud s USING(id_solicitud) JOIN grupo g USING(id_grupo)
WHERE (s.id_curso,s.id_periodo,s.id_sede,s.id_horario)<>
 (g.id_curso,g.id_periodo,g.id_sede,g.id_horario)
UNION ALL
SELECT 'capacidad',count(*) FROM (
SELECT g.id_grupo FROM grupo g LEFT JOIN matricula m USING(id_grupo)
GROUP BY g.id_grupo,g.capacidad_corte HAVING count(m.id_matricula)>g.capacidad_corte) q
UNION ALL
SELECT 'fechas_matricula',count(*) FROM matricula m JOIN solicitud s USING(id_solicitud)
JOIN periodo p ON p.id_periodo=s.id_periodo
WHERE s.fecha>m.fecha OR m.fecha>p.corte_matricula OR m.fecha<p.inicio
 OR m.fecha_retiro>p.fin OR m.fecha_retiro<=p.corte_matricula
UNION ALL
SELECT 'fechas_solicitud',count(*) FROM solicitud s JOIN periodo p USING(id_periodo)
WHERE s.fecha<p.inicio OR s.fecha>p.corte_matricula
UNION ALL
SELECT 'resultados_pendientes',count(*) FROM matricula WHERE estado='PENDIENTE'
UNION ALL
SELECT 'sin_cupo_justificado',count(*) FROM solicitud s
WHERE s.resultado='SIN_CUPO' AND EXISTS (
 SELECT 1 FROM grupo g WHERE g.id_curso=s.id_curso AND g.id_periodo=s.id_periodo
 AND g.id_sede=s.id_sede AND g.id_horario=s.id_horario
 AND (SELECT count(*) FROM matricula m WHERE m.id_grupo=g.id_grupo)<g.capacidad_corte)
UNION ALL
SELECT 'solicitud_sin_oferta',count(*) FROM solicitud s WHERE NOT EXISTS (
 SELECT 1 FROM grupo g WHERE g.id_curso=s.id_curso AND g.id_periodo=s.id_periodo
 AND g.id_sede=s.id_sede AND g.id_horario=s.id_horario);
