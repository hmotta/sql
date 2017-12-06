CREATE or replace FUNCTION sptablaamorcalculo(numeric, date, character, integer, integer, integer, integer, date, numeric, integer) RETURNS SETOF tablaamor
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
  pcalculoid     alias for $10;

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

  daytab numeric[2][12]:=array[[31,28,31,30,31,30,31,31,30,31,30,31],
                               [31,29,31,30,31,30,31,31,30,31,30,31]];
  linteresnormal numeric;
  pprimeraamor numeric;
  lpagou numeric;
  fnoamor numeric; 

  ftasafijo numeric;
  iperiododias integer;
  ibiciesto integer;
  ianio integer;
  imes integer;
begin
--raise notice 'fin febrero: %',daytab[1][2];
  select aplicareciprocidad,iva,diasanualesprestamo,cobrardiainicial
    into saplicareciprocidad,gIVA,gdiasanualesprestamo,gcobrardiainicial
    from empresa
   where empresaid=1;

select tantos,aplicaivaprestamo,tasa_normal
    into itantos,saplicaivaprestamo,ftasa_normal
    from tipoprestamo
   where tipoprestamoid=ptipoprestamoid;

ftasa_normal:=ptasanormal;
raise notice ' ptasanormal %',ptasanormal;
--if ptipoprestamoid not in ('N5 ','N17','N18','N53','N54') then
if pcalculoid=1 then

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
   
   -- ==>> 1er amortizacion
    r.numamortizacion      := 1;
    r.fechadepago          := ppago1;
    --valida inabil
    while exists( select fecha from inabil where fecha=r.fechadepago)
    loop
	 r.fechadepago:=r.fechadepago+1;      
    end loop;
    -- <<== primer amortizacion día
    
	raise notice 'Tasa = % %',r.tasainteres,ftasa_normal;
    if saplicareciprocidad='S' then
      r.tasainteres := ftasa_normal;
      if ptipoprestamoid<>'CE1' then
        r.tasainteres          := tasareciprocidad(pmonto,pmonto,r.fechadepago,itantos);
      end if;
      if r.tasainteres > ftasa_normal then
        r.tasainteres := ftasa_normal;
      end if;
    else
      r.tasainteres        := ftasa_normal;
    end if;
	raise notice 'Tasa = % %',r.tasainteres,ftasa_normal;
    --r.importeamortizacion  := lpago1;

    -- ==>validando si unica amort
    if pnoamor>1 then      
      r.importeamortizacion  := limporteamor;  -- Para dejar la ultima mayor
    else
      r.importeamortizacion:=pmonto;
    end if;
    -- <<<== unica amort

    if gcobrardiainicial=1 then
      r.interesnormal := round(pmonto*(r.fechadepago-pfechaotorga+1)*r.tasainteres/100/gdiasanualesprestamo,2);
    else
      r.interesnormal := round(pmonto*(r.fechadepago-pfechaotorga)*r.tasainteres/100/gdiasanualesprestamo,2);
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

   -- asignando fecha segunda amort
    dfechai := r.fechadepago;
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

    while exists( select fecha from inabil where fecha=dfechaf)
    loop
	 dfechaf:=dfechaf+1;      
    end loop;

   -- <<==fecha segunda amort 
  

  for j in 2..pnoamor
  loop

    r.numamortizacion      := j;
    r.fechadepago          := dfechaf;
    if saplicareciprocidad='S' then
      if ftasa_normal>0 then
        r.tasainteres := ftasa_normal;
        if ptipoprestamoid<>'CE1' then
          r.tasainteres        := tasareciprocidad(pmonto,fsaldo,r.fechadepago,itantos);
        end if;
      else
        r.tasainteres := 0;
      end if;
    else
      r.tasainteres := ftasa_normal;
    end if;

    if j<>pnoamor then
      r.importeamortizacion := limporteamor;

    else
      r.importeamortizacion := lpago1;  -- Es la ultima
    end if;

  --  raise notice ' % % % %',ftasa_normal,fsaldo,dfechaf,dfechai;
--  raise notice '%,% dias %',dfechaf,dfechai,dfechaf-dfechai;
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

    --valida inabil
    while exists( select fecha from inabil where fecha=dfechaf)
    loop
	 dfechaf:=dfechaf+1;      
    end loop;
    --
    return next r;

  end loop;

