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
		( case when pr.renovado=0 then t.cuentaactivo else t.cuentaactivoren end) as cuentaactivo,
		( case when pr.renovado=0 then t.cuentaactivovencida else t.cuentaactivovencidaren end) as cuentaactivovencida,
		( case when pr.renovado=0 then t.cuentaintdevnocobres else t.cuentaintdevnocobresren end) as cuentaintdevnocobres,
        ( case when pr.renovado=0 then t.cuentaintnormalnocob else t.cuentaintnormalnocobren end) as cuentaintnormalnocob,
	    ( case when pr.renovado=0 then t.cuentaordeninteres else t.cuentaordeninteresren end) as cuentaordeninteres,
	    ( case when pr.renovado=0 then t.ordeninteresacreedor else t.ordeninteresacreedorren end) as ordeninteresacreedor,
        ( case when pr.renovado=0 then t.cuentaintnormal else t.cuentaintnormalren end) as cuentaintnormal,
	    ( case when pr.renovado=0 then t.cuentaintmora else t.cuentaintmoraren end) as cuentaintmora,
	    ( case when pr.renovado=0 then t.cuentaintnormalresvencida else t.cuentaintnormalresvencidaren end) as cuentaintnormalresvencida,
        ( case when pr.renovado=0 then t.cuentaintnormalvencida else t.cuentaintnormalvencidaren end) as cuentaintnormalvencida,
	    ( case when pr.renovado=0 then t.cuentaintmoravencida else t.cuentaintmoravencidaren end) as cuentaintmoravencida,
	    ( case when pr.renovado=0 then t.cuentaintnormalresvigente else t.cuentaintnormalresvigenteren end) as cuentaintnormalresvigente,
       t.cuentariesgocred, --
	   t.cuentariesgocredres, -- 
       sum((case when p.fechacierre= pfechaactual then p.saldovencidomenoravencido else 0 end)) as A, 
       sum((case when p.fechacierre= pfechaactual then p.saldovencidomayoravencido else 0 end)) as B,
       sum((case when p.diasvencidos <= p.diastraspasoavencida then p.interesdevengadomenoravencido else 0 end)) as C,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.interesdevengadomenoravencido else 0 end)) as CC,
       sum((case when p.diasvencidos <= p.diastraspasoavencida then p.interesdevengadomayoravencido else 0 end)) as D,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.interesdevengadomayoravencido else 0 end)) as DD,       
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.pagointeresenperiodo else 0 end)) as interes,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.pagomoratorioenperiodo else 0 end)) as moratorio,
       sum((case when p.bonificacionintenperiodo > 0 and p.saldoprestamo > 0 then p.bonificacionintenperiodo else 0 end)) as interesbonificado,
       0 as reservacalculada,
	   pr.renovado
	   --sum((case when (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado > 0
                 --then (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado else 0 end)) as reservacalculada   
                 
  from precorte p, tipoprestamo t, prestamos pr
 where p.fechacierre = pfechaactual and p.tipoprestamoid <> 'CAS' and
       t.tipoprestamoid = p.tipoprestamoid and p.prestamoid=pr.prestamoid
group by p.tipoprestamoid,t.cuentaactivo,t.cuentaactivovencida,t.cuentaintdevnocobres,
       t.cuentaintnormalnocob,t.cuentaordeninteres,t.ordeninteresacreedor,
       t.cuentaintnormal,t.cuentaintmora,t.cuentaintnormalresvencida,
       t.cuentaintnormalvencida,t.cuentaintmoravencida,t.cuentaintnormalresvigente,t.cuentaactivoren,t.cuentaactivovencidaren,t.cuentaintdevnocobresren,
       t.cuentaintnormalnocobren,t.cuentaordeninteresren,t.ordeninteresacreedorren,
       t.cuentaintnormalren,t.cuentaintmoraren,t.cuentaintnormalresvencidaren,
       t.cuentaintnormalvencidaren,t.cuentaintmoravencidaren,t.cuentaintnormalresvigenteren,
       t.cuentariesgocred,t.cuentariesgocredres,pr.renovado--,p.factoraplicado 
  loop
	raise notice 'cuenta=%, tipoprestamoid = %',r.cuentaactivo,r.tipoprestamoid;
    for r1 in
  select t.tipoprestamoid,
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
                 
  from tipoprestamo t left join precorte p on (t.tipoprestamoid=p.tipoprestamoid and p.renovado=r.renovado)
 where t.tipoprestamoid=r.tipoprestamoid 
group by t.tipoprestamoid  

    loop
	  
      -- 1era Parte
      if bprimer then
        monto1 := r.b;
		--raise notice 'Estoy Caso1 monto1 % := r.b %  | tipoprestamoid= %',monto1,r.b,r.tipoprestamoid;
      else
        monto1 := r.b-r1.b1;
		--raise notice 'Estoy primera parte CASO2 monto1 % := r.b % - r1.b1 %   | tipoprestamoid= %',monto1,r.b,r1.b1,r.tipoprestamoid;
      end if;

      if monto1<>0 then
      if monto1>0 then
        scuentaid := r.cuentaactivovencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto1,0,' ',' ',
                             'Trasp. activo vig. a ven.'||r.tipoprestamoid);
        scuentaid := r.cuentaactivo;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto1,' ',' ',
                             'Disminuir la cartera vig.'||r.tipoprestamoid);
      else
        scuentaid := r.cuentaactivo;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto1),0,' ',
                             ' ','Trasp. activo vig. a ven.'||r.tipoprestamoid);
        scuentaid := r.cuentaactivovencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto1),' ',
                             ' ','Disminuir la cartera vig.'||r.tipoprestamoid);
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
		raise notice 'Estoy segunda parte monto21 % := r.cc % - r1.cc1 %   | tipoprestamoid= %',monto21,r.cc,r1.cc1,r.tipoprestamoid;
      end if;

      if monto2<>0 then
      if monto2>0 then
        scuentaid := r.cuentaintdevnocobres;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto2,0,' ',' ',
                             'Activo int. dev. no cob.'||r.tipoprestamoid);
        scuentaid := r.cuentaintnormalnocob;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto2,' ',' ',
                             'Ingreso int. dev. no cob.'||r.tipoprestamoid); 
      else
        scuentaid := r.cuentaintnormalnocob;        
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto2),0,' ',
               ' ','Activo int. dev. no cob.'||r.tipoprestamoid);
        scuentaid := r.cuentaintdevnocobres;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto2),' ',
               ' ','Ingreso int. dev. no cob.'||r.tipoprestamoid); 
      end if;
      end if;

      if monto21<>0 then
        if monto21>0 then
          scuentaid := r.cuentaintnormalvencida;
          select *
            into pmovipolizaid
           from spimovipoliza(ppolizaid,scuentaid,' ','C',monto21,0,' ',' ',
                             'Orden int. dev. venc.'||r.tipoprestamoid);
 	   scuentaid := r.CuentaIntNormalResVigente;
        
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto21,' ',' ',
                             'Orden int. dev. venc.'||r.tipoprestamoid);         
        else 

	  scuentaid := r.CuentaIntNormalResVigente;
          
          select *
            into pmovipolizaid
            from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto21),0,' ',
               ' ','Orden int. dev. venc.'||r.tipoprestamoid);
          --scuentaid := r.cuentaintdevnocobres;  Esta cuenta estaba mal
          scuentaid := r.cuentaintnormalvencida;
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

      if monto3<>0 then
        if monto3>0 then
          scuentaid := r.cuentaordeninteres;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto3,0,' ',' ',
                             'CuentaOrdenInteres'||r.tipoprestamoid);
          scuentaid := r.ordeninteresacreedor;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto3,' ',' ',
                             'OrdenInteresAcreedor'||r.tipoprestamoid); 
        else
          scuentaid := r.ordeninteresacreedor;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto3),0,' ',
               ' ','OrdenInteresAcreedor'||r.tipoprestamoid);
          scuentaid := r.cuentaordeninteres;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto3),' ',
               ' ','CuentaOrdenInteres'||r.tipoprestamoid); 
        end if;
      end if;
      
      monto4 := r.interes;
      monto5 := r.moratorio;

      if monto4>0 then
        scuentaid := r.cuentaintnormal;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto4,0,' ',' ',
                             'Reclasificacion int vigente'||r.tipoprestamoid);
      end if;
      if monto5>0 then
        scuentaid := r.cuentaintmora;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto5,0,' ',' ',
                             'Reclasificacion mora vig.'||r.tipoprestamoid);
      end if;
      
      if monto4>0 then
        scuentaid := r.cuentaintnormalresvencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto4,
               ' ',' ','Interes cartera vencida'||r.tipoprestamoid); 
      end if;
      if monto5>0 then
        scuentaid := r.cuentaintmoravencida;
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
          raise notice 'Reserva %|%|% ',r.cuentariesgocred,monto6,pfechaactual;
         
          scuentaid := r.cuentariesgocredres;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',monto6,0,' ',' ',
                             'Creacion de Reserva');
                             
          scuentaid := r.cuentariesgocred;
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
	   ( case when pr.renovado=0 then t.moravigentebalance else t.moravigentebalanceren end) as moravigentebalance,
	   ( case when pr.renovado=0 then t.moravencidobalance else t.moravencidobalanceren end) as moravencidobalance,
	   ( case when pr.renovado=0 then t.moravigenteresultado else t.moravigenteresultadoren end) as moravigenteresultado,
       ( case when pr.renovado=0 then t.moravencidoresultado else t.moravencidoresultadoren end) as moravencidoresultado,
	   ( case when pr.renovado=0 then t.moractaordendeudora else t.moractaordendeudoraren end) as moractaordendeudora,
	   ( case when pr.renovado=0 then t.moractaordenacredora else t.moractaordenacredoraren end) as moractaordenacredora,
       sum((case when p.diasvencidos <= p.diastraspasoavencida then p.interesdevmormenor else 0 end)) as MoratorioVigente,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.interesdevmormenor else 0 end)) as MoratorioVencido,
       sum((case when p.diasvencidos > p.diastraspasoavencida then p.interesdevmormayor else 0 end)) as MoratorioCtasOrden,
		pr.renovado
	   --sum((case when (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado > 0
                 --then (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado else 0 end)) as reservacalculada   
  from precorte p, tipoprestamo t, prestamos pr
  where p.fechacierre = pfechaactual and p.tipoprestamoid <> 'CAS' and t.tipoprestamoid = p.tipoprestamoid and p.prestamoid=pr.prestamoid
  group by p.tipoprestamoid,t.moravigentebalance,t.moravencidobalance,t.moravigenteresultado,
       t.moravencidoresultado,t.moractaordendeudora,t.moractaordenacredora,pr.renovado,t.moravigentebalanceren,t.moravencidobalanceren,t.moravigenteresultadoren,
       t.moravencidoresultadoren,t.moractaordendeudoraren,t.moractaordenacredoraren--,p.factoraplicado 
  loop
	  --Cierre Anterior
	  for r1 in
		  select t.tipoprestamoid,
		   sum((case when p.fechacierre=pfechaanterior and p.diasvencidos <= p.diastraspasoavencida then p.interesdevmormenor else 0 end)) as MoratorioVigenteAnt,
		   sum((case when p.fechacierre=pfechaanterior and p.diasvencidos > p.diastraspasoavencida then p.interesdevmormenor else 0 end)) as MoratorioVencidoAnt,
		   sum((case when p.fechacierre=pfechaanterior and p.diasvencidos > p.diastraspasoavencida then p.interesdevmormayor else 0 end)) as MoratorioCtasOrdenAnt       
		   --sum((case when (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado > 0
					 --then (p.reservacalculada+p.reservaidnc+p.reservagarantia)*p.factoraplicado else 0 end)) as reservacalculada   
	  from tipoprestamo t left join precorte p on (t.tipoprestamoid=p.tipoprestamoid and p.renovado=r.renovado)
	  where p.tipoprestamoid <> 'CAS' and t.tipoprestamoid = r.tipoprestamoid 
	  group by t.tipoprestamoid 
	    loop
			raise notice 'r.tipoprestamoid % r1.tipoprestamoid %',r.tipoprestamoid,r1.tipoprestamoid ;
			monto:=r.MoratorioVigente-r1.MoratorioVigenteAnt;
			raise notice 'monto  % :=r.MoratorioVigente  % -r1.MoratorioVigenteAnt  %',monto,r.MoratorioVigente,r1.MoratorioVigenteAnt;
			if monto<>0 then
				if monto>0 then
					scuentaid := r.moravigentebalance;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',monto,0,' ',' ','+ Mora Vigente Balance '||r.tipoprestamoid);
					scuentaid := r.moravigenteresultado;  
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto,' ',' ','+ Mora Vigente Resultados '||r.tipoprestamoid);
				else
					scuentaid := r.moravigenteresultado;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto),0,' ',' ','- Mora Vigente Resultados '||r.tipoprestamoid);
					scuentaid := r.moravigentebalance;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto),' ',' ','- Mora Vigente Balance'||r.tipoprestamoid);
				end if;
				
			end if;
			
			monto:=r.MoratorioVencido-r1.MoratorioVencidoAnt;
			raise notice 'monto  % :=r.MoratorioVencido  % -r1.MoratorioVencidoAnt  %',monto,r.MoratorioVencido,r1.MoratorioVencidoAnt;
			if monto<>0 then
				if monto>0 then
					scuentaid := r.moravencidobalance;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',monto,0,' ',' ','+ Mora Vencido Balance '||r.tipoprestamoid);
					scuentaid := r.moravencidoresultado;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto,' ',' ','+ Mora Vencido Resultados '||r.tipoprestamoid); 
				else
					scuentaid := r.moravencidoresultado;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto),0,' ',' ','- Mora Vencido Balance '||r.tipoprestamoid);
					scuentaid := r.moravencidobalance;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto),' ',' ','- Mora Vencido Resultados '||r.tipoprestamoid); 
				end if;
			end if;
			
			monto:=r.MoratorioCtasOrden-r1.MoratorioCtasOrdenAnt;
			raise notice 'monto  % :=r.MoratorioCtasOrden  % -r1.MoratorioCtasOrdenAnt  %',monto,r.MoratorioCtasOrden,r1.MoratorioCtasOrdenAnt;
			if monto<>0 then
				if monto>0 then
					scuentaid := r.moractaordendeudora;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',monto,0,' ',' ','+ Mora Orden Deudora '||r.tipoprestamoid);
					scuentaid := r.moractaordenacredora;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,monto,' ',' ','+ Mora Orden Acreedora '||r.tipoprestamoid); 
				else
					scuentaid := r.moractaordenacredora;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(monto),0,' ',' ','- Mora Orden Deudora '||r.tipoprestamoid);
					scuentaid := r.moractaordendeudora;
					select * into pmovipolizaid from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(monto),' ',' ','- Mora Orden Acreedora '||r.tipoprestamoid); 
				end if;
			end if;
		end loop;
	
  end loop;

return 1;
end
$_$
    LANGUAGE plpgsql 
