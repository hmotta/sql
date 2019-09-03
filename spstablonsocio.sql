CREATE OR REPLACE FUNCTION spstablonsocio(integer) RETURNS SETOF tablon
    AS $_$
declare

 psocioid alias for $1;

 stexto text;
 r tablon%rowtype;


 ptablonid int4;
 lprestamoid int4;
 lmoratorio numeric;
 
 icertificadossinfirmar int4;

begin

    select pr.prestamoid
    into lprestamoid
    from prestamos pr
    where saldoprestamo>0 and pr.socioid=psocioid and claveestadocredito<>'008';

	if FOUND then
		SELECT coalesce(moratorio,0)
		into lmoratorio
		FROM spscalculopago(lprestamoid)
		where vencidas>0;  
	else
		lmoratorio:=0;
	end if;

    delete
    from tablon
    where tablonid in (1,2);

    insert into tablon (tablonid,socioid,fechatablon,textotablon,vigente,usuarioid,fechavigencia)
    values (1,6037,'2009-09-25','','S','supervisor','2009-09-25');
    
    select tablonid
    into ptablonid
    from tablon
    where tablonid=1;
    
    if lmoratorio>0  then
    
    update tablon
    set socioid=psocioid,
        fechatablon=current_date,
        fechavigencia=current_date,
        textotablon='Estimado CAJERO: Por favor comunique y canalice al GERENTE de sucursal ó EJECUTIVO de Crédito, la situación del socio a la brevedad posible.'
    where tablonid=ptablonid;

        end if;
    
	--Se validan los certificados de Partes Sociales Normal y Adicional
	insert into tablon (tablonid,socioid,fechatablon,textotablon,vigente,usuarioid,fechavigencia)
    values (2,6037,'2009-09-25','','S','supervisor','2009-09-25');
	
	select tablonid
    into ptablonid
    from tablon
    where tablonid=2;
    
	
	PERFORM verifirmascertificado(psocioid);
	
	select coalesce(count(*),0) into icertificadossinfirmar from firmascertificado where statusfirma=0 and socioid=psocioid;
	
    if icertificadossinfirmar > 0  then
    
    update tablon
    set socioid=psocioid,
        fechatablon=current_date,
        fechavigencia=current_date,
        textotablon='ATENCION!! El SOCIO tiene '||icertificadossinfirmar||' CERTIFICADOS de parte social NO FIRMADOS, por favor recabe la firma. * * *'
    where tablonid=ptablonid;

    end if;
	
    
    stexto:='';

    for r in
      select *
        from tablon
       where socioid=psocioid and 
             vigente='S'
    loop
      stexto:=stexto||r.textotablon||chr(10)||chr(10);
    end loop;

    r.textotablon:=stexto;
    return next r;
    
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
