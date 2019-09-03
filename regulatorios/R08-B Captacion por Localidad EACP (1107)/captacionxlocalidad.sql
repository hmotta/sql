
drop type rcaptacionxlocalidad cascade;
create type rcaptacionxlocalidad as(
	clasificacion character(12),
	localidadcnbv character(7),
	localidad character varying(50),
	saldo numeric,
	tipomovimientoid character (3)
);

CREATE OR REPLACE FUNCTION captacionxlocalidad(date) RETURNS SETOF rcaptacionxlocalidad
    AS $_$

  DECLARE  
  pfechaf   alias for $1;
  r rcaptacionxlocalidad%rowtype;
begin
	for r in 
	select 
		(case when cp.tipomovimientoid='IN' then '211190000000' else '210101000000' end),
		cd.localidadcnbv,
		--s.socioid,
		(select localidad from localidadessiti where clave=cd.localidadcnbv),
		(case when cp.tipomovimientoid='IN' then round(deposito+intdevacumulado) else round(deposito+intdevmensual) end),
		cp.tipomovimientoid 
	from captaciontotal cp, 
		socio s, 
		sujeto su, 
		domicilio d, 
		ciudadesmex cd 
	where fechadegeneracion =pfechaf and 
		cp.socioid=s.socioid and 
		s.sujetoid=su.sujetoid and 
		d.sujetoid=su.sujetoid and 
		cd.ciudadmexid=d.ciudadmexid and 
		cp.desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT','PARTE SOCIAL P3','PARTE SOCIAL','IMPUESTO POR DEP. EN EFECTIVO','PAGO PARCIAL DE CAPITAL SOCIAL')
	loop
		return next r;
	end loop;
return ;

END
$_$
    LANGUAGE plpgsql;

CREATE or replace FUNCTION captacionxlocalidadc(date) RETURNS SETOF rcaptacionxlocalidad
AS $_$
declare
	
	pfecha alias for $1;
	r rcaptacionxlocalidad%rowtype;
  	f record;
  	dblink1 text;
  	dblink2 text;
begin
for f in
		select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
		dblink2:='set search_path to public,'||f.esquema||';select * from  captacionxlocalidad('||''''||pfecha||''''||');';
        
        for r in
           select * from
           dblink(dblink1,dblink2) as
           t2(
			clasificacion character(12),
			localidadcnbv character(7),
			localidad character varying(50),
			saldo numeric,
			tipomovimientoid character (3)
			)
	
        loop
              return next r;
        end loop;

end loop;
return;
end
$_$
    LANGUAGE plpgsql;	

