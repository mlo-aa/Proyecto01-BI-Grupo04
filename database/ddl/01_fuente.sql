-- Fuente operacional del caso ficticio. Ejecutar en una base vacía.
-- No elimina ni reemplaza objetos existentes.
BEGIN;
CREATE SCHEMA universidad;
SET search_path TO universidad, public;
CREATE TABLE carrera (id_carrera integer PRIMARY KEY, nombre varchar(100) NOT NULL UNIQUE);
CREATE TABLE sede (id_sede integer PRIMARY KEY, nombre varchar(80) NOT NULL UNIQUE);
CREATE TABLE docente (id_docente integer PRIMARY KEY, alias varchar(50) NOT NULL UNIQUE);
CREATE TABLE modalidad (id_modalidad integer PRIMARY KEY, nombre varchar(30) NOT NULL UNIQUE);
CREATE TABLE horario (id_horario integer PRIMARY KEY, franja varchar(30) NOT NULL UNIQUE);
CREATE TABLE periodo (
 id_periodo integer PRIMARY KEY, codigo varchar(10) NOT NULL UNIQUE,
 anio integer NOT NULL, numero smallint NOT NULL CHECK(numero IN (1,2)),
 inicio date NOT NULL, corte_matricula date NOT NULL, fin date NOT NULL,
 CHECK(inicio <= corte_matricula AND corte_matricula < fin), UNIQUE(anio,numero));
CREATE TABLE curso (id_curso integer PRIMARY KEY, codigo varchar(12) NOT NULL UNIQUE,
 nombre varchar(100) NOT NULL, creditos smallint NOT NULL CHECK(creditos BETWEEN 1 AND 12));
CREATE TABLE estudiante (id_estudiante integer PRIMARY KEY, alias varchar(30) NOT NULL UNIQUE);
CREATE TABLE trayectoria (
 id_estudiante integer NOT NULL REFERENCES estudiante, id_periodo integer NOT NULL REFERENCES periodo,
 id_carrera integer NOT NULL REFERENCES carrera, cohorte varchar(10) NOT NULL,
 PRIMARY KEY(id_estudiante,id_periodo));
CREATE TABLE grupo (
 id_grupo integer PRIMARY KEY, id_curso integer NOT NULL REFERENCES curso,
 id_periodo integer NOT NULL REFERENCES periodo, id_sede integer NOT NULL REFERENCES sede,
 id_docente integer NOT NULL REFERENCES docente, id_modalidad integer NOT NULL REFERENCES modalidad,
 id_horario integer NOT NULL REFERENCES horario, numero_grupo smallint NOT NULL CHECK(numero_grupo>0),
 capacidad_corte smallint NOT NULL CHECK(capacidad_corte>0),
 UNIQUE(id_curso,id_periodo,id_sede,numero_grupo));
CREATE TABLE solicitud (
 id_solicitud integer PRIMARY KEY, id_estudiante integer NOT NULL,
 id_periodo integer NOT NULL, id_curso integer NOT NULL REFERENCES curso,
 id_sede integer NOT NULL REFERENCES sede, id_horario integer NOT NULL REFERENCES horario,
 fecha date NOT NULL, resultado varchar(20) NOT NULL
 CHECK(resultado IN ('ASIGNADA','SIN_CUPO','NO_ELEGIBLE','DESISTIDA')),
 FOREIGN KEY(id_estudiante,id_periodo) REFERENCES trayectoria,
 UNIQUE(id_estudiante,id_periodo,id_curso));
CREATE TABLE matricula (
 id_matricula integer PRIMARY KEY, id_solicitud integer NOT NULL UNIQUE REFERENCES solicitud,
 id_grupo integer NOT NULL REFERENCES grupo, fecha date NOT NULL,
 estado varchar(12) NOT NULL CHECK(estado IN ('APROBADO','REPROBADO','RETIRADO','PENDIENTE')),
 nota numeric(5,2), fecha_retiro date,
 CHECK(nota IS NULL OR nota BETWEEN 0 AND 100),
 CHECK((estado='APROBADO' AND nota IS NOT NULL AND nota>=70 AND fecha_retiro IS NULL)
    OR (estado='REPROBADO' AND nota IS NOT NULL AND nota<70 AND fecha_retiro IS NULL)
    OR (estado='RETIRADO' AND nota IS NULL AND fecha_retiro IS NOT NULL AND fecha_retiro>=fecha)
    OR (estado='PENDIENTE' AND nota IS NULL AND fecha_retiro IS NULL)));
CREATE INDEX ix_grupo_periodo ON grupo(id_periodo,id_curso,id_sede);
CREATE INDEX ix_solicitud_periodo ON solicitud(id_periodo,id_curso,id_sede,id_horario);
CREATE INDEX ix_matricula_grupo ON matricula(id_grupo);
COMMIT;
