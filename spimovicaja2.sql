CREATE OR REPLACE FUNCTION spimovicaja(integer, character, integer, integer, character, integer, integer, character, integer, integer) RETURNS integer
    AS $_$
declare
   psocioid          alias for $1;	
   ptipomovimientoid alias for $2;
   ppolizaid         alias for $3;
   preferenciacaja   alias for $4;
   pseriecaja        alias for $5;
   pmovipolizaid     alias for $6;
   pprestamoid       alias for $7;
   pestatusmovicaja  alias for $8;
   pinversionid      alias for $9;
   pcontratoid       alias for $10;
  
   amort record;

   fprestamos numeric;
   fretiro numeric;
   fdeposito numeric;
   fsaldo  numeric;

   iestatussocio int;

   saplicasaldo char(1);
   saceptadeposito char(1);
   saceptaretiro   char(1);

   stiposocioid char(2);

   fmontopartesocial numeric;
   fsaldopa numeric;
   ipartesocialcompleta int4;
  
   lsocioid int4;

   irepetido int4;

-- IDE

   fdepositoefectivo numeric;
   fsumaefectivo numeric;
   psaldo numeric;
   pefectivo integer;

   pfecha date;

   scuentacaja char(24);
   scuentadeposito char(24);

   pnumero_poliza int4;
   preferencia int4;

   lreferenciacaja int4;

   ppolizaid1 int4;
   pmovipolizaid1 int4;
   pmovipolizaid2 int4;
   fideexento numeric;
   fporide numeric;
   freciprocidad numeric;
   
   susuarioid character(20);

   fdepaplicar numeric;
   iautorizacionid integer;
   imovicajaid integer;
   ptipomovimientoret char(2);

   
begin


   
   --Abrir y cerrar cajas

