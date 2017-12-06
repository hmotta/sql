drop type tmatrizriesgo cascade;

CREATE TYPE tmatrizriesgo AS (
  friesgo1 numeric,
  friesgo2 numeric,
  friesgo3 numeric,
  friesgo4 numeric,
  friesgo5 numeric,
  friesgo6 numeric,
  friesgo7 numeric,
  friesgo8 numeric,
  friesgo9 numeric,
  friesgo10 numeric,
  friesgo11 numeric,
  friesgo12 numeric,
  friesgo13 numeric,
  friesgo14 numeric,
  friesgo15 numeric,
  friesgo16 numeric,
  friesgo17 numeric,
  friesgo18 numeric,
  friesgo19 numeric,
  friesgo20 numeric
);

CREATE or replace FUNCTION generamatrizriesgo(integer,integer,integer, character) RETURNS SETOF tmatrizriesgo
    AS $_$
declare
  psocioid alias for $1;
  ptipobusqueda alias for $2;
  preferenciacaja alias for $3;
  pseriecaja alias for $4;

  r tmatrizriesgo%rowtype;

  stipomovimientoid character(2);
  isujetoid integer;
  iedad integer;
  stiposocioid character(2);
  spaterno varchar(20);
  smaterno varchar(20);
  snombre varchar(40);
  srfc character(16);
  scurp character(20);

-- rangooper
  perdiames date;
  ultdiames date;
