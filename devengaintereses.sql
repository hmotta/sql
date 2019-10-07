--update empresa set fechainiciareservas='2012-07-31';

CREATE or replace FUNCTION devengaintereses(date, date) RETURNS integer
    AS $_$
declare
  pfechaactual alias for $1;
  pfechaanterior alias for $2;

  r record;
  r1 record;

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  scuentaid char(24);
  monto numeric;
  monto1 numeric;
  monto2 numeric;
  monto21 numeric;
  monto3 numeric;
  monto4 numeric;
  monto5 numeric;

  sserie_user char(2);

  bprimer bool;
  diniciadevengamiento date;

  dfechainiciareservas date;
  monto6 numeric;
  reservacreada numeric;
  pejercicioant integer;
  pperiodoant integer;

  pejercicioact integer;
  pperiodoact integer;

  freservacreada numeric;
  freservacalculada numeric;
  factorreserva numeric;
  
begin

  pejercicioant:=cast(extract(year from pfechaanterior) as integer);
  pperiodoant:=cast(extract(month from pfechaanterior) as integer);

  pejercicioact:=cast(extract(year from pfechaactual) as integer);
  pperiodoact:=cast(extract(month from pfechaactual) as integer);

-- 
-- Borrar poliza del mismo dia, serie y tipo=V
--

  sserie_user := 'ZA';

  delete from movipolizas where polizaid in (select polizaid from polizas where seriepoliza=sserie_user and tipo='V' and fechapoliza=pfechaactual);

  delete from logpoliza where polizaid in (select polizaid from polizas where seriepoliza=sserie_user and tipo='V' and fechapoliza=pfechaactual);
  
  delete from polizas where seriepoliza=sserie_user and tipo='V' and fechapoliza=pfechaactual;

   
  select abs(coalesce(sum(saldo_inic_ejer),0)+coalesce(sum(cargos_acum_ejer),0)-coalesce(sum(abonos_acum_ejer),0)) into freservacreada  from balanza('1303','1304',pejercicioact,pperiodoact) where cuentaid='1303' group by cuentaid;

  --select sum((reservacalculada+reservaidnc+reservagarantia)*factoraplicado) into freservacalculada from precorte where fechacierre=pfechaactual;

  --freservacalculada:=round(freservacalculada,2);
      
  select iniciadevengamiento--,fechainiciareservas
    into diniciadevengamiento--,dfechainiciareservas
    from empresa;
 
  if pfechaanterior=diniciadevengamiento then
    bprimer:=true;
  else
    bprimer:=false;
  end if;
  
