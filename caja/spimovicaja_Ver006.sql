--Modificada el 23 de Enero del 2012, Correcion al cobro de IDE en  depositos en IP 
CREATE OR REPLACE FUNCTION spimovicaja(integer, character, integer, integer, character, integer, integer, character, integer, integer, numeric) RETURNS integer
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
   pautorizacionid   alias for $11;
   
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
   primermovimiento numeric;
   creferenciaprestamomc char(18);
   creferenciaprestamomb char(18);
   iinversionsinpasar integer;

   fserie_user character(2);
   fcuentacaja character(24);
   fsaldocuenta numeric;
   ppermiso character(1);

   ngarantiarequerida numeric;
   ngarantiaactual numeric;
   nmontopartesocial numeric;
   nsaldoenpa numeric;

   ccuentap3 character(24);
   fmontomovp3 numeric;
   
   ccuentamov character(24);
   fmontomovsaldo numeric;
   fmontomovpoliza numeric;
   fmontomov numeric;
   fmontomaximo numeric;
   fmontominimo numeric;
   
-- >> Validar Folios de P3 hmota-2012/04/10
	ipartes real;
	iejercicio integer;
	iperiodo integer;
	ifolioini integer;
	ifoliofin integer;
	ssaldoinversion numeric;
	stipoinversionid character(3);
	pinversionanteriorid integer;
	nsaldoinversion numeric;
	ninteresinversion numeric;
-- << Validar Folios de P3 hmota-2012/04/10

	


-- >> Validar Condonacion de los Gastos de cobranza hmota-2012/10/03
	fgastoscond numeric;
-- << Validar Condonacion de los Gastos de cobranza hmota-2012/10/03   

   ccuentatipoprestamo character(24);
   fmontoprestamo numeric;
   prestamocontabilizado numeric;
 iprestamosdeldia integer;
 
 sdia character(2);
begin
raise notice 'Movicaja...';

   nmontopartesocial:=500.00;
   
   iautorizacionid:=trunc(pautorizacionid); --Autorizacion de bonificacion
   --Abrir y cerrar cajas

-- Validar apertura de caja

    select serie_user,cuentacaja,usuarioid
      into fserie_user,fcuentacaja,susuarioid
      from parametros
    where serie_user=pseriecaja;
   
   select sum(debe)-sum(haber) as saldocuenta into fsaldocuenta
     from movipolizas
    where cuentaid=fcuentacaja and polizaid in (select polizaid
                                                from polizas
                                                where fechapoliza < current_date and seriepoliza=pseriecaja);
                                                
   select p.permiso
     into ppermiso
     from parametros pa, permisosmodulos p
    where pa.serie_user =pseriecaja  and
          p.usuarioid = pa.usuarioid and
          p.clavemodulo = 'ABCER';

   ppermiso := coalesce(ppermiso,'N');
   
   if fsaldocuenta>0 and ppermiso='N' then
       raise exception 'No tienes permitido operar cajas con días pendientes por cerrar.';
   end if;

  select debe,haber
   into fdeposito,fretiro
   from movipolizas
   where movipolizaid=pmovipolizaid;


--->>  Inicio a validar primer movimiento RE

--   select count(*)
--   into primermovimiento
--   from movicaja
--   where tipomovimientoid='RE' and seriecaja=pseriecaja and estatusmovicaja='A' and polizaid in (select polizaid
--                                                                                                 from polizas
--                                                                                                 where fechapoliza=current_date);

--   if pseriecaja<>'XY' and primermovimiento='0' and ptipomovimientoid<>'RE' or primermovimiento='0' and ptipomovimientoid='RE' and fretiro>0 then
   
--   raise exception '¡Tu primer movimiento del día debe una dotación';
--   end if;
------< Termino de validar primer movimiento RE

---->> Inicio a validar que no hagan remesa sino han entregado todos sus créditos.*/
--    select count(*),referenciaprestamo
--    into creferenciaprestamomc
--    from prestamos
--    where fecha_otorga=current_date and claveestadocredito<>'008' and prestamoid not in (select prestamoid
--                                                           from movicaja
--                                                           where prestamoid is not null) group by referenciaprestamo;
--    select count(*),referenciaprestamo
--    into creferenciaprestamomb
--    from prestamos
--    where fecha_otorga=current_date and claveestadocredito<>'008' and prestamoid not in (select prestamoid
--                                                           from movibanco
--                                                           where prestamoid is not null) group by referenciaprestamo;

