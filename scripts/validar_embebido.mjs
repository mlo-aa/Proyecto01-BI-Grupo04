process.on("uncaughtException",e=>{console.error(e.message,e.detail??"");process.exit(1)});
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import { fileURLToPath } from 'node:url';
const root=process.argv[2] ?? fileURLToPath(new URL('../',import.meta.url));
const db=new PGlite();
const log={motor:(await db.query('select version()')).rows[0].version,entorno:'PGlite PostgreSQL embebido, no servidor del grupo',archivos:[],controles:[],pruebas_negativas:[]};
for(const path of ['database/ddl/01_fuente.sql','database/dml/02_datos.sql','database/ddl/03_vistas_control.sql','database/ddl/04_validar.sql']){
 await db.exec(fs.readFileSync(root+'/'+path,'utf8'));log.archivos.push({archivo:path,estado:'OK'});
}
log.controles=(await db.query('select * from universidad.v_controles order by control')).rows;
const queries=await db.exec(fs.readFileSync(root+'/database/05_consultas_negocio.sql','utf8'));
log.consultas=queries.filter(x=>x.fields?.length).map((x,i)=>({pregunta:'P'+(i+1),filas:x.rows.length,muestra:x.rows.slice(0,2)}));
log.totales=(await db.query(`SELECT (select count(*) from universidad.solicitud) solicitudes,
(select count(*) from universidad.matricula) matriculas,
(select count(*) from universidad.solicitud where resultado='SIN_CUPO') sin_cupo,
(select count(*) from universidad.solicitud where resultado='NO_ELEGIBLE') no_elegibles,
(select count(*) from universidad.solicitud where resultado='DESISTIDA') desistidas,
(select count(*) from universidad.grupo g where not exists(select 1 from universidad.matricula m where m.id_grupo=g.id_grupo)) grupos_sin_matricula`)).rows[0];
const mutations=[
['pk_duplicada',`insert into universidad.estudiante values(1,'Otro')`,null],
['fk_inexistente',`update universidad.trayectoria set id_carrera=999 where id_estudiante=1`,null],
['nota_fuera_rango',`update universidad.matricula set nota=101 where estado='APROBADO'`,null],
['retiro_con_nota',`update universidad.matricula set nota=0 where estado='RETIRADO'`,null],
['duplicado_solicitud',`insert into universidad.solicitud select 99999,id_estudiante,id_periodo,id_curso,id_sede,id_horario,fecha,resultado from universidad.solicitud limit 1`,null],
['sobrecupo',`update universidad.grupo set capacidad_corte=1 where id_grupo=(select id_grupo from universidad.matricula group by id_grupo having count(*)>1 limit 1)`,'capacidad'],
['fecha_incompatible',`update universidad.matricula set fecha='2030-01-01' where id_matricula=(select min(id_matricula) from universidad.matricula where estado='APROBADO')`,'fechas_matricula']];
for(const [name,sql,control] of mutations){
 await db.exec('BEGIN');let caught=false;
 try {await db.exec(sql); if(control){const rows=(await db.query(`select incidencias from universidad.v_controles where control=$1`,[control])).rows;caught=Number(rows[0].incidencias)>0;}}
 catch(e){if(!control)caught=e.code===(name==='fk_inexistente'?'23503':name==='pk_duplicada'||name==='duplicado_solicitud'?'23505':'23514');else throw e;}
 finally {await db.exec('ROLLBACK');}
 log.pruebas_negativas.push({prueba:name,detectada:caught});if(!caught)throw Error(name+' no detectado');
}
await db.exec(fs.readFileSync(root+'/database/ddl/04_validar.sql','utf8'));
const columns=(await db.query(`SELECT table_name,column_name,data_type,character_maximum_length,numeric_precision,numeric_scale,is_nullable
FROM information_schema.columns WHERE table_schema='universidad' AND table_name NOT LIKE 'v_%' ORDER BY table_name,ordinal_position`)).rows;
const constraints=(await db.query(`SELECT c.relname AS tabla,con.conname AS nombre,pg_get_constraintdef(con.oid) AS regla FROM pg_constraint con JOIN pg_class c ON c.oid=con.conrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='universidad' ORDER BY c.relname,con.conname`)).rows;
fs.writeFileSync(root+'/docs/modelo_transaccional/estructura_verificada.json',JSON.stringify({columns,constraints},null,2));
const csv=(rows)=>[Object.keys(rows[0]).join(','),...rows.map(r=>Object.values(r).map(x=>x==null?'':'"'+String(x).replaceAll('"','""')+'"').join(','))].join('\n')+'\n';
fs.writeFileSync(root+'/docs/modelo_transaccional/campos_fuente.csv',csv(columns));
fs.writeFileSync(root+'/docs/modelo_transaccional/restricciones_fuente.csv',csv(constraints));
fs.writeFileSync(root+'/validacion/resultado_pruebas.json',JSON.stringify(log,null,2));
console.log(JSON.stringify(log,null,2));await db.close();
