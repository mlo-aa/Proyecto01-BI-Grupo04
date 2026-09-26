SET search_path TO universidad, public;
-- P1: la carrera es la adscripción del estudiante en el periodo.
SELECT id_periodo,id_carrera,id_curso,id_sede,count(*) AS inscripciones,
 count(DISTINCT id_estudiante) AS estudiantes_unicos
FROM v_resultados GROUP BY id_periodo,id_carrera,id_curso,id_sede
ORDER BY id_periodo,inscripciones DESC;
-- P2: solo resultados finales. El lote contiene periodos cerrados.
SELECT id_periodo,id_curso,id_docente,id_modalidad,cohorte,
 count(*) AS n,
 round(100.0*sum(CASE WHEN estado='APROBADO' THEN 1 ELSE 0 END)/count(*),2) AS aprobacion_pct,
 round(100.0*sum(CASE WHEN estado='REPROBADO' THEN 1 ELSE 0 END)/count(*),2) AS reprobacion_pct,
 round(100.0*sum(CASE WHEN estado='RETIRADO' THEN 1 ELSE 0 END)/count(*),2) AS retiro_pct
FROM v_resultados WHERE estado<>'PENDIENTE'
GROUP BY id_periodo,id_curso,id_docente,id_modalidad,cohorte;
-- P3: retiros tienen nota NULL; AVG los excluye. Créditos por actividad del periodo.
SELECT id_periodo,id_carrera,cohorte,round(avg(nota),2) AS nota_promedio,
 count(nota) AS n_notas,
 sum(CASE WHEN estado='APROBADO' THEN creditos ELSE 0 END) AS creditos_aprobados
FROM v_resultados GROUP BY id_periodo,id_carrera,cohorte;
-- P4: agregar oferta y demanda por separado para NO multiplicar cupos.
WITH ocupacion AS (
 SELECT g.id_grupo,g.id_periodo,g.id_curso,g.id_sede,g.id_horario,g.capacidad_corte,
 count(m.id_matricula) AS inscritos FROM grupo g LEFT JOIN matricula m USING(id_grupo)
 GROUP BY g.id_grupo), oferta AS (
 SELECT id_periodo,id_curso,id_sede,id_horario,sum(capacidad_corte) AS cupos,
 sum(inscritos) AS matriculados FROM ocupacion GROUP BY id_periodo,id_curso,id_sede,id_horario
), demanda AS (
 SELECT id_periodo,id_curso,id_sede,id_horario,count(*) AS solicitudes_activas_elegibles
 FROM solicitud WHERE resultado IN ('ASIGNADA','SIN_CUPO')
 GROUP BY id_periodo,id_curso,id_sede,id_horario)
SELECT o.*,coalesce(d.solicitudes_activas_elegibles,0) AS demanda,
 round(100.0*o.matriculados/nullif(o.cupos,0),2) AS utilizacion_pct
FROM oferta o LEFT JOIN demanda d USING(id_periodo,id_curso,id_sede,id_horario);
-- P5: desistidas y no elegibles se excluyen de numerador Y denominador.
SELECT id_periodo,id_curso,id_sede,id_horario,
 sum(CASE WHEN resultado='SIN_CUPO' THEN 1 ELSE 0 END) AS sin_cupo,
 count(*) AS demanda_activa_elegible,
 round(100.0*sum(CASE WHEN resultado='SIN_CUPO' THEN 1 ELSE 0 END)/count(*),2) AS no_atendida_pct
FROM solicitud WHERE resultado IN ('ASIGNADA','SIN_CUPO')
GROUP BY id_periodo,id_curso,id_sede,id_horario;