--
-- Dar de alta la poliza contable
--

  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfechaactual) as int),cast(date_part('month',pfechaactual) as int),'V',sserie_user,'D');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,sserie_user,'V',pnumero_poliza,cast(date_part('year',pfechaactual) as int),cast(date_part('month',pfechaactual) as int),' ',pfechaactual,'D',' ',' ','Devenga Intereses',pfechaactual);

  for r in
  select p.tipoprestamoid,
		ct.cta_cap_vig,
		ct.cta_cap_ven,
		ct.cta_int_vig_balance,
        ct.cta_int_vig_dev_nocob_resultados,
	    ct.cta_int_ven_orden_deudora,
	    ct.cta_int_ven_orden_acreedora,
        ct.cta_int_vig_resultados,
	    ct.cta_mora_vig_resultados,
	    ct.cta_int_ven_resultados,
        ct.cta_int_ven_balance,
	    ct.cta_mora_ven_resultados,
	    ct.cta_int_ven_dev_nocob_resultados,
        ct.cta_estimacion, 
	    ct.cta_estimacion_resultados, 
		ct.clavefinalidad,
		ct.renovado,
       sum((case when p.fechacierre= pfechaactual then p.saldovencidomenoravencido else 0 end)) as A, 
       sum((case when p.fechacierre= pfechaactual then p.saldovencidomayoravencido else 0 end)) as B,
       sum((case when p.diasvencidos <= p.diastraspasoavencida then p.interesdevengadomenoravencido else 0 end)) as C,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.interesdevengadomenoravencido else 0 end)) as CC,
       sum((case when p.diasvencidos <= p.diastraspasoavencida then p.interesdevengadomayoravencido else 0 end)) as D,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.interesdevengadomayoravencido else 0 end)) as DD,       
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.pagointeresenperiodo else 0 end)) as interes,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.pagomoratorioenperiodo else 0 end)) as moratorio,
       sum((case when p.bonificacionintenperiodo > 0 and p.saldoprestamo > 0 then p.bonificacionintenperiodo else 0 end)) as interesbonificado,
       0 as reservacalculada
	   --sum((case when (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado > 0
                 --then (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado else 0 end)) as reservacalculada   
                 
  from precorte p
			inner join prestamos pr on (p.prestamoid=pr.prestamoid)
			inner join cat_cuentas_tipoprestamo ct on (ct.cat_cuentasid = pr.cat_cuentasid)
 where p.fechacierre = pfechaactual and p.tipoprestamoid <> 'CAS'
group by p.tipoprestamoid,ct.cta_cap_vig,ct.cta_cap_ven,ct.cta_int_vig_balance,
       ct.cta_int_vig_dev_nocob_resultados,ct.cta_int_ven_orden_deudora,ct.cta_int_ven_orden_acreedora,
       ct.cta_int_vig_resultados,ct.cta_mora_vig_resultados,ct.cta_int_ven_resultados,
       ct.cta_int_ven_balance,ct.cta_mora_ven_resultados,ct.cta_int_ven_dev_nocob_resultados,
       ct.cta_estimacion,ct.cta_estimacion_resultados,ct.clavefinalidad,ct.renovado--,p.factoraplicado 
  loop
	raise notice 'cuenta=%, tipoprestamoid = %',r.cta_cap_vig,r.tipoprestamoid;
    for r1 in
	  select ct.tipoprestamoid,
	   ct.clavefinalidad,
	   ct.renovado,
       sum((case when p.fechacierre=pfechaanterior then p.saldovencidomenoravencido else 0 end)) as A1, 
       sum((case when p.fechacierre=pfechaanterior then p.saldovencidomayoravencido else 0 end)) as B1,     
       sum((case when p.diasvencidos <= p.diastraspasoavencida and p.fechacierre=pfechaanterior then p.saldoprestamo else 0 end)) as A1, 
       sum((case when p.diasvencidos > p.diastraspasoavencida and p.fechacierre=pfechaanterior then p.saldoprestamo else 0 end)) as B1, 
       sum((case when p.diasvencidos <= p.diastraspasoavencida and p.fechacierre=pfechaanterior then p.interesdevengadomenoravencido else 0 end)) as C1,
       sum((case when p.diasvencidos > p.diastraspasoavencida and p.fechacierre=pfechaanterior then p.interesdevengadomenoravencido else 0 end)) as CC1,
       sum((case when p.diasvencidos <= p.diastraspasoavencida and p.fechacierre=pfechaanterior then p.interesdevengadomayoravencido else 0 end)) as D1,
       sum((case when p.diasvencidos > p.diastraspasoavencida and p.fechacierre=pfechaanterior then p.interesdevengadomayoravencido else 0 end)) as DD1,       
       sum((case when p.diasvencidos > p.diastraspasoavencida and p.fechacierre=pfechaanterior then p.pagointeresenperiodo else 0 end)) as interes1,
       sum((case when p.diasvencidos > p.diastraspasoavencida and p.fechacierre=pfechaanterior then p.pagomoratorioenperiodo else 0 end)) as moratorio1,
       sum((case when p.bonificacionintenperiodo > 0  and p.saldoprestamo > 0 and p.fechacierre=pfechaanterior then p.bonificacionintenperiodo else 0 end)) as interesbonificado1,
		0 as reservacalculada1		 
       --sum((case when (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado > 0
         --        then (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado else 0 end)) as reservacalculada1
	  from cat_cuentas_tipoprestamo ct left join precorte p on (ct.tipoprestamoid=p.tipoprestamoid and ct.clavefinalidad=p.clavefinalidad and ct.renovado=p.renovado )
	  where ct.tipoprestamoid=r.tipoprestamoid and ct.clavefinalidad=r.clavefinalidad and ct.renovado=r.renovado
	  group by ct.tipoprestamoid,ct.clavefinalidad,ct.renovado  

    loop
	  --raise notice 'r.tipoprestamoid % r.clavefinalidad % r.renovado % ||| r1.tipoprestamoid % r1.clavefinalidad %  r1.renovado %',r.tipoprestamoid,r.clavefinalidad,r.renovado,r1.tipoprestamoid,r1.clavefinalidad,r1.renovado ;
	  raise notice '% % %',r.tipoprestamoid,r.clavefinalidad,r.renovado;
      -- 1era Parte
      if bprimer then
        monto1 := r.b;
		--raise notice 'Estoy Caso1 monto1 % := r.b %  | tipoprestamoid= %',monto1,r.b,r.tipoprestamoid;
      else
        monto1 := r.b-r1.b1;
		--raise notice 'Estoy primera parte CASO2 monto1 % := r.b % - r1.b1 %   | tipoprestamoid= %',monto1,r.b,r1.b1,r.tipoprestamoid;
      end if;
	  
	  raise notice 'monto  % := r.b % - r1.b1 %',monto1,r.b,r1.b1;
	  
      if monto1<>0 then
		  if monto1>0 then
			scuentaid := r.cta_cap_ven;
			select *
			  into pmovipolizaid
			  from spimovipoliza(ppolizaid,scuentaid,' ','C',monto1,0,' ',' ',
								 'Trasp. activo vig. a ven. '||r.tipoprestamoid);
			scuentaid := r.cta_cap_vig;
			select *
			  into pmovipolizaid
			  from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto1,' ',' ',
								 'Disminuir la cartera vig. '||r.tipoprestamoid);
		  else
			scuentaid := r.cta_cap_vig;
			select *
			  into pmovipolizaid
			  from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto1),0,' ',
								 ' ','Trasp. activo vig. a ven. '||r.tipoprestamoid);
			scuentaid := r.cta_cap_ven;
			select *
			  into pmovipolizaid
			  from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto1),' ',
								 ' ','Disminuir la cartera vig. '||r.tipoprestamoid);
		  end if;
      end if;

      -- 2da Parte
      if bprimer then
        monto2 := r.c;
        monto21 := r.cc;
      else
        monto2 := r.c-r1.c1;
        monto21 := r.cc-r1.cc1;
		--raise notice 'Estoy segunda parte monto2 % := r.c % - r1.c1 %   | tipoprestamoid= %',monto2,r.c,r1.c1,r.tipoprestamoid;
		--raise notice 'Estoy segunda parte monto21 % := r.cc % - r1.cc1 %   | tipoprestamoid= %',monto21,r.cc,r1.cc1,r.tipoprestamoid;
      end if;

	  raise notice 'monto2  % :=  r.c % -  r1.c1 %',monto1,r.c,r1.c1;
	  raise notice 'monto21  % :=  r.cc % -  r1.cc1 %',monto1,r.cc,r1.cc1;
	  
      if monto2<>0 then
		  if monto2>0 then
			scuentaid := r.cta_int_vig_balance;
			select *
			  into pmovipolizaid
			  from spimovipoliza(ppolizaid,scuentaid,' ','C',monto2,0,' ',' ',
								 'Activo int. dev. no cob. '||r.tipoprestamoid);
			scuentaid := r.cta_int_vig_dev_nocob_resultados;
			select *
			  into pmovipolizaid
			  from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto2,' ',' ',
								 'Ingreso int. dev. no cob. '||r.tipoprestamoid); 
		  else
			scuentaid := r.cta_int_vig_dev_nocob_resultados;        
			select *
			  into pmovipolizaid
			  from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto2),0,' ',
				   ' ','Activo int. dev. no cob. '||r.tipoprestamoid);
			scuentaid := r.cta_int_vig_balance;
			select *
			  into pmovipolizaid
			  from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto2),' ',
				   ' ','Ingreso int. dev. no cob. '||r.tipoprestamoid); 
		  end if;
      end if;

      if monto21<>0 then
        if monto21>0 then
          scuentaid := r.cta_int_ven_balance;
          select *
            into pmovipolizaid
           from spimovipoliza(ppolizaid,scuentaid,' ','C',monto21,0,' ',' ',
                             'Orden int. dev. venc.'||r.tipoprestamoid);
 	   scuentaid := r.cta_int_ven_dev_nocob_resultados;
        
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto21,' ',' ',
                             'Orden int. dev. venc.'||r.tipoprestamoid);         
        else 

	  scuentaid := r.cta_int_ven_dev_nocob_resultados;
          
          select *
            into pmovipolizaid
            from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto21),0,' ',
               ' ','Orden int. dev. venc.'||r.tipoprestamoid);
          --scuentaid := r.cta_int_vig_balance;  Esta cuenta estaba mal
          scuentaid := r.cta_int_ven_balance;
          select *
            into pmovipolizaid
            from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto21),' ',
               ' ','Orden int. dev. venc.'||r.tipoprestamoid); 
        end if;

      end if;

      -- 3era Parte

      if bprimer then
        monto3 := r.d + r.dd;
      else
        monto3 := r.d + r.dd - r1.d1 - r1.dd1;
      end if;

	  raise notice 'monto3  % :=  r.d % + r.dd % - r1.d1 % - r1.dd1 %',monto3,r.d,r.dd,r1.d1,r1.dd1;
      if monto3<>0 then
        if monto3>0 then
          scuentaid := r.cta_int_ven_orden_deudora;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto3,0,' ',' ',
                             'CuentaOrdenInteres'||r.tipoprestamoid);
          scuentaid := r.cta_int_ven_orden_acreedora;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto3,' ',' ',
                             'OrdenInteresAcreedor'||r.tipoprestamoid); 
        else
          scuentaid := r.cta_int_ven_orden_acreedora;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto3),0,' ',
               ' ','OrdenInteresAcreedor'||r.tipoprestamoid);
          scuentaid := r.cta_int_ven_orden_deudora;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto3),' ',
               ' ','CuentaOrdenInteres'||r.tipoprestamoid); 
        end if;
      end if;
      
      monto4 := r.interes;
      monto5 := r.moratorio;

      if monto4>0 then
        scuentaid := r.cta_int_vig_resultados;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto4,0,' ',' ',
                             'Reclasificacion int vigente'||r.tipoprestamoid);
      end if;
      if monto5>0 then
        scuentaid := r.cta_mora_vig_resultados;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto5,0,' ',' ',
                             'Reclasificacion mora vig.'||r.tipoprestamoid);
      end if;
      
      if monto4>0 then
        scuentaid := r.cta_int_ven_resultados;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto4,
               ' ',' ','Interes cartera vencida'||r.tipoprestamoid); 
      end if;
      if monto5>0 then
        scuentaid := r.cta_mora_ven_resultados;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto5,
               ' ',' ','Int mora cartera vencida'||r.tipoprestamoid); 
      end if;

      -- Contabilizando la reserva calculada.
      -- Validar que no existan polizas
      /*
      
      if pfechaactual >  dfechainiciareservas then
      
        if pfechaactual = dfechainiciareservas then      
          monto6:=round(r.reservacalculada,2);
          freservacreada:=0;
        else
        
          if pfechaactual > dfechainiciareservas then    
            monto6:=round(r.reservacalculada,2);
          else
            monto6:=0;     
          end if;
        
        end if;

        raise notice 'Reservas =  %|%',freservacalculada,freservacreada;

        if freservacreada < freservacalculada then
      
          factorreserva:=(freservacalculada-freservacreada)/freservacalculada;
         
          monto6:=round(monto6*factorreserva,2);         
          raise notice 'Reserva %|%|% ',r.cta_estimacion,monto6,pfechaactual;
         
          scuentaid := r.cta_estimacion_resultados;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto6,0,' ',' ',
                             'Creacion de Reserva');
                             
          scuentaid := r.cta_estimacion;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto6,' ',' ',
                             'Creacion de Reserva');
        end if;
      end if;
      */
      
    end loop;
  end loop;
  
  
  --Devenga interes moratorio
	--