select count(*) into iprestamosdeldia from prestamos where claveestadocredito<>'008' and fecha_otorga=current_date and prestamoid not in ((select distinct(prestamoid) from movibanco where prestamoid is not null) union (select distinct(prestamoid) from movicaja where estatusmovicaja='A' and tipomovimientoid='RM' and prestamoid is not null));
                                                          

   if ptipomovimientoid='RE' and fretiro>0 and iprestamosdeldia>0 then
--   if ptipomovimientoid='RE' and fretiro>0 and iprestamosdeldia>0creferenciaprestamomc>0 and creferenciaprestamomb>0 then
   
   raise exception 'Retira tus créditos otorgados en el día, para poder realizar el retiro de dotación';
   
   end if;   
-----<< Termino de validar que no hagan remesa sino han entregado todos sus créditos.*/

---->> Inicio a validar que no hagan remesa sino han pasado por caja sus inversiones.*/
	select count(*) into iinversionsinpasar from inversion where fechainversion=current_date and depositoinversion>0 and inversionid not in(select inversionid from movicaja where inversionid is not null and estatusmovicaja='A');
                                                          

   if ptipomovimientoid='RE' and fretiro>0 and iinversionsinpasar>0 then
   
   raise exception 'Debes pasar por caja las inversiones del día de hoy, para poder realizar el retiro de dotación';
   
   end if;   
-----<< Termino de validar que no hagan remesa sino han pasado por caja sus inversiones.*/


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

----- >> Validar saldo en PA
	   
--         select coalesce(sum(saldo),0) into nsaldoenpa from spssaldosmov(psocioid) where tipomovimientoid in ('PA');

-- 	if (nsaldoenpa < nmontopartesocial) and ptipomovimientoid<>'PA' and psocioid not in (select socioid from socio s, sujeto su where s.sujetoid=su.sujetoid and paterno||' '||materno||' '||nombre like '%CAJA%') and stiposocioid='02' then 
-- 	   raise exception 'El socio no tiene completa su parte social, saldoactual: % \n No puede hacer movimientos en caja!',nsaldoenpa;
-- 	end if;

----- << Validar saldo en PA

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



-- >> Validar tipos de movimiento permitidos por tipo de socio
   if stiposocioid='01' and ptipomovimientoid in ('AF','AA','AO') then
      raise notice 'Error. Menor con movimiento de mayor %',ptipomovimientoid;
      raise exception 'El socio Menor no puede realizar el tipo de movimiento % ',ptipomovimientoid;
   end if;

   if stiposocioid='02' and ptipomovimientoid in ('AM') then
      raise notice 'Error. Mayor con movimiento de menor %',ptipomovimientoid;
      raise exception 'El socio Mayor no puede realizar el tipo de movimiento % ',ptipomovimientoid;
   end if;

-- << Termina de validar tipo de movimiento


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
	raise notice 'Saldo=% ',fsaldo;
   if saplicasaldo='S' and
      fretiro>fsaldo and
      ptipomovimientoid<>'IN' and
      ptipomovimientoid<>'RM' and
      ptipomovimientoid<>'RE' then
      raise exception 'El socio no puede retirar mas de su Saldo.';
   end if;

   
