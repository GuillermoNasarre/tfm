CREATE OR REPLACE FUNCTION stg.try_cast(_in text, INOUT _out anyelement)
 RETURNS anyelement
 LANGUAGE plpgsql
AS $function$
BEGIN
   EXECUTE format('SELECT %L::%s', $1, pg_typeof(_out))
   INTO  _out;
EXCEPTION WHEN others THEN
   -- do nothing: _out already carries default
END
$function$
;
