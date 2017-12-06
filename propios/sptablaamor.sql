CREATE OR REPLACE FUNCTION sptablaamor(numeric, date, character, integer, integer, integer, integer, date, numeric) RETURNS SETOF tablaamor
    AS $_$
declare
  pmonto          alias for $1;
  ppago1          alias for $2;
  ptipoprestamoid alias for $3;
  pnoamor         alias for $4;
  pperiododias    alias for $5;
  pmeses          alias for $6;
  pdiames         alias for $7;
  pfechaotorga    alias for $8;
  ptasanormal     alias for $9;

  r tablaamor%rowtype;
  j int;
  i int;
  limporteamor numeric;
  lpago1 numeric;
  itantos int;
  saplicaivaprestamo char(1);
  fsaldo numeric;
  dfechai date;
  dfechaf date;
  ftasa_normal numeric;
  diames int;
  mmes int;
  ames int;
  fmonto numeric;
 
  saplicareciprocidad char(1);
  gIVA numeric;
  gdiasanualesprestamo int4;

  gcobrardiainicial int4;

  ftasasiniva numeric;
  ftasamensual numeric;
  idif int4;

  daytab numeric[2][13]:=array[[31,28,31,30,31,30,31,31,30,31,30,31,31],
                               [31,29,31,30,31,30,31,31,30,31,30,31,31]];
  linteresnormal numeric;
  pprimeraamor numeric;
  lpagou numeric;
  fnoamor numeric; 

begin

  select aplicareciprocidad,iva,diasanualesprestamo,cobrardiainicial
    into saplicareciprocidad,gIVA,gdiasanualesprestamo,gcobrardiainicial
    from empresa
   where empresaid=1;

select tantos,aplicaivaprestamo,tasa_normal
    into itantos,saplicaivaprestamo,ftasa_normal
    from tipoprestamo
   where tipoprestamoid=ptipoprestamoid;

ftasa_normal:=ptasanormal;

if ptipoprestamoid not in ('N5 ','N17','N18','N53','N54') then

  limporteamor := trunc(pmonto/pnoamor);

  if pnoamor>1 then
    if limporteamor*pnoamor=pmonto then
      lpago1 := limporteamor;
    else
      lpago1 := limporteamor + pmonto - pnoamor*trunc(pmonto/pnoamor);
    end if;
  else
    lpago1 := pmonto;
    limporteamor := pmonto;
  end if;
   
    r.numamortizacion      := 1;
    r.fechadepago          := ppago1;
    if saplicareciprocidad='S' then
      r.tasainteres := ftasa_normal;
      if ptipoprestamoid<>'CE1' then
        r.tasainteres          := tasareciprocidad(pmonto,pmonto,ppago1,itantos);
      end if;
      if r.tasainteres>ftasa_normal then
        r.tasainteres := ftasa_normal;
      end if;
    else
      r.tasainteres        := ftasa_normal;
    end if;

    --r.importeamortizacion  := lpago1;
    if pnoamor>1 then      
      r.importeamortizacion  := limporteamor;  -- Para dejar la ultima mayor
    else
      r.importeamortizacion:=pmonto;
    end if;

    if gcobrardiainicial=1 then
      r.interesnormal := round(pmonto*(ppago1-pfechaotorga+1)*r.tasainteres/100/gdiasanualesprestamo,2);
    else
      r.interesnormal := round(pmonto*(ppago1-pfechaotorga)*r.tasainteres/100/gdiasanualesprestamo,2);
    end if;
    if saplicaivaprestamo='S' then
      r.iva := r.interesnormal*gIVA;
    else
      r.iva := 0;
    end if;
    r.saldo_absoluto       := pmonto - limporteamor;
    r.pagototal            := round(limporteamor+r.interesnormal+r.iva,2);

    fsaldo := r.saldo_absoluto;
    return next r;

    dfechai := ppago1;
    if pperiododias>0 then
       dfechaf := dfechai + pperiododias;    
    else
      
       dfechaf := dfechai;
       for i in 1..pmeses
       loop
         select dfechaf + interval '1 month'
           into dfechaf;
       end loop;

       diames:=pdiames;
       mmes:=cast(extract(month from dfechaf) as integer);
       ames:=cast(extract(year from dfechaf) as integer);
       if mmes = 2 and pdiames > 28 then
          diames:=28;
       end if;
       if (mmes = 4 or mmes = 6 or mmes= 9 or mmes = 11 ) and pdiames=31 then 
          diames:=30;
       end if;
       dfechaf := cast(to_char(ames,'9999')||'-'||ltrim(to_char(mmes,'99'))||'-'||ltrim(to_char(diames,'99'))as date);

    end if;

  for j in 2..pnoamor
  loop

    r.numamortizacion      := j;
    r.fechadepago          := dfechaf;
    if saplicareciprocidad='S' then
      if ftasa_normal>0 then
        r.tasainteres := ftasa_normal;
        if ptipoprestamoid<>'CE1' then
          r.tasainteres        := tasareciprocidad(pmonto,fsaldo,ppago1,itantos);
        end if;
      else
        r.tasainteres := 0;
      end if;
    else
      r.tasainteres        := ftasa_normal;
    end if;

    if j<>pnoamor then
      r.importeamortizacion := limporteamor;

    else
      r.importeamortizacion := lpago1;  -- Es la ultima

    end if;
    --raise notice ' % % % %',ftasa_normal,fsaldo,dfechaf,dfechai;
    r.interesnormal        := round(fsaldo*(dfechaf-dfechai)*r.tasainteres/100/gdiasanualesprestamo,2);
    if saplicaivaprestamo='S' then
      r.iva := round(r.interesnormal*gIVA,2);
    else
      r.iva := 0;
    end if;
    r.saldo_absoluto       := fsaldo - r.importeamortizacion;
    r.pagototal            := round(r.importeamortizacion + r.interesnormal+r.iva,2);

    fsaldo := r.saldo_absoluto;

    dfechai := dfechaf;
    if pperiododias>0 then      
       dfechaf := dfechai + pperiododias;
    else

       dfechaf := dfechai;
       for i in 1..pmeses
       loop
         select dfechaf + interval '1 month'
           into dfechaf;
       end loop;

       diames:=pdiames;
       mmes:=cast(extract(month from dfechaf) as integer);
       ames:=cast(extract(year from dfechaf) as integer);
       if mmes = 2 and pdiames > 28 then
          diames:=28;
       end if;
       if (mmes = 4 or mmes = 6 or mmes= 9 or mmes = 11 ) and pdiames=31 then 
          diames:=30;
       end if;
       dfechaf := cast(to_char(ames,'9999')||'-'||ltrim(to_char(mmes,'99'))||'-'||ltrim(to_char(diames,'99'))as date);

    end if;

    return next r;

  end loop;