-->> Validar el Ahorro Futuro y Ahorro Futuro Infantil de acuerdo a las Reestricciones del manual
   if ptipomovimientoid in ('AF') and fretiro>0 then
		select * into sdia from substr(now(),9,2);
		raise notice 'validare el ahorro futuro AF ... Dia = %',sdia;
		if sdia not in ('01','02','03','04','05') then
			--raise exception 'Este producto solo se puede retirar en los primeros 5 dias del mes.';
		end if;
   end if;
   --<< Fin validar Ahorro Futuro
   
   
   -->> Validar Montos Maximos y Minimos de ahorro
   select cuentadeposito into ccuentamov from tipomovimiento where tipomovimientoid=ptipomovimientoid;
   select sum(haber)-sum(debe) into fmontomovpoliza from movipolizas where polizaid =ppolizaid and cuentaid=ccuentamov;   
   select montomaximo into fmontomaximo from extensiontipomovimiento where tipomovimientoid=ptipomovimientoid;
   select montominimo into fmontominimo from extensiontipomovimiento where tipomovimientoid=ptipomovimientoid;
   --if fmontomovpoliza<0 then
	--	fmontomovpoliza:=fmontomovpoliza*-1;
   --end if;
   raise notice 'MontoSaldo=% , MontoPoliza= %',fsaldo,fmontomovpoliza;
   
   fmontomov:=fsaldo+fmontomovpoliza;
   
   raise notice 'Monto=% | MontoMinimo=% | MontoMaximo=% ',fmontomov,fmontominimo,fmontomaximo;
   
   if fmontomov > fmontomaximo then
		raise exception 'El saldo maximo para este tipo de cuenta % es de $ %.',ptipomovimientoid,fmontomaximo;
	end if;
		
   if fmontomov < fmontominimo and fmontomov<>0 and fmontomov>0 and fretiro>0 then
		raise exception 'El saldo minimo para este tipo de cuenta % es de $ %.',ptipomovimientoid,fmontominimo;
   end if;
   --<< Fin Validar Montos Maximos y Minimos de ahorro
   
   
   
--# Validar multiplos de 500 P3
if ptipomovimientoid='P3' then 
   raise notice 'movimiento p3, validaré multiplos';
   select cuentadeposito into ccuentap3 from tipomovimiento where tipomovimientoid='P3';

   select sum(debe)-sum(haber) into fmontomovp3 from movipolizas where polizaid =ppolizaid and cuentaid=ccuentap3;

   if fmontomovp3 <0 then 
      fmontomovp3:=fmontomovp3*-1;
   end if;
   raise notice 'Traigo %',(fmontomovp3/500)-trunc(fmontomovp3/500);
   if ((fmontomovp3/500)-trunc(fmontomovp3/500))>0 then
       raise exception 'Los movimientos en P3 deben ser multiplos de 500.00, verifique!!!';
   end if;
   raise notice 'Termina';
end if;

raise notice 'Validare ... %',ptipomovimientoid;
--------
if ptipomovimientoid='00' then 
   select cuentaactivo into ccuentatipoprestamo from tipoprestamo tp, prestamos p where tp.tipoprestamoid=p.tipoprestamoid and prestamoid=pprestamoid;
   select montoprestamo into fmontoprestamo from prestamos where prestamoid=pprestamoid;
   select sum(debe) into prestamocontabilizado from movipolizas where cuentaid=ccuentatipoprestamo and polizaid in (select polizaid from movibanco where prestamoid=pprestamoid union all select polizaid from movicaja where prestamoid=pprestamoid);
   prestamocontabilizado:=coalesce(prestamocontabilizado,0);

   raise notice 'Prestamoid:%, Cuentaactivo:%, Montoprestamo:%, Retiro: %',pprestamoid,ccuentatipoprestamo,fmontoprestamo,prestamocontabilizado;

   if prestamocontabilizado<fmontoprestamo then 
--raise exception 'No se ha retirado el credito!';
   end if;
end if;
----->> Validar reriro de PA
--   if ptipomovimientoid='PA' and fretiro >0 and (fretiro>(fsaldo-nmontopartesocial)) then 
  --     raise exception 'El socio no puede incompletar su parte social!';
   --end if;

-----<< Validar saldo en PA


   -- Validar la promocion
   --if not validapromocion(psocioid,ptipomovimientoid,fretiro) then
   --  raise exception 'El socio no pude realizar retiro por que esta en una promoci?n';
   --end if;

   -- Verificar el retiro de interes al ahorro
   if ptipomovimientoid='IA' and fretiro>0 and fretiro<>fsaldo then
     raise exception 'El interes al ahorro debe ser retirado en su totalidad.';
   end if;


   if fretiro>0 then
     
--    freciprocidad:=round(reciprocidadactual(psocioid,ptipomovimientoid),2);

    -- validar monto garantia