else

--  raise notice 'pago fijo por formula';
-- Verificar si 
if pcalculoid=4 then 

raise notice 'pago fijoooo';

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

    ftasafijo:=ftasa_normal/100/360;

    if saplicaivaprestamo='S' then
      ftasamensual:=(1+gIVA)*ftasa_normal/12/100;
    else
      ftasamensual:=ftasa_normal/12/100;
      gIVA:=0.00;
    end if;

    if pperiododias>0 then 
      iperiododias:=pperiododias;
    else
      iperiododias:=pmeses*30;
    end if;

    ftasamensual:= iperiododias*ftasamensual/30;
    ftasasiniva := iperiododias*ftasasiniva/30;
  

-- Aplicando formula C=M(i/(1-(1+i)^(-n)))
	raise notice 'pmonto %, ftasamensual %, pnoamor % ',pmonto,ftasamensual,pnoamor;
    limporteamor := pmonto*(ftasamensual/(1-(1+ftasamensual)^(-(pnoamor))));

	raise notice 'limite importe amortizacion %',limporteamor;
  dfechai:=pfechaotorga;
  dfechaf:=ppago1;

    while exists( select fecha from inabil where fecha=dfechaf)
    loop
	 dfechaf:=dfechaf+1;      
    end loop;
-----------
  fsaldo:=pmonto;

  i:=1;
  for j in 1..pnoamor
  loop

    r.numamortizacion      := j;

--    if ptipoprestamoid='N18' then
--      r.fechadepago          := dfechaf+2;--
--    else
--      r.fechadepago          := dfechaf;
--    end if;

    r.fechadepago:=dfechaf;
    
    --

-- raise notice 'fsaldo % ftasassiniva% ',fsaldo,ftasasiniva;

    if j<>pnoamor then
--      raise notice '% -% ; Dias %',dfechaf,dfechai,dfechaf-dfechai;
      r.interesnormal        := round(fsaldo*(dfechaf-dfechai)*ftasafijo,2);
--      r.interesnormal        := round(fsaldo*ftasasiniva,2);
      r.iva                  := round(r.interesnormal*gIVA,2);     
      lpago1                 := round(limporteamor-r.interesnormal-r.iva,2);
		raise notice 'Amor %, fechaf %, fechai %, dias %,pago % ',j,dfechaf,dfechai,dfechaf-dfechai,lpago1;
    else
    
      r.interesnormal        := round(fsaldo*(dfechaf-dfechai)*ftasafijo,2);
--    r.interesnormal        := round(fsaldo*ftasasiniva,2);
      r.iva                  := round(r.interesnormal*gIVA,2);
      lpago1                 := round(fsaldo,2);

    end if;

    r.importeamortizacion  := lpago1;
    r.saldo_absoluto       := fsaldo - lpago1;
    r.pagototal            := lpago1+r.interesnormal+r.iva;
    fsaldo := r.saldo_absoluto;
    
    dfechai := dfechaf;    

   


    if pperiododias=15 then
        dfechaf:=dfechaf+10;
        if date_part('day',dfechaf)<=15 then
           select cast(to_char(date_part('year',dfechaf),'9999')||'-'||trim(to_char(date_part('month',dfechaf),'99'))||'-15' as date) into dfechaf;
        else
	  ianio:=date_part('year',dfechaf);
	  if ((ianio%4=0 and ianio%100<>0) or ianio%400=0) then 
            ibiciesto:=2;
          else
            ibiciesto:=1;
          end if;
          --raise notice 'anio:%, fin febrero: %',ianio,daytab[ibiciesto][2];
	
          select cast(to_char(date_part('year',dfechaf),'9999')||'-'||trim(to_char(date_part('month',dfechaf),'99'))||'-'||trim(to_char(daytab[ibiciesto][date_part('month',dfechaf)],'99')) as date) into dfechaf;
        end if;
        --raise notice ' 2 -- % % ',dfechaf,r.fechadepago;
    else
       if pperiododias>0 then
         dfechaf:=dfechaf+iperiododias;
       else
         ianio:=date_part('year',dfechaf);
         imes:=date_part('month',dfechaf);
