
CREATE OR REPLACE FUNCTION llenafirmascertificado() RETURNS integer
    AS $$
declare
r record;
l record;
--psocioid alias for $1;
nsaldopa numeric;
psocioid int4;

j integer;

begin
j:=1;

for l in
	select socioid from socio where estatussocio<>2 and tiposocioid='02' 
loop
	psocioid:=l.socioid;
	select saldomov(psocioid,'PA',current_date) into nsaldopa from socio where socioid=psocioid;
	if nsaldopa=1000.00 then
		if not exists (select foloid from firmascertificado where socioid=psocioid and tipomovimientoid='PA') then
			j:=j+1;
			insert into firmascertificado( foloid,socioid,tipomovimientoid,folioini,foliofin,statusfirma) values (1,psocioid,'PA',1,1,0);
			raise notice ' 1, PA, Activo';
		end if;
	end if;

	for r in select folioid,tipomovimientoid,folioini,foliofin,vigente from foliops where socioid=psocioid
	   loop
	   
		  if not exists (select foloid from firmascertificado where foloid=r.folioid) and r.vigente='S' then

			 insert into firmascertificado( foloid,socioid,tipomovimientoid,folioini,foliofin,statusfirma) values (r.folioid,psocioid,r.tipomovimientoid,r.folioini,r.foliofin,0);
			 j:=j+1;       

			 raise notice ' %  %  Activo',r.folioid,r.tipomovimientoid;
		  end if;
		  
		  if exists (select foloid from firmascertificado where foloid=r.folioid) and r.vigente='N' then
			  update firmascertificado set statusfirma=2 where foloid=r.folioid;
			  raise notice ' %  %  Inactivo',r.folioid,r.tipomovimientoid;
		  end if;

	   end loop;

end loop;
return j;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;
