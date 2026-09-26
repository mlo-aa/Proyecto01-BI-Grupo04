"""Genera datos académicos ficticios. Python 3.10+, solo biblioteca estándar.
Ejecutar desde cualquier ruta. Sobrescribe SOLO los CSV y el SQL generado de este paquete.
"""
from pathlib import Path
from datetime import date,timedelta
import csv,random,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
rng=random.Random(20260925)
data={}
def put(name,cols,rows):data[name]=(cols.split(','),rows)
put('carrera','id_carrera,nombre',[(1,'Administración'),(2,'Informática'),(3,'Ingeniería Industrial')])
put('sede','id_sede,nombre',[(1,'Central'),(2,'Norte'),(3,'Pacífico')])
put('docente','id_docente,alias',[(i,f'Docente {i:02}') for i in range(1,19)])
put('modalidad','id_modalidad,nombre',[(1,'Presencial'),(2,'Virtual'),(3,'Híbrida')])
put('horario','id_horario,franja',[(1,'Mañana'),(2,'Tarde'),(3,'Noche')])
periods=[]
for i,(y,n) in enumerate([(2024,1),(2024,2),(2025,1),(2025,2)],1):
 start=date(y,2 if n==1 else 7,1);cut=start+timedelta(days=14);end=date(y,6 if n==1 else 11,30)
 periods.append((i,f'{y}-{n}',y,n,start.isoformat(),cut.isoformat(),end.isoformat()))
put('periodo','id_periodo,codigo,anio,numero,inicio,corte_matricula,fin',periods)
names=['Matemática','Estadística','Programación','Bases de datos','Contabilidad','Economía','Gestión de procesos','Comunicación','Investigación']
put('curso','id_curso,codigo,nombre,creditos',[(i,f'CU{i:03}',name,[4,3,4,4,3,3,4,2,3][i-1]) for i,name in enumerate(names,1)])
put('estudiante','id_estudiante,alias',[(i,f'Estudiante {i:04}') for i in range(1,241)])
put('trayectoria','id_estudiante,id_periodo,id_carrera,cohorte',[(i,p[0],(i-1)%3+1,'2023-1' if i<=120 else '2024-1') for p in periods for i in range(1,241)])
groups=[];lookup={};capacity={};taken={}
for per in periods:
 for course in range(1,10):
  for sede in range(1,4):
   for slot in range(1,4):
    gid=len(groups)+1; cap=5 if sede==1 and slot==1 else rng.choice([10,14,18])
    # Un grupo sin demanda garantizado para verificar LEFT JOIN y ocupación cero.
    if course==9 and sede==3 and slot==3:cap=12
    groups.append((gid,course,per[0],sede,rng.randint(1,18),rng.randint(1,3),slot,slot,cap))
    lookup[(per[0],course,sede,slot)]=gid;capacity[gid]=cap;taken[gid]=0
put('grupo','id_grupo,id_curso,id_periodo,id_sede,id_docente,id_modalidad,id_horario,numero_grupo,capacidad_corte',groups)
requests=[];enroll=[]
for per in periods:
 start=date.fromisoformat(per[4]);cut=date.fromisoformat(per[5])
 students=list(range(1,241));rng.shuffle(students)
 for stu in students:
  for course in rng.sample(range(1,10),4):
   sede=rng.choices([1,2,3],[.6,.25,.15])[0];slot=rng.choices([1,2,3],[.55,.3,.15])[0]
   if course==9 and sede==3 and slot==3:slot=2
   gid=lookup[(per[0],course,sede,slot)];sid=len(requests)+1
   day=start+timedelta(days=rng.randint(0,10));r=rng.random()
   status='NO_ELEGIBLE' if r<.04 else 'DESISTIDA' if r<.07 else 'SIN_CUPO' if taken[gid]>=capacity[gid] else 'ASIGNADA'
   requests.append((sid,stu,per[0],course,sede,slot,day.isoformat(),status))
   if status=='ASIGNADA':
    taken[gid]+=1;endstate=rng.random();withdraw=None;grade=None
    if endstate<.12:state='RETIRADO';withdraw=(cut+timedelta(days=rng.randint(5,65))).isoformat()
    elif endstate<.34:state='REPROBADO';grade=round(rng.uniform(20,69.99),2)
    else:state='APROBADO';grade=round(rng.uniform(70,100),2)
    enroll.append((len(enroll)+1,sid,gid,(day+timedelta(days=1)).isoformat(),state,grade,withdraw))
put('solicitud','id_solicitud,id_estudiante,id_periodo,id_curso,id_sede,id_horario,fecha,resultado',requests)
put('matricula','id_matricula,id_solicitud,id_grupo,fecha,estado,nota,fecha_retiro',enroll)
folder=ROOT/'database/datos';folder.mkdir(parents=True,exist_ok=True)
lines=['-- Datos sintéticos; semilla 20260925. No es un proceso ETL.','BEGIN;','SET search_path TO universidad, public;']
def literal(v):
 if v is None:return 'NULL'
 if isinstance(v,(int,float)):return str(v)
 return "'"+str(v).replace("'","''")+"'"
manifest={'semilla':20260925,'periodos':['2024-1','2024-2','2025-1','2025-2'],'tablas':{}}
for name,(cols,rows) in data.items():
 path=folder/f'{name}.csv'
 with path.open('w',newline='',encoding='utf-8') as f:
  w=csv.writer(f);w.writerow(cols);w.writerows(rows)
 manifest['tablas'][name]={'filas':len(rows),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
 for off in range(0,len(rows),200):
  lines.append(f'INSERT INTO {name} ({",".join(cols)}) VALUES\n'+',\n'.join('('+','.join(map(literal,row))+')' for row in rows[off:off+200])+';')
lines.append('COMMIT;')
(ROOT/'database/dml/02_datos.sql').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(folder/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:len(v[1]) for k,v in data.items()},ensure_ascii=False))