-- Dar de alta la poliza contable
--

  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfechaactual) as int),cast(date_part('month',pfechaactual) as int),'V',sserie_user,'D');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,sserie_user,'V',pnumero_poliza,cast(date_part('year',pfechaactual) as int),cast(date_part('month',pfechaactual) as int),' ',pfechaactual,'D',' ',' ','Devenga Intereses Moratorios',pfechaactual);

  --Cierre Actual
  for r in
	  select p.tipoprestamoid,
	   ct.cta_mora_vig_balance,
	   ct.cta_mora_ven_balance,
	   ct.cta_mora_vig_dev_nocob_resultados,
       ct.cta_mora_ven_dev_nocob_resultados,
	   ct.cta_mora_ven_orden_deudora,
	   ct.cta_mora_ven_orden_acreedora,
	   ct.clavefinalidad,
	   ct.renovado,
       sum((case when p.diasvencidos <= p.diastraspasoavencida then p.interesdevmormenor else 0 end)) as MoratorioVigente,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.interesdevmormenor else 0 end)) as MoratorioVencido,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.interesdevmormayor else 0 end)) as MoratorioCtasOrden
	   --sum((case when (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado > 0
                 --then (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado else 0 end)) as reservacalculada   
	  from precorte p 
				inner join prestamos pr on (p.prestamoid=pr.prestamoid)
				inner join cat_cuentas_tipoprestamo ct on (ct.cat_cuentasid = pr.cat_cuentasid)
	  where p.fechacierre = pfechaactual and p.tipoprestamoid <> 'CAS' 
	  group by p.tipoprestamoid,ct.cta_mora_vig_balance,ct.cta_mora_ven_balance,ct.cta_mora_vig_dev_nocob_resultados,
       ct.cta_mora_ven_dev_nocob_resultados,ct.cta_mora_ven_orden_deudora,ct.cta_mora_ven_orden_acreedora,ct.clavefinalidad,ct.renovado--,p.factoraplicado 
  loop
	  --Cierre Anterior
	  for r1 in
		  select ct.tipoprestamoid,ct.clavefinalidad,ct.renovado,
		   sum((case when p.fechacierre=pfechaanterior and p.diasvencidos <= p.diastraspasoavencida then p.interesdevmormenor else 0 end)) as MoratorioVigenteAnt,
		   sum((case when p.fechacierre=pfechaanterior and p.diasvencidos > p.diastraspasoavencida then p.interesdevmormenor else 0 end)) as MoratorioVencidoAnt,
		   sum((case when p.fechacierre=pfechaanterior and p.diasvencidos > p.diastraspasoavencida then p.interesdevmormayor else 0 end)) as MoratorioCtasOrdenAnt       
		   --sum((case when (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado > 0
					 --then (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado else 0 end)) as reservacalculada   
	  from cat_cuentas_tipoprestamo ct left join precorte p on (ct.tipoprestamoid=p.tipoprestamoid and ct.clavefinalidad=p.clavefinalidad and ct.renovado=p.renovado)
	  where p.tipoprestamoid <> 'CAS' and ct.tipoprestamoid = r.tipoprestamoid and ct.clavefinalidad=r.clavefinalidad and ct.renovado=r.renovado
	  group by ct.tipoprestamoid,ct.clavefinalidad,ct.renovado
	    loop
			raise notice '% % %',r.tipoprestamoid,r.clavefinalidad,r.renovado ;
			monto:=r.MoratorioVigente-r1.MoratorioVigenteAnt;
			raise notice 'monto  % :=r.MoratorioVigente  % -r1.MoratorioVigenteAnt  %',monto,r.MoratorioVigente,r1.MoratorioVigenteAnt;
			if monto<>0 then
				if monto>0 then
					scuentaid := r.cta_mora_vig_balance;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',monto,0,' ',' ','+ Mora Vigente Balance '||r.tipoprestamoid);
					scuentaid := r.cta_mora_vig_dev_nocob_resultados;  
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto,' ',' ','+ Mora Vigente Resultados '||r.tipoprestamoid);
				else
					scuentaid := r.cta_mora_vig_dev_nocob_resultados;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto),0,' ',' ','- Mora Vigente Resultados '||r.tipoprestamoid);
					scuentaid := r.cta_mora_vig_balance;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto),' ',' ','- Mora Vigente Balance'||r.tipoprestamoid);
				end if;
				
			end if;
			
			monto:=r.MoratorioVencido-r1.MoratorioVencidoAnt;
			raise notice 'monto  % :=r.MoratorioVencido  % -r1.MoratorioVencidoAnt  %',monto,r.MoratorioVencido,r1.MoratorioVencidoAnt;
			if monto<>0 then
				if monto>0 then
					scuentaid := r.cta_mora_ven_balance;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',monto,0,' ',' ','+ Mora Vencido Balance '||r.tipoprestamoid);
					scuentaid := r.cta_mora_ven_dev_nocob_resultados;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto,' ',' ','+ Mora Vencido Resultados '||r.tipoprestamoid); 
				else
					scuentaid := r.cta_mora_ven_dev_nocob_resultados;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto),0,' ',' ','- Mora Vencido Balance '||r.tipoprestamoid);
					scuentaid := r.cta_mora_ven_balance;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto),' ',' ','- Mora Vencido Resultados '||r.tipoprestamoid); 
				end if;
			end if;
			
			monto:=r.MoratorioCtasOrden-r1.MoratorioCtasOrdenAnt;
			raise notice 'monto  % :=r.MoratorioCtasOrden  % -r1.MoratorioCtasOrdenAnt  %',monto,r.MoratorioCtasOrden,r1.MoratorioCtasOrdenAnt;
			if monto<>0 then
				if monto>0 then
					scuentaid := r.cta_mora_ven_orden_deudora;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',monto,0,' ',' ','+ Mora Orden Deudora '||r.tipoprestamoid);
					scuentaid := r.cta_mora_ven_orden_acreedora;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto,' ',' ','+ Mora Orden Acreedora '||r.tipoprestamoid); 
				else
					scuentaid := r.cta_mora_ven_orden_acreedora;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto),0,' ',' ','- Mora Orden Deudora '||r.tipoprestamoid);
					scuentaid := r.cta_mora_ven_orden_deudora;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto),' ',' ','- Mora Orden Acreedora '||r.tipoprestamoid); 
				end if;
			end if;
		end loop;
	
  end loop;

return 1;
end
$_$
    LANGUAGE plpgsql;
