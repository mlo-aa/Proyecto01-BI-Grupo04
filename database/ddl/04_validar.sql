SET search_path TO universidad, public;
SELECT * FROM v_controles ORDER BY control;
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM v_controles WHERE incidencias<>0) THEN
 RAISE EXCEPTION 'Fuente no válida: revisar universidad.v_controles';
 END IF;
END $$;