--	 raise notice 'Anio:%, Mes:%',ianio,imes;
	 imes:=imes+pmeses;
         while imes>12 loop
            imes:=imes-12;
            ianio:=ianio+1;
         end loop;
	-- raise notice 'Anio:%, Mes:%',ianio,imes;
         dfechaf:=cast(trim(to_char(ianio,'9999'))||'-'||trim(to_char(imes,'99'))||'-'||trim(to_char(pdiames,'99')) as date);
       end if;
    end if;
    --valida inabil
    while exists( select fecha from inabil where fecha=dfechaf)
    loop
      dfechaf:=dfechaf+1;      
    end loop;
    
    return next r;


  end loop;
--end if; --fijo
else 
  -- Pago global fijo
  if pcalculoid=5 then  --Global 

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
  end if;--pnoamor>1
   
    r.numamortizacion      := 1;
    r.fechadepago          := ppago1;
    --valida inabil
    while exists( select fecha from inabil where fecha=r.fechadepago)
    loop
	 r.fechadepago:=r.fechadepago+1;      
    end loop;
    --
    
--    if saplicareciprocidad='S' then
      r.tasainteres        := ftasa_normal;
--    end if;
	raise notice 'Tasa = % %',r.tasainteres,ftasa_normal;
    --r.importeamortizacion  := lpago1;
    if pnoamor>1 then      
      r.importeamortizacion  := limporteamor;  -- Para dejar la ultima mayor
    else
      r.importeamortizacion:=pmonto;
    end if;

    if gcobrardiainicial=1 then
       if pperiododias >0 then
         r.interesnormal:=round((pmonto*(pperiododias+1)*r.tasainteres/100/360),2);
       else
         r.interesnormal:=round((pmonto*(pmeses*30+1)*r.tasainteres/100/360),2);
       end if;
--      r.interesnormal := round(pmonto*(r.fechadepago-pfechaotorga+1)*r.tasainteres/100/gdiasanualesprestamo,2);
    else
       if pperiododias >0 then
         r.interesnormal:=round((pmonto*pperiododias*r.tasainteres/100/360),2);
       else
         r.interesnormal:=round((pmonto*(pmeses*30)*r.tasainteres/100/360),2);
       end if;
  --    r.interesnormal := round(pmonto*(r.fechadepago-pfechaotorga)*r.tasainteres/100/gdiasanualesprestamo,2);
    end if;--cobrarinicial


    if saplicaivaprestamo='S' then
      r.iva := r.interesnormal*gIVA;
    else
      r.iva := 0;
    end if;


    r.saldo_absoluto       := pmonto - limporteamor;
    r.pagototal            := round(limporteamor+r.interesnormal+r.iva,2);

    fsaldo := r.saldo_absoluto;
    return next r;
-------Fechas

    dfechai := r.fechadepago;
    if pperiododias>0 then
       dfechaf := dfechai + pperiododias;    
    else
      dfechaf:=dfechai+pmeses*30;
      -- Validar dia del mes
    end if;
  for j in 2..pnoamor
  loop

    r.numamortizacion      := j;
    r.fechadepago          := dfechaf;

--     validar saplicareciprocidad='S'
      r.tasainteres        := ftasa_normal;
--    end if;
	raise notice 'Tasa = % %',r.tasainteres,ftasa_normal;
    if j<>pnoamor then
      r.importeamortizacion := limporteamor;
    else
      r.importeamortizacion := lpago1;  -- Es la ultima
    end if;

---
    --raise notice ' % % % %',ftasa_normal,fsaldo,dfechaf,dfechai;
       if pperiododias >0 then
         r.interesnormal:=round((pmonto*pperiododias*r.tasainteres/100/360),2);
       else
         r.interesnormal:=round((pmonto*(pmeses*30)*r.tasainteres/100/360),2);
       end if;

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
      dfechaf:=dfechai+pmeses*30;
      --validar dia del mes
    end if;

    --valida inabil
    while exists( select fecha from inabil where fecha=dfechaf)
    loop
	 dfechaf:=dfechaf+1;      
    end loop;
    --
    return next r;

  end loop;

end if;--- Global

end if;

end if;

return;
end
 $_$
    LANGUAGE plpgsql SECURITY DEFINER;