--Tablon avisos, modificado para mostrar un mensaje a los socios con atraso.

CREATE or replace FUNCTION spstablonsocio(integer) RETURNS SETOF tablon
    AS $_$
declare

 psocioid alias for $1;

 stexto text;
 r tablon%rowtype;


 ptablonid int4;
 lprestamoid int4;
 lmoratorio numeric;
 

begin

    select pr.prestamoid
    into lprestamoid
    from prestamos pr
    where saldoprestamo>0 and pr.socioid=psocioid and claveestadocredito<>'008';

    SELECT moratorio
    into lmoratorio
    FROM spscalculopago(lprestamoid)
    where vencidas>0;  

    delete
    from tablon
    where tablonid=1;

    insert into tablon (tablonid,socioid,fechatablon,textotablon,vigente,usuarioid,fechavigencia)
    values (1,200,'2009-09-25','','S','supervisor','2009-09-25');
    
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

