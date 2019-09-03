CREATE OR REPLACE FUNCTION devengaintereses(date, date) RETURNS integer
    AS $_$
declare
  pfecha1 alias for $1;
  pfecha2 alias for $2;

  r record;
  r1 record;

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  scuentaid char(24);
  debehaber1 numeric;
  debehaber2 numeric;
  debehaber21 numeric;
  debehaber3 numeric;
  debehaber4 numeric;
  debehaber5 numeric;

  sserie_user char(2);

  bprimer bool;
  diniciadevengamiento date;

begin

  select iniciadevengamiento
    into diniciadevengamiento
    from empresa;

  if pfecha2=diniciadevengamiento then
    bprimer:=true;
  else
    bprimer:=false;
  end if;
  
  sserie_user := 'ZA';

-- 
-- Borrar poliza del mismo día, serie y tipo=V
--

  delete from logpoliza where polizaid in (select polizaid from polizas where seriepoliza=sserie_user and tipo='V' and fechapoliza=pfecha1);

  delete from movipolizas where polizaid in (select polizaid from polizas where seriepoliza=sserie_user and tipo='V' and fechapoliza=pfecha1);

  delete from polizas where seriepoliza=sserie_user and tipo='V' and fechapoliza=pfecha1;

--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha1) as int),cast(date_part('month',pfecha1) as int),'V',sserie_user,'D');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,sserie_user,'V',pnumero_poliza,cast(date_part('year',pfecha1) as int),cast(date_part('month',pfecha1) as int),' ',pfecha1,'D',' ',' ','Devenga Intereses',pfecha1);

  for r in

select p.tipoprestamoid,t.cuentaactivo,t.cuentaactivovencida,t.cuentaintdevnocobres,
       t.cuentaintnormalnocob,t.cuentaordeninteres,t.ordeninteresacreedor,
       t.cuentaintnormal,t.cuentaintmora,t.cuentaintnormalresvencida,
       t.cuentaintnormalvencida,t.cuentaintmoravencida,t.cuentaintnormalresvigente,
       sum((case when p.diasvencidos <= t.diastraspasoavencida
                 then p.saldoprestamo else 0 end)) as A, 
       sum((case when p.diasvencidos > t.diastraspasoavencida
                 then p.saldoprestamo else 0 end)) as B, 
       sum((case when p.diasvencidos <= t.diastraspasoavencida
                 then p.interesdevengadomenoravencido+p.interesdevmormenor else 0 end)) as C,
       sum((case when p.diasvencidos > t.diastraspasoavencida
                 then p.interesdevengadomenoravencido+p.interesdevmormenor else 0 end)) as CC,
       sum((case when p.diasvencidos <= t.diastraspasoavencida
                 then p.interesdevengadomayoravencido+p.interesdevmormayor else 0 end)) as D,
       sum((case when p.diasvencidos > t.diastraspasoavencida
                 then p.interesdevengadomayoravencido+p.interesdevmormayor else 0 end)) as DD,       
       sum((case when p.diasvencidos > t.diastraspasoavencida
                 then p.pagointeresenperiodo else 0 end)) as interes,
       sum((case when p.diasvencidos > t.diastraspasoavencida
                 then p.pagomoratorioenperiodo else 0 end)) as moratorio
  from precorte p, tipoprestamo t
 where p.fechacierre = pfecha1 and p.tipoprestamoid <> 'CAS' and
       t.tipoprestamoid = p.tipoprestamoid 
group by p.tipoprestamoid,t.cuentaactivo,t.cuentaactivovencida,t.cuentaintdevnocobres,
       t.cuentaintnormalnocob,t.cuentaordeninteres,t.ordeninteresacreedor,
       t.cuentaintnormal,t.cuentaintmora,t.cuentaintnormalresvencida,
       t.cuentaintnormalvencida,t.cuentaintmoravencida,t.cuentaintnormalresvigente
  loop

    for r1 in
  select t.tipoprestamoid,
       sum((case when p.diasvencidos <= t.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.saldoprestamo else 0 end)) as A1, 
       sum((case when p.diasvencidos > t.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.saldoprestamo else 0 end)) as B1, 
       sum((case when p.diasvencidos <= t.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.interesdevengadomenoravencido+p.interesdevmormenor else 0 end)) as C1,
       sum((case when p.diasvencidos > t.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.interesdevengadomenoravencido+p.interesdevmormenor else 0 end)) as CC1,
       sum((case when p.diasvencidos <= t.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.interesdevengadomayoravencido+p.interesdevmormayor else 0 end)) as D1,
       sum((case when p.diasvencidos > t.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.interesdevengadomayoravencido+p.interesdevmormayor else 0 end)) as DD1,       
       sum((case when p.diasvencidos > t.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.pagointeresenperiodo else 0 end)) as interes1,
       sum((case when p.diasvencidos > t.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.pagomoratorioenperiodo else 0 end)) as moratorio1
  from tipoprestamo t left join precorte p on t.tipoprestamoid=p.tipoprestamoid
 where t.tipoprestamoid=r.tipoprestamoid
