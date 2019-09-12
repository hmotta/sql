CREATE or replace FUNCTION  castigoprestamo(integer,character,numeric,date) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  pusuarioid alias for $2;
  psaldoprestamo alias for $3;
  pfechapago alias for $4;
  

  r record;
  f record;
    
  fcapital numeric;
  pfecha date;
  pnumero_poliza int4;
  preferencia int4;
  pserie_user char(2);
  sreferenciaprestamo char(18);
  scuentaactivo char(24);
  scuentariesgocred char(24);
  scuentaactivovencida char(24);
  
  stipoprestamoid char(3);
  ispiprestamoscas integer;

  ppolizaid int4;
  pmovipolizaid int4;
  pmovipolizaid2 int4;
  lreferenciacaja integer;
  pmovicajaid int4;
  lsocioid integer;
  dfechaultimopago date;
  pmontoprestamo numeric;
  pcapitalpagado numeric;
  sreferenciaprestamocas  char(18); 

  veint integer;
  veamo integer;
  swamo integer;
  igeneraramortizaciones integer;
  
begin

  pfecha:=current_date;

  select referenciaprestamo,tipoprestamoid,socioid,fechaultimopago,montoprestamo into sreferenciaprestamo,stipoprestamoid,lsocioid,dfechaultimopago,pmontoprestamo from prestamos where prestamoid=pprestamoid;

  
  -- Se cambia esta linea para utilizar el saldo que viene como parametro
  --pcapitalpagado:=pmontoprestamo-fcapital;

  swamo:=0;
  
  if psaldoprestamo > pmontoprestamo then
    pmontoprestamo:=psaldoprestamo;
    pcapitalpagado:=0;
    swamo:=1;
  else
    pcapitalpagado:=pmontoprestamo-psaldoprestamo;
  end if;

  dfechaultimopago:=pfechapago;
  
  
  select cuentaactivo,cuentariesgocred into scuentaactivo,scuentariesgocred from tipoprestamo where tipoprestamoid = stipoprestamoid;
  select serie_user into pserie_user from parametros where usuarioid=pusuarioid;   

 
  -- Crear el préstamo con tipo CAS Castigado
  
    for r in select * from prestamos where prestamoid=pprestamoid
    loop

       sreferenciaprestamocas:=r.referenciaprestamo||'CAS-';
       select spiprestamoscas into ispiprestamoscas from spiprestamoscas(r.referenciaprestamo||'CAS-',pmontoprestamo,
                        psaldoprestamo,
                        r.numero_de_amor,
                        r.fecha_otorga,
                        r.fecha_vencimiento,
                        'CAS',
                        r.tasanormal,
                        r.tasa_moratoria,
                        lsocioid,
                        r.dias_de_cobro,
                        r.meses_de_cobro,
                        r.dia_mes_cobro,
                        r.fecha_1er_pago,
                        r.clavegarantia,
                        r.monto_garantia,
                        '001',
                        r.usuarioid,
                        r.clavefinalidad,
                        r.calculonormalid,
                        r.calculomoratorioid,
                        0,
                        r.solicitudprestamoid,
                        r.norenovaciones,
                        r.formalizado,
                        r.condicionid,
                        r.clasificacioncreditoid,
                        0,
                        r.tipoacreditadoid,
                        '',
                        '',
                        0,
                        0,
                        r.ahorrocompromiso,
                        0);

       end loop;

       if swamo=0 then 
          for f in select * from amortizaciones  where prestamoid=pprestamoid

          loop

            insert into amortizaciones(prestamoid,claveestadocredito,numamortizacion, fechadepago,importeamortizacion,interesnormal,saldo_absoluto,interespagado, abonopagado ,ultimoabono,iva,totalpago,ahorro,ahorropagado,seguropagado,cobranza,cobranzapagado,moratoriopagado) values (ispiprestamoscas,f.claveestadocredito,f.numamortizacion,f. fechadepago,f.importeamortizacion,f.interesnormal,f.saldo_absoluto,f.interespagado,f. abonopagado ,f.ultimoabono,f.iva,f.totalpago,f.ahorro,f.ahorropagado,f.seguropagado,f.cobranza,f.cobranzapagado,f.moratoriopagado);

          end loop;
       else
           select generaramortizaciones into igeneraramortizaciones from  generaramortizaciones(sreferenciaprestamocas,pcapitalpagado,dfechaultimopago);
       end if;
       
  --Crear la poliza del nuevo credito

--
-- Dar de alta la poliza contable
--

select cuentaactivo,cuentaactivovencida into scuentaactivo,scuentaactivovencida from tipoprestamo where tipoprestamoid = 'CAS';

  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie_user,'A');
  
-- Encabezado de la poliza

 select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','CASTIGO DE PRESTAMO:'||sreferenciaprestamo,dfechaultimopago);
-- Detalle de la poliza

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,scuentaactivo,' ','C',pmontoprestamo,0,' ',' ','CARTERA CASTIGADA');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,pcapitalpagado,' ',' ','CARTERA CASTIGADA');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentaactivovencida,' ','A',0,pmontoprestamo-pcapitalpagado,' ',' ','CARTERA CASTIGADA');
    
   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = pserie_user;

  lreferenciacaja := lreferenciacaja+1;   

    select *
     into pmovicajaid
     from spimovicajaseguro(lsocioid,'00',ppolizaid,lreferenciacaja,pserie_user,pmovipolizaid,ispiprestamoscas,'A',NULL);
              
   --Validar amortizaciones pagadas.
   
   select * into veint from verificainterespagado(sreferenciaprestamocas,sreferenciaprestamo);
   select * into veamo from verificaamortizacionpagada(sreferenciaprestamocas);   
     
return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;





    