---

 if ptipomovimientoid='00' then
     -- Validar que el prestamo corresponda al socio

     select socioid into lsocioid
       from prestamos where prestamoid=pprestamoid;
     if lsocioid<>psocioid then
       raise exception 'Verifique el prestamo no corresponde al socio !!!';
     end if;
   end if;

  

   if ptipomovimientoid='IN' then
     -- Validar que la inversion corresponda al socio

     select socioid into lsocioid
       from inversion where inversionid=pinversionid;
     if lsocioid<>psocioid then
       raise exception 'Verifique la inversion no corresponde al socio !!!';
     end if;

   end if;

   select estatussocio,tiposocioid into iestatussocio,stiposocioid
     from socio
    where socioid=psocioid;

   select montopartesocial,partesocialcompleta,ideexento,poride
       into fmontopartesocial,ipartesocialcompleta,fideexento,fporide
       from empresa where empresaid=1;


   if stiposocioid='02' and
      (ptipomovimientoid<>'00' and ptipomovimientoid<>'PA' and
       ptipomovimientoid<>'RE' and ptipomovimientoid<>'CH' and
       ptipomovimientoid<>'MG' and ptipomovimientoid<>'BS') then

   
     if ipartesocialcompleta=1 then
       -- Validar que tenga la parte social
       select sum(mp.debe)-sum(mp.haber) into fsaldopa
         from movicaja mc, movipolizas mp
        where mc.socioid=psocioid and
              mc.tipomovimientoid='PA' and
              mp.movipolizaid=mc.movipolizaid;
       fsaldopa:=coalesce(fsaldopa,0);

       if fsaldopa<fmontopartesocial then
         raise exception 'El socio no tiene cubierta su parte social';
       end if;
     end if;
   end if;

   select aplicasaldo,aceptadeposito,aceptaretiro
     into saplicasaldo,saceptadeposito,saceptaretiro
     from tipomovimiento where tipomovimientoid=ptipomovimientoid;

   if iestatussocio=2 and ptipomovimientoid<>'PA' then
     raise exception 'No se pueden realizar movimientos en socios dados de BAJA.';
   end if;

   if stiposocioid='01' and
      (ptipomovimientoid='00') then
       raise exception 'El socio menor no puede realizar el tipo de movimiento %',ptipomovimientoid;
   end if;

   if stiposocioid='01' and ptipomovimientoid='AA' then
       raise exception 'El socio menor no puede realizar el tipo de movimiento %',ptipomovimientoid;
   end if;

   if stiposocioid='02' and ptipomovimientoid='AM' then
       raise exception 'El socio Mayor no puede realizar el tipo de movimiento %',ptipomovimientoid;
   end if;

   select sum(p.montoprestamo/tp.tantos) into fprestamos
    from prestamos p, tipoprestamo tp
   where p.socioid = psocioid and
         p.saldoprestamo>0 and
         tp.tipoprestamoid = p.tipoprestamoid and
         tp.tipomovimientoid = ptipomovimientoid and
         tp.tantos>0 and
         p.claveestadocredito<>'008';

   select debe,haber into fdeposito,fretiro
    from movipolizas
   where movipolizaid=pmovipolizaid;

   if iestatussocio=1 and ptipomovimientoid='PA' and fretiro>0 then
     raise exception 'El socio debe pasar primeramente a informaci?n a realizar su BAJA Antes de realizar el retiro de su PARTE SOCIAL';
   end if;

   fdeposito := coalesce(fdeposito,0);
   fretiro := coalesce(fretiro,0);

   fprestamos := coalesce(fprestamos,0);

   -- Validar que el tipo de movimiento acepte el deposito o el retiro
   if fdeposito>0 and saceptadeposito='N' then
     raise exception 'En este tipo de movimiento % no se pueden realizar depositos.',ptipomovimientoid;
   end if;
   if fretiro>0 and saceptaretiro='N' then
     raise exception 'En el tipo de movimiento % no se pueden realizar retiros.',ptipomovimientoid;
   end if;


   -- Validar que no retire mas de lo que tiene en Saldo
   select sum(mp.debe)-sum(mp.haber) into fsaldo
     from movicaja mc, movipolizas mp
    where mc.socioid=psocioid and
          mc.tipomovimientoid=ptipomovimientoid and
          mp.movipolizaid=mc.movipolizaid;

   fsaldo:=coalesce(fsaldo,0);

   if saplicasaldo='S' and
      fretiro>fsaldo and
      ptipomovimientoid<>'IN' and
      ptipomovimientoid<>'RM' and
      ptipomovimientoid<>'RE' then
      raise exception 'El socio no puede retirar mas de su Saldo.';
   end if;

   -- Validar la promocion
   --if not validapromocion(psocioid,ptipomovimientoid,fretiro) then
   --  raise exception 'El socio no pude realizar retiro por que esta en una promoci?n';
   --end if;

   -- Verificar el retiro de interes al ahorro
   if ptipomovimientoid='IA' and fretiro>0 and fretiro<>fsaldo then
     raise exception 'El interes al ahorro debe ser retirado en su totalidad.';
   end if;


   if fretiro>0 then
     
    freciprocidad:=round(reciprocidadactual(psocioid,ptipomovimientoid),2);

    if fretiro>fsaldo-freciprocidad and saplicasaldo='S' and ptipomovimientoid<>'IN' and ptipomovimientoid<>'RM' and ptipomovimientoid<>'RE' then
        raise exception 'El socio no puede realizar este tipo de movimiento, es garantia de algun prestamo del socio.  Reciprocidad=%',freciprocidad;
    end if;

    if ptipomovimientoid = 'AA' then 
       freciprocidad:=round(reciprocidadactualAA(psocioid),2);
       if fretiro>fsaldo-freciprocidad and saplicasaldo='S' and ptipomovimientoid<>'IN' and ptipomovimientoid<>'RM' and ptipomovimientoid<>'RE' then
           raise exception 'El socio no puede realizar este tipo de movimiento, AA es garantia de algun prestamo del socio.  Reciprocidad=%',freciprocidad;
        end if;   
    end if;    
   end if;

----

   select sum(valor) into fdepositoefectivo from sabana where referenciacaja=preferenciacaja and seriecaja = pseriecaja and entradasalida=0 and denominacionid in (select denominacionid from denominacion where efectivo=1);

   if fdepositoefectivo >= fdeposito then
     pefectivo:=1;
   else
     pefectivo:=0;
   end if;

   insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,saldoactual,efectivo,fechahora,contratoid)
   values(psocioid,ptipomovimientoid,ppolizaid,preferenciacaja,pseriecaja,pmovipolizaid,pprestamoid,pestatusmovicaja,pinversionid,fsaldo,pefectivo,current_timestamp,pcontratoid);

   -- Insertando el numero de autorizacion
   
  
