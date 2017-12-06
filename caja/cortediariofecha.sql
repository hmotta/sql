create or replace function cortediariofecha(date,date) returns setof tcortediario
as $_$
declare
	pfecha1 alias for $1;
	pfecha2 alias for $1;
	r tcortediario%rowtype;
begin
	for r in
	select
		 folio,
		 referencia,
		 serie,
		 socioid,
		 clavesocioint,
		 fecha,
		 capital,
		 interes,
		 moratorio,
		 iva,
		 deposito,
		 retiro,
		 tipomovimientoid,
		 '' as tipomovimiento,
		 tipoprestamoid,
		 '' as tipoprestamo,
		 null as ultimomovimiento
	from 
		cortecajafecha('',pfecha1,pfecha2,0) 
	loop
		select desctipomovimiento into r.tipomovimiento from tipomovimiento where tipomovimientoid=r.tipomovimientoid;
		if r.tipomovimientoid='IN' then
			r.tipoprestamoid='';
		else
			select desctipoprestamo into r.tipoprestamo from tipoprestamo where tipoprestamoid=r.tipoprestamoid;
		end if;
		
		select max(p.fechapoliza) into r.ultimomovimiento from movicaja mc natural join polizas p natural join socio s where tipomovimientoid in ('AC','AA','IP','AI','AP','P3','TA','PR','AH','AO','AF','AM','00','IN') and seriecaja not in ('ZA','WW') and socioid=r.socioid;
		
		return next r;
	end loop;
end

$_$
LANGUAGE plpgsql SECURITY DEFINER;