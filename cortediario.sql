drop TYPE tcortediario cascade;
CREATE TYPE tcortediario AS (
	 folio integer,
	 referencia integer,
	 serie character(2),
	 socioid integer,
	 clavesocioint character varying(15),
	 fecha date,
	 capital numeric,
	 interes numeric,
	 moratorio numeric,
	 iva numeric,
	 deposito numeric,
	 retiro numeric,
	 tipomovimientoid character(2),
	 tipomovimiento character varying(40),
	 tipoprestamoid character(23),
	 tipoprestamo character varying(40),
	 ultimomovimiento date
);

create or replace function cortediario(date) returns setof tcortediario
as $_$
declare
	pfecha alias for $1;
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
		cortecaja('',pfecha,0) where tipomovimientoid not in ('CH','RE','AG','LE','BU','SM','SI','SQ','SB','ST','TC','MV','IU','OP','MC','CM','SK','CF','TU','ET')
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