RAISE NOTICE 'VALIDARE GARANTIAAAAAAA';

	if ptipomovimientoid='IN' then
			raise notice 'inversionid== %',pinversionid;
			select tipoinversionid into stipoinversionid from inversion where inversionid=pinversionid;
	end if;
	
	if ptipomovimientoid in ('AA','P3') or stipoinversionid='PSO' then 
		select coalesce(sum(saldo),0) into ngarantiaactual from spssaldosmov(psocioid) where tipomovimientoid in ('P3','AA');
		
		if stipoinversionid='PSO' then 
			select coalesce(SUM((case when mp.cuentaid=t.cuentapasivo then mp.haber-mp.debe else 0 end)),0) into nsaldoinversion from polizas p, movicaja m, movipolizas mp, inversion i,tipoinversion t where i.socioid=psocioid and i.fechainversion<=current_date and m.inversionid = i.inversionid and p.polizaid = m.polizaid and p.fechapoliza <= CURRENT_DATE and t.tipoinversionid = i.tipoinversionid and mp.polizaid = p.polizaid and i.tipoinversionid='PSO';
			select interesinversion into ninteresinversion from spsinversion(pinversionid);		
			raise notice 'saldoinversion==%',nsaldoinversion;
			ngarantiaactual:=ngarantiaactual+nsaldoinversion+ninteresinversion;
		end if;
		
		raise notice 'garantiaactual==%',ngarantiaactual;
		select coalesce(sum(monto_garantia),0) into ngarantiarequerida from prestamos where claveestadocredito='001' and clavegarantia='02' and socioid=psocioid;
		raise notice '(ngarantiaactual-fretiro)==% , %',(ngarantiaactual-fretiro),ngarantiarequerida;
	if (ngarantiaactual-fretiro)<ngarantiarequerida then 
	   raise exception 'El monto en garantía no puede ser menor a: %',round(ngarantiarequerida,2);
	end if;
    end if;

--     if fretiro>fsaldo-freciprocidad and saplicasaldo='S' and ptipomovimientoid<>'IN' and ptipomovimientoid<>'RM' and ptipomovimientoid<>'RE' then
--         raise exception 'El socio no puede realizar este tipo de movimiento, es garantia de algun prestamo del socio.  Reciprocidad=%',freciprocidad;
--     end if;
-- 
--     if ptipomovimientoid = 'AA' then 
--        freciprocidad:=round(reciprocidadactualAA(psocioid),2);
--        if fretiro>fsaldo-freciprocidad and saplicasaldo='S' and ptipomovimientoid<>'IN' and ptipomovimientoid<>'RM' and ptipomovimientoid<>'RE' then
--            raise exception 'El socio no puede realizar este tipo de movimiento, AA es garantia de algun prestamo del socio.  Reciprocidad=%',freciprocidad;
--         end if;   
--     end if;    
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

   -->bitacora de accesos
    insert into
bitacoraaccesos(clavemodulo,descripcionmodulos,usuarioid,fecha,fechahora,acceso,tipomovimientoid,deposito,retiro)
      values