group by t.tipoprestamoid  

    loop

      -- 1era Parte
      if bprimer then
        debehaber1 := r.b;
		raise notice 'Estoy Caso1 debehaber1 % := r.b %  | tipoprestamoid= %',debehaber1,r.b,r.tipoprestamoid;
      else
        debehaber1 := r.b-r1.b1;
		raise notice 'Estoy CASO2 debehaber1 % := r.b % - r1.b1 %   | tipoprestamoid= %',debehaber1,r.b,r1.b1,r.tipoprestamoid;
      end if;

      if debehaber1<>0 then
      if debehaber1>0 then
        scuentaid := r.cuentaactivovencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber1,0,' ',' ',
                             'Trasp. activo vig. a vencida');
        scuentaid := r.cuentaactivo;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber1,' ',' ',
                             'Disminuir la cartera vigente');
      else
        scuentaid := r.cuentaactivo;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(debehaber1),0,' ',
                             ' ','Trasp. activo vig. a vencida');
        scuentaid := r.cuentaactivovencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(debehaber1),' ',
                             ' ','Disminuir la cartera vigente');
      end if;
      end if;

      -- 2da Parte
      if bprimer then
        debehaber2 := r.c;
        debehaber21 := r.cc;
      else
        debehaber2 := r.c-r1.c1;
        debehaber21 := r.cc-r1.cc1;
      end if;

      if debehaber2<>0 then
      if debehaber2>0 then
        scuentaid := r.cuentaintdevnocobres;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber2,0,' ',' ',
                             'Activo int. dev. no cobrados');
        scuentaid := r.cuentaintnormalnocob;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber2,' ',' ',
                             'Ingreso int. dev. no cobrados'); 
      else
        scuentaid := r.cuentaintnormalnocob;        
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(debehaber2),0,' ',
               ' ','Activo int. dev. no cobrados');
        scuentaid := r.cuentaintdevnocobres;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(debehaber2),' ',
               ' ','Ingreso int. dev. no cobrados'); 
      end if;
      end if;

      if debehaber21<>0 then
        if debehaber21>0 then
          scuentaid := r.cuentaintnormalvencida;
          select *
            into pmovipolizaid
           from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber21,0,' ',' ',
                             'Orden int. dev. cartera venc.');
 	   scuentaid := r.CuentaIntNormalResVigente;
        
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber21,' ',' ',
                             'Orden int. dev. cartera venc.');         
        else 

	  scuentaid := r.CuentaIntNormalResVigente;
          
          select *
            into pmovipolizaid
            from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(debehaber21),0,' ',
               ' ','Orden int. dev. cartera venc.');
          --scuentaid := r.cuentaintdevnocobres;  Esta cuenta estaba mal
          scuentaid := r.cuentaintnormalvencida;
          select *
            into pmovipolizaid
            from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(debehaber21),' ',
               ' ','Orden int. dev. cartera venc.'); 
        end if;

      end if;

      -- 3era Parte

      if bprimer then
        debehaber3 := r.d + r.dd;
      else
        debehaber3 := r.d + r.dd - r1.d1 - r1.dd1;
      end if;

      if debehaber3<>0 then
      if debehaber3>0 then
        scuentaid := r.cuentaordeninteres;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber3,0,' ',' ',
                             'CuentaOrdenInteres');
        scuentaid := r.ordeninteresacreedor;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber3,' ',' ',
                             'OrdenInteresAcreedor'); 
      else
        scuentaid := r.ordeninteresacreedor;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(debehaber3),0,' ',
               ' ','OrdenInteresAcreedor');
        scuentaid := r.cuentaordeninteres;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(debehaber3),' ',
               ' ','CuentaOrdenInteres'); 
      end if;
      end if;
      
      debehaber4 := r.interes;
      debehaber5 := r.moratorio;

      if debehaber4>0 then
        scuentaid := r.cuentaintnormal;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber4,0,' ',' ',
                             'CuentaIntNormal');
      end if;
      if debehaber5>0 then
        scuentaid := r.cuentaintmora;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber5,0,' ',' ',
                             'CuentaIntMora');
      end if;
      if debehaber4>0 then
        scuentaid := r.cuentaintnormalresvencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber4,
               ' ',' ','cuentaintnormalresvencida'); 
      end if;
      if debehaber5>0 then
        scuentaid := r.cuentaintmoravencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber5,
               ' ',' ','cuentaintmroavencida'); 
      end if;

    end loop;
  end loop;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;