begin

  select su.sujetoid,edad,tiposocioid,paterno,materno,nombre,rfc,curp into isujetoid,iedad,stiposocioid,spaterno,smaterno,snombre,srfc,scurp from socio s, sujeto su where s.sujetoid=su.sujetoid and socioid=psocioid;
  isujetoid:=coalesce(isujetoid,0);
  
  
  if ptipobusqueda=0 then -- Busqueda de matriz con datos de ingreso
    raise notice 'Consultando informacion de ingreso';
  else
    raise notice 'Consultando informacion de registro';
  end if;

  if isujetoid>0 then  -- Validamos que exista el socio

    -- friesgo1 - Tipo_operacion | Buscado en movicaja o Conoceatucliente
    --PRESTAMO 2.5  AHORRO 5.5      INVERSION 8.5
      if ptipobusqueda=0 then
        select (case when aperturainversion=1 then 8.5 else (case when aperturaahorro=1 then 5.5 else 2.5 end) end) into r.friesgo1 from conoceatucliente where socioid=psocioid;
      r.friesgo1:=coalesce(r.friesgo1,2.5);      
      else
        select tipomovimientoid into stipomovimientoid from movicaja where referenciacaja=preferenciacaja and seriecaja=pseriecaja;

        r.friesgo1:=2.5;
        if stipomovimientoid='00' then 
          r.friesgo1:=2.5;
        elseif stipomovimientoid in ('AA','AS') then 
          r.friesgo1:=5.5;
        elseif stipomovimientoid = 'IN' then 
	  r.friesgo1:=8.5;
        end if;        
      end if;

      --2 Zona Geografica | Buscado en domicilio
      --SUR/ESTE/OESTE 2.5    Centro 5.5      NOR/ESTE/OESTE/EXTRAJERO 8.5 
      r.friesgo2:=2.5;
      select (case when estadomexid in (4,20,23,27,31) then 2.5 when estadomexid in (9,12,13,15,17,21,22,29,30) then 5.5 else 8.5 end) into r.friesgo2 from ciudadesmex where ciudadmexid =(select ciudadmexid from domicilio where sujetoid=isujetoid);

      --3 Nacionalidad | Buscado en conoceatucliente
      --Mexicana 2.5   Extranjero 8.5 
      select (case when coalesce(trim(nacionalidad),'MEXICANA')='MEXICANA' then 0 else 1 end) into r.friesgo3 from conoceatucliente where socioid=psocioid;
      r.friesgo3:=coalesce(r.friesgo3,0);      
      r.friesgo3:=(case when r.friesgo3 = 0 then 2.5  else 8.5 end);

      --4 Edad | Buscado en sujeto
      --31 A 50 2.5  50 o mÃ¡s 5.5  18 a 30 8.5
      r.friesgo4:=(case when iedad between 31 and 50 then 2.5 when iedad >50 then 5.5 else 8.5 end);

      --5 ESTADO CIVIL | Buscado en solicitudingreso
      --CASADO 2.5 UNION LIBRE 5.5 SOLTERO, VIUDO, DIVORCIADO 8.5
      select (case when estadocivilid=4 then 5.5 when estadocivilid in (0,2,3) then 8.5 else 2.5 end) into r.friesgo5 from solicitudingreso where sujetoid=isujetoid;
      r.friesgo5:=coalesce(r.friesgo5,2.5);
      
      --6 Actividad | Buscado en conoceatucliente
      --Propietario 2.5  Empleado 5.5  Desempleado 8.5
      select actividadid into r.friesgo6 from conoceatucliente where socioid=psocioid;
      r.friesgo6:=coalesce(r.friesgo6,2);      
      r.friesgo6:=(case when r.friesgo6 = 0 then 8.5 when r.friesgo6 = 1 then 5.5 else 2.5 end);

      --7 INGRESOS MES  POR ACTIVIDAD | Buscado en conoceatucliente
      -- >50,000 2.5  10,000 a 50,000 5.5  Menor a 10,000 8.5
      select salariomensual into r.friesgo7 from conoceatucliente where socioid=psocioid;
      r.friesgo7:=coalesce(r.friesgo7,0);      
      r.friesgo7:=(case when r.friesgo7 between 10000.00 and 50000.00 then 5.5 when r.friesgo7 < 10000.00 then 8.5 else 2.5 end);

      --8 TIEMPO EN EMPLEO | Buscado en conoceatucliente
      -- 5 años o mas 2.5 | 2 años menos de 5 5.5 | menos de 2 años 8.5
      select date_part('year',age(current_date ,fechaingresotrabajo)) into r.friesgo8 from conoceatucliente where socioid=psocioid;
      r.friesgo8:=coalesce(r.friesgo8,0);      
      r.friesgo8:=(case when r.friesgo8 between 2 and 5 then 5.5 when r.friesgo8 < 2 then 8.5 else 2.5 end);

      --9 Monto de operaciones | Buscado en conoceatucliente o calculado con deppromedio
      -- < a 30000.00 2.5 | entre 30000.00 y 50000 5.5 | > 50000.00 8.5
      if ptipobusqueda=0 then
        select montooperaciones into r.friesgo9 from conoceatucliente where socioid=psocioid;
      else
        select deppromedio(psocioid) into r.friesgo9;
      end if;
      r.friesgo9:=coalesce(r.friesgo9,0);      
      r.friesgo9:=(case when r.friesgo9 between 30000.00 and 50000.00 then 5.5 when r.friesgo9 < 30000.00 then 2.5 else 8.5 end);

      --10 INSTRU_MONETARIO | Buscado en conoceatucliente
      --CHEQUE 2.5    TRANSF 5.5.     EFECTIVO 8.5
      select formaoperaciones into r.friesgo10 from conoceatucliente where socioid=psocioid;
      r.friesgo10:=coalesce(r.friesgo10,0);      
      r.friesgo10:=(case when r.friesgo10=0 then 8.5 when r.friesgo10=1 then 2.5 else 5.5 end);
      
      --11 FRECUENCIA_OPS | Buscado en conoceatucliente
      --1 A 4  2.5 | 5 O 6 5.5 | >=7 8.5
      if ptipobusqueda=0 then
        select frecuenciaoperaciones into r.friesgo11 from conoceatucliente where socioid=psocioid;
      else
        perdiames:=cast(to_char(cast(extract(year from current_date) as integer),'9999')||'-'||ltrim(to_char(cast(extract(month from current_date) as integer),'99'))||'-'||ltrim(to_char(1,'99'))as date);
	ultdiames:=cast(to_char(cast(extract(year from (current_date + interval '1 month')) as integer),'9999')||'-'||ltrim(to_char(cast(extract(month from (current_date + interval '1 month')) as integer),'99'))||'-'||ltrim(to_char(1,'99'))as date)-1;

	--raise notice 'Fechas busqueda: % and %, socio: %',perdiames,ultdiames,psocioid;

        select count(*) into r.friesgo11 from movicaja mc, polizas po where po.polizaid=mc.polizaid and estatusmovicaja='A' and tipomovimientoid in ('CC','00','AA','IN') and mc.socioid=psocioid and (po.fechapoliza between perdiames and ultdiames);
       --raise notice 'conta oper mes %', r.friesgo11;

        r.friesgo11:=(case when (r.friesgo11<=4) then 0 when (r.friesgo11 between 5 and 6) then 1 else 2 end); 
      end if;
      r.friesgo11:=coalesce(r.friesgo11,0);      
      r.friesgo11:=(case when r.friesgo11=0 then 2.5 when r.friesgo11=1 then 5.5 else 8.5 end);

      --12 Propiedad | Buscado en conoceatucliente
      --PROPIOS 2.5   FAMILIA 5.5     OTROS 8.5
      select propiedadrecursos into r.friesgo12 from conoceatucliente where socioid=psocioid;
      r.friesgo12:=coalesce(r.friesgo12,0);      
      r.friesgo12:=(case when r.friesgo12 = 0 then 2.5 when r.friesgo12 = 1 then 5.5 else 8.5 end);

      --13 TIPO RESIDENCIA | Buscado en socioeconomico
      -- CASA 2.5      DEPARTAMENTO 5.5        UNIDAD HABITACIONAL /VECINDAD 8.5
      select (case when tipocasa='Casa Propia' then 2.5 when tipocasa='Departamento' then 5.5 else 8.5 end) into r.friesgo13 from socioeconomico where socioid=psocioid;
      r.friesgo13:=coalesce(r.friesgo13,8.5);      

      --14 TIPO RESIDENCIA | Buscado en solicitudingreso
      --PROPIA 2.5    FAMILIAR 5.5    RENTA 8.5
      select tipocasaid into r.friesgo14 from solicitudingreso where socioid=psocioid;
      r.friesgo14:=coalesce(r.friesgo14,0);      
      r.friesgo14:=(case when r.friesgo14 = 1 then 2.5 when r.friesgo14 =2 then 5.5 else 8.5 end);

      --15 Otros Ingresos | Buscado en conoceatucliente
      -- > 50000.00 2.5 | entre 20000.00 y 50000.00 5.5 | < 20000.00 8.5
      select otrosingresos into r.friesgo15 from conoceatucliente where socioid=psocioid;
      r.friesgo15:=coalesce(r.friesgo15,0);      
      r.friesgo15:=(case when r.friesgo15 < 20000.00 then 8.5 when r.friesgo15 between 20000.00 and 50000.00 then 5.5 else 8.5 end);

      --16 CREDITOS ACTIVOS | Buscado en conoceatucliente
      --0 -2.5        1 5.5.  >2 8.5
      select credipersonales into r.friesgo16 from conoceatucliente where socioid=psocioid;
      r.friesgo16:=coalesce(r.friesgo16,0);      
      r.friesgo16:=(case when r.friesgo16 =0 then 2.5 when r.friesgo16 = 1 then 5.5 else 8.5 end);

      --17 ESTADO CReDITOS | Buscado en conoceatucliente
      --LIQUIDADO 2.5 VIGENTE AL CORRIENTE 5.5        VIGENTE EN MORA 8.5
      select credipersonalesestado into r.friesgo17 from conoceatucliente where socioid=psocioid;
      r.friesgo17:=coalesce(r.friesgo17,0);      
      r.friesgo17:=(case when r.friesgo17 =0 then 2.5 when r.friesgo17 = 1 then 5.5 else 8.5 end);

      --18 PEPS | Buscado en conoceatucliente
      --NO 2.5     SI 8.5
      select (case when (politicamenteexpuesto='1' or afiliacionpol=1) then 1 else 0 end) into r.friesgo18 from conoceatucliente where socioid=psocioid;
      r.friesgo18:=coalesce(r.friesgo18,0);      
      r.friesgo18:=(case when r.friesgo18 =0 then 2.5 else 8.5 end);

      --19 OFAC | Buscado en funcion verificalistaprevencion
      --NO EXISTE 2.5 PARECIDOS O SIMILARES 5.5       IDENTICOS 8.5
      select (case when verificalistaprevencion='ENCONTRADO' then 1 else 0 end) into r.friesgo19 from verificalistaprevencion(spaterno,smaterno,snombre,srfc,scurp);
      r.friesgo19:=(case when r.friesgo19 =0 then 2.5 else 8.5 end);

      --20 PERSONA | Buscado en socio
      --MORAL 2.5 PFAE 5.5    FISICA 8.5
      r.friesgo20:=(case when stiposocioid='02' then 8.5 when stiposocioid='04' then 5.5 else 2.5 end);
      
  end if;
  
  return next r; 
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