('CAJA',ptipomovimientoid,susuarioid,current_date,current_timestamp,'S',ptipomovimientoid,fdeposito,fretiro);

	--<

   imovicajaid:=currval('movicaja_movicajaid_seq');
 
	-- >> Validar Folios de P3 hmota-2012/04/10
	if ptipomovimientoid='P3' then 
	   select saldomov into fmontomovp3 from saldomov(psocioid,'P3',current_date);
	   update foliops set vigente='N' where socioid=psocioid and tipomovimientoid='P3';
	   if fmontomovp3>0 then
			select ejercicio,periodo into iejercicio,iperiodo from polizas where polizaid=ppolizaid;
			ipartes = fmontomovp3/500;
			select coalesce(max(foliofin)+1,1) into ifolioini from foliops where ejercicio=iejercicio and tipomovimientoid=ptipomovimientoid;
			ifoliofin:=ifolioini+ipartes-1;
			insert into foliops(socioid,movicajaid,tipomovimientoid,ejercicio,periodo,folioini,foliofin,vigente,inversionid) values(psocioid,imovicajaid,'P3',iejercicio,iperiodo,ifolioini,ifoliofin,'S',NULL);
	   end if;
	else
		if ptipomovimientoid='IN' then
			raise notice 'inversionid== %',pinversionid;
			select tipoinversionid,coalesce(inversionanteriorid,0) into stipoinversionid,pinversionanteriorid from inversion where inversionid=pinversionid;
			if stipoinversionid in ('PSO','PSV') THEN
				if pinversionanteriorid=0 then --Es una inversion nueva
					raise notice 'tipoinversionid== %',stipoinversionid;
					
					select SUM((case when mp.cuentaid=t.cuentapasivo then mp.haber-mp.debe else 0 end)) into ssaldoinversion from polizas p, movicaja m, movipolizas mp, inversion i,tipoinversion t where i.socioid=psocioid and i.fechainversion<=current_date and m.inversionid = i.inversionid and p.polizaid = m.polizaid and p.fechapoliza <= CURRENT_DATE and t.tipoinversionid = i.tipoinversionid and mp.polizaid = p.polizaid and i.inversionid=pinversionid;
					
					if ssaldoinversion>0  then
						--Deposito
						raise notice 'Inversion nueva== %',pinversionid;
						select ejercicio,periodo into iejercicio,iperiodo from polizas where polizaid=ppolizaid;
						ipartes = ssaldoinversion/500;
						select coalesce(max(foliofin)+1,1) into ifolioini from foliops where ejercicio=iejercicio and tipomovimientoid=stipoinversionid;
						ifoliofin:=ifolioini+ipartes-1;
						insert into foliops(socioid,movicajaid,tipomovimientoid,ejercicio,periodo,folioini,foliofin,vigente,inversionid) values(psocioid,imovicajaid,stipoinversionid,iejercicio,iperiodo,ifolioini,ifoliofin,'S',pinversionid);
						
					else
						--Retiro
						update foliops set vigente='N' where socioid=psocioid and tipomovimientoid=stipoinversionid and inversionid=pinversionid;
					end if;
				else
					raise notice 'Reinversion anterior== % actual==%',pinversionanteriorid,pinversionid;
					update foliops set vigente='S' where socioid=psocioid and tipomovimientoid=stipoinversionid and inversionid=pinversionanteriorid;
					update foliops set inversionid=pinversionid,movicajaid=imovicajaid where socioid=psocioid and tipomovimientoid=stipoinversionid and inversionid=pinversionanteriorid;
				end if;
			end if;
		end if;
	end if;
   -- << Validar Folios de P3 hmota-2012/04/10
   
   --validar el pago de seguroy del ahorro reciprocidad en la tabla de amortizaciones
   
   if fdeposito > 0 and ptipomovimientoid in ('AA','AR','0A','0B','0C','00') and pprestamoid is not null then

      --raise notice ' Voy a aplicar en amortizaciones %',fdepaplicar;
   
      if ptipomovimientoid in ('AA','AR') then

          fdepaplicar:=fdeposito;

          for amort in select amortizacionid,ahorro,ahorropagado from amortizaciones where prestamoid=pprestamoid and ahorro> ahorropagado order by fechadepago
          loop
           if fdepaplicar > 0 then 
             if fdepaplicar > amort.ahorro-amort.ahorropagado then

                update amortizaciones set ahorropagado= amort.ahorro-amort.ahorropagado where amortizacionid=amort.amortizacionid;
                fdepaplicar:=  fdepaplicar- (amort.ahorro-amort.ahorropagado);
                
             else
             
                update amortizaciones set ahorropagado= fdepaplicar where amortizacionid=amort.amortizacionid;
                fdepaplicar:=  0;

             end if;
           end if;  
          end loop;
      end if;

      fdepaplicar:=0;
      
      if ptipomovimientoid in ('0A','00') then --Gastos de cobranza

          select sum(haber) into fdepaplicar from movipolizas where polizaid=ppolizaid and cuentaid in (select cuentadeposito from tipomovimiento where tipomovimientoid = '0A');
          select cobranza into fgastoscond from autorizabonificacion where autorizacionid=iautorizacionid and aplicado=0;
		  raise notice '***Gastos De Cobranza';
		  raise notice 'cobranzapagado= % cobranzacondonado= %',fdepaplicar,fgastoscond;
          fdepaplicar:=coalesce(fdepaplicar,0)+coalesce(fgastoscond,0);
          for amort in select amortizacionid,cobranza,cobranzapagado from amortizaciones where prestamoid=pprestamoid and cobranza> cobranzapagado order by fechadepago
          loop
            if fdepaplicar > 0 then 
             if fdepaplicar > amort.cobranza-amort.cobranzapagado then
				
                update amortizaciones set cobranzapagado= amort.cobranza-amort.cobranzapagado where amortizacionid=amort.amortizacionid;
				raise notice 'update amortizaciones: set cobranzapagado= % - %',amort.cobranza,amort.cobranzapagado;
                fdepaplicar:=  fdepaplicar- (amort.cobranza-amort.cobranzapagado);
                raise notice 'fdepaplicar= %',fdepaplicar;
             else
             
                update amortizaciones set cobranzapagado= fdepaplicar where amortizacionid=amort.amortizacionid;
				raise notice 'update amortizaciones: set cobranzapagado= % ',fdepaplicar;
                fdepaplicar:=  0;
				raise notice 'fdepaplicar= %',fdepaplicar;
             end if;
            end if; 
          end loop;
      end if;

      fdepaplicar:=0;  

      if ptipomovimientoid in ('0C') then

          select sum(haber) into fdepaplicar from movipolizas where polizaid=ppolizaid and cuentaid in (select cuentadeposito from tipomovimiento where tipomovimientoid = ptipomovimientoid);
          
          fdepaplicar:=coalesce(fdepaplicar,0);

          raise notice ' Voy a aplicar el seguro %',fdepaplicar;
           
          for amort in select amortizacionid,seguro,seguropagado from amortizaciones where prestamoid=pprestamoid and seguro> seguropagado order by fechadepago
          loop

            if fdepaplicar > 0 then 

             if fdepaplicar > amort.seguro-amort.seguropagado then

                update amortizaciones set seguropagado= amort.seguro-amort.seguropagado where amortizacionid=amort.amortizacionid;
                fdepaplicar:=  fdepaplicar- (amort.seguro-amort.seguropagado);
                
             else
             
                update amortizaciones set seguropagado= fdepaplicar where amortizacionid=amort.amortizacionid;
                fdepaplicar:=  0;

             end if;

            end if;
            
          end loop;
          
      end if;
      
   end if;
   
   -- Insertando el numero de autorizacion
   update autorizabonificacion set movicajaid=imovicajaid,aplicado=1 where autorizacionid=iautorizacionid;
   
