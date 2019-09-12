CREATE or replace FUNCTION primexencion(integer) RETURNS integer
    AS $_$
declare

  psocioid alias for $1;
  pejercicio int4;
begin
		
	pejercicio := cast(date_part('year',current_date) as int4);
	
	--Si existe la exension es decir ya se aplico alguna vez en el año
    if EXISTS(select inversionid from inversion where fechainversion between date_part('year',current_date)||'-01-01' and current_date  and exencionisr=1 and tipoinversionid not in ('PSO','PSV') and socioid=psocioid) then
		return 0;
    else
	--primera exension
		return 1;
    end if;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;