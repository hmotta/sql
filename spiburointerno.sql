create or replace function spiburointerno(integer,date,integer,integer,integer,integer,numeric,integer,numeric,numeric,numeric,numeric,numeric,character) returns integer 
AS $_$
declare
	psocioid alias for $1;
	pfechageneracion alias for $2;
	ppagospactados alias for $3;
	ppagosenmora alias for $4;
	pcreditospagados alias for $5;
	pcreditosvigentes alias for $6;
	psaldototal alias for $7;
	pdiasatrasomaximo alias for $8;
	pmontoultimocred alias for $9;
	pmontomaximocred alias for $10;
	pcorreccionxanios alias for $11;
	panios alias for $12;
	pcalificacion alias for $13;
	pclasificacion alias for $14;
	sultimoprestamoid character varying (30);
begin
	
	select (case when (select count(*) from prestamos where socioid=psocioid and claveestadocredito='001' and tipoprestamoid<>'P4')>0 then (select tipoprestamoid from prestamos where socioid=psocioid and claveestadocredito='001' and tipoprestamoid<>'P4' group by tipoprestamoid,montoprestamo,fecha_otorga having montoprestamo>=(select max(montoprestamo) from prestamos where socioid=psocioid and claveestadocredito='001') order by fecha_otorga desc limit 1) else (select tipoprestamoid from prestamos where socioid=psocioid and tipoprestamoid<>'P4' order by fecha_otorga desc limit 1) end ) into sultimoprestamoid;
	
	PERFORM prestamoid from prestamos where tipoprestamoid='CAS' and socioid=psocioid;
	if found then
		insert into burointerno (socioid,fechageneracion,pagospactados,pagosenmora,creditospagados,creditosvigentes,saldototal,diasatrasomaximo,montoultimocred,montomaximocred,correccionxanios,anios,calificacion,clasificacion,ultimocred,descultimocred) values(psocioid,pfechageneracion,ppagospactados,ppagosenmora,pcreditospagados,pcreditosvigentes,psaldototal,pdiasatrasomaximo,pmontoultimocred,pmontomaximocred,pcorreccionxanios,panios,0.00,'N/A',sultimoprestamoid,
		(select desctipoprestamo from tipoprestamo where tipoprestamoid=sultimoprestamoid));
	else
		insert into burointerno (socioid,fechageneracion,pagospactados,pagosenmora,creditospagados,creditosvigentes,saldototal,diasatrasomaximo,montoultimocred,montomaximocred,correccionxanios,anios,calificacion,clasificacion,ultimocred,descultimocred) values(psocioid,pfechageneracion,ppagospactados,ppagosenmora,pcreditospagados,pcreditosvigentes,psaldototal,pdiasatrasomaximo,pmontoultimocred,pmontomaximocred,pcorreccionxanios,panios,pcalificacion,pclasificacion,sultimoprestamoid,
		(select desctipoprestamo from tipoprestamo where tipoprestamoid=sultimoprestamoid));
	end if;
	
	return 1;
end
$_$
	LANGUAGE plpgsql SECURITY DEFINER;