else

--  raise notice 'pago fijo por formula';
-- Verificar si 


raise notice 'pago fijo';

-- Verificar si 

  select aplicareciprocidad,iva,diasanualesprestamo,cobrardiainicial
    into saplicareciprocidad,gIVA,gdiasanualesprestamo,gcobrardiainicial
    from empresa
   where empresaid=1;

  select tantos,aplicaivaprestamo,tasa_normal
    into itantos,saplicaivaprestamo,ftasa_normal
    from tipoprestamo
   where tipoprestamoid=ptipoprestamoid;

    ftasa_normal:=ptasanormal;

    ftasasiniva:=ftasa_normal/12/100;

    if saplicaivaprestamo='S' then
      ftasamensual:=(1+gIVA)*ftasa_normal/12/100;
    else
      ftasamensual:=ftasa_normal/12/100;
      gIVA:=0.00;
    end if;

    ftasamensual:= pperiododias*ftasamensual/30;
    ftasasiniva := pperiododias*ftasasiniva/30;

   if pperiododias=15 then
   
    if date_part('day',dfechaf)<15 then

     select cast(to_char(date_part('year',dfechaf),'9999')||'-'||trim(to_char(date_part('month',dfechaf),'99'))||'-15' as date) into dfechaf;

     
    else

      select cast(to_char(date_part('year',dfechaf),'9999')||'-'||trim(to_char(date_part('month',dfechaf),'99'))||'-'||trim(to_char(daytab[1][date_part('month',dfechaf)],'99')) as date) into dfechaf;

    end if;
  end if;

  

-- Aplicando formula C=M(i/(1-(1+i)^(-n)))

    limporteamor := pmonto*(ftasamensual/(1-(1+ftasamensual)^(-(pnoamor))));

--raise exception 'Importe amortizacione %',limporteamor;

  dfechaf:=ppago1;
  fsaldo:=pmonto;

  i:=1;
  for j in 1..pnoamor
  loop

    r.numamortizacion      := j;


     if pperiododias=15 then
   
        if date_part('day',dfechaf)<=15 then

           select cast(to_char(date_part('year',dfechaf),'9999')||'-'||trim(to_char(date_part('month',dfechaf),'99'))||'-15' as date) into dfechaf;

     
        else

           select cast(to_char(date_part('year',dfechaf),'9999')||'-'||trim(to_char(date_part('month',dfechaf),'99'))||'-'||trim(to_char(daytab[1][date_part('month',dfechaf)],'99')) as date) into dfechaf;

        end if;

        --raise notice ' 2 -- % % ',dfechaf,r.fechadepago;
            
    end if;


    if ptipoprestamoid='N18' then
      r.fechadepago          := dfechaf+2;
    else
      r.fechadepago          := dfechaf;
    end if;

    --raise notice '% % ',dfechaf,r.fechadepago;

    if j<>pnoamor then

      r.interesnormal        := round(fsaldo*ftasasiniva,2);
      r.iva                  := round(r.interesnormal*gIVA,2);     
      lpago1                 := round(limporteamor-r.interesnormal-r.iva,2);

    else
    
      r.interesnormal        := round(fsaldo*ftasasiniva,2);
      r.iva                  := round(r.interesnormal*gIVA,2);
      lpago1                 := round(fsaldo,2);

    end if;

    r.importeamortizacion  := lpago1;
    r.saldo_absoluto       := fsaldo - lpago1;
    r.pagototal            := lpago1+r.interesnormal+r.iva;
    fsaldo := r.saldo_absoluto;
    
    dfechai := dfechaf;    

   
    dfechaf:=dfechaf+pperiododias;
    
    return next r;


  end loop;


end if;

return;
end
 $_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.sptablaamor(numeric, date, character, integer, integer, integer, integer, date, numeric) OWNER TO sistema;