------------------------------------------

-- Impuesto Deposito en efectivo

   raise notice ' Voy a efectuar el ide credito ';

   if ptipomovimientoid in ((select tipomovimientoid from tipomovimiento where tipomovimientoid<>'CI' and tipomovimientoid<>'IP'  and ptipomovimientoid<>'AH' and tipomovimientoid<>'RE' and aplicasaldo='S') union (select (case when exists (select socioid from datosfiscales where socioid =psocioid) then '**' else '00' end) )) and  pefectivo=1 then


     select fechapoliza into pfecha from polizas where polizaid=ppolizaid;
     select cuentacaja into scuentacaja from parametros where serie_user=pseriecaja;

     select sumadepositos into fsumaefectivo from sumadepositos(ptipomovimientoid,pfecha,psocioid);
         
     if fsumaefectivo > fideexento then

      psaldo:=0;
      if fsumaefectivo-fdeposito > fideexento then 
         psaldo := fdeposito * fporide;
      else            
         psaldo := (fsumaefectivo-fideexento) * fporide;
      end if;

      --
      -- Dar de alta la poliza contable para el IDE
      --

      select fechapoliza into pfecha from polizas where polizaid=ppolizaid;
      select cuentacaja into scuentacaja from parametros where serie_user=pseriecaja;

      select cuentadeposito into scuentadeposito from tipomovimiento where tipomovimientoid='ID';


      select *
        into pnumero_poliza,preferencia
        from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pseriecaja,'A');

      -- Encabezado de la poliza
      select * 
        into ppolizaid1
        from spipolizasfecha(preferencia,pseriecaja,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','IMPUESTO DEPOSITOS EN EFECTIVO',pfecha);

      -- Detalle de la poliza

      select *
        into pmovipolizaid1
        from spimovipoliza(ppolizaid1,scuentacaja,' ','C',psaldo,0,' ',' ','IDE');

      select *
        into pmovipolizaid2
        from spimovipoliza(ppolizaid1,scuentadeposito,' ','A',0,psaldo,' ',' ','IDE');

      insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,saldoactual,efectivo)
      values(psocioid,'ID',ppolizaid1,preferenciacaja,pseriecaja,pmovipolizaid1,NULL,pestatusmovicaja,NULL,0,1);


      -- Dar de alta la poliza retiro de caja para el IDE
      --
 
      if ptipomovimientoid <> '00' then
            select cuentaretiro into scuentadeposito from tipomovimiento where tipomovimientoid=ptipomovimientoid;
            ptipomovimientoret:=ptipomovimientoid;
      else
            select cuentaretiro,tipomovimientoid into scuentadeposito,ptipomovimientoret from tipomovimiento where tipomovimientoid in (select tp.tipomovimientoid from prestamos p, tipoprestamo tp where p.prestamoid=pprestamoid and p.tipoprestamoid=tp.tipoprestamoid);
      end if;      

      raise notice ' cuenta retiro %  sumadepositos %  ide % ',scuentadeposito,fsumaefectivo,psaldo;
      
      select *
        into pnumero_poliza,preferencia
        from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pseriecaja,'A');

      -- Encabezado de la poliza
      select * 
        into ppolizaid1
        from spipolizasfecha(preferencia,pseriecaja,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','IMPUESTO DEPOSITOS EN EFECTIVO',pfecha);

      -- Detalle de la poliza

      select *
        into pmovipolizaid1
        from spimovipoliza(ppolizaid1,scuentacaja,' ','A',0,psaldo,' ',' ','IDE');

      select *
        into pmovipolizaid2
        from spimovipoliza(ppolizaid1,scuentadeposito,' ','C',psaldo,0,' ',' ','IDE');


      insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,saldoactual,efectivo)
      values(psocioid,ptipomovimientoret,ppolizaid1,preferenciacaja,pseriecaja,pmovipolizaid1,NULL,pestatusmovicaja,NULL,0,1);

     end if;

   end if;
   
return currval('movicaja_movicajaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;