------------------------------------------

-- Impuesto Deposito en efectivo

   raise notice ' Voy a efectuar el ide credito %',pefectivo;
--linea que se corrije el dia lunes 23 de Enero del 2012 en la cta de IP 
-- linea Original if ptipomovimientoid in ((select tipomovimientoid from tipomovimiento where tipomovimientoid<>'CI' and tipomovimientoid<>'IP' and ptipomovimientoid<>'AH' and  tipomovimientoid<>'RE' and aplicasaldo='S') union (select (case when exists (select socioid from datosfiscales where socioid =psocioid) then '**' else '00' end) )) and  pefectivo=1 then
   if ptipomovimientoid in ((select tipomovimientoid from tipomovimiento where tipomovimientoid<>'CI' and ptipomovimientoid<>'AH' and  tipomovimientoid<>'RE' and aplicasaldo='S') union (select (case when exists (select socioid from datosfiscales where socioid =psocioid) then '**' else '00' end) )) and  pefectivo=1 then

     select fechapoliza into pfecha from polizas where polizaid=ppolizaid;
     select cuentacaja into scuentacaja from parametros where serie_user=pseriecaja;

     select sumadepositos into fsumaefectivo from sumadepositos(ptipomovimientoid,pfecha,psocioid);

      raise notice '1 cuenta retiro %  sumadepositos %  ide % ',scuentadeposito,fsumaefectivo,psaldo;
     
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

