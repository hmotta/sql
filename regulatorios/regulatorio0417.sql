
drop type tcartera417 cascade;

CREATE TYPE tcartera417 AS (
CLAVE__ENTIDAD char(6),
CLAVE_NIVEL_INSTITUCION integer,
CONCEPTO char(12),
SUBREPORTE integer,
TIPO_CARTERA integer,
DATO NUMERIC
);


CREATE or replace FUNCTION cartera417(date) RETURNS SETOF tcartera417
    AS $_$
declare

  -- Modificado el 4-08-2011
  
  pfechacierre alias for $1;
  
  r tcartera417%rowtype;
   
  pclaveentidad  char(6);
  pnivel integer;

  pejercicio integer;
  pejercicioanterior integer;
  
  pperiodo integer;
  pperiodoanterior integer;

  psaldo1303 numeric;
  
  fReserva numeric;
  fcapitalinteres numeric;
  
  fcartera11 numeric;
  fcartera12 numeric;
  fcarteraconsumo numeric;

  fcartera13 numeric;
  fcartera14 numeric;
  fcartera15 numeric;
  fcartera16 numeric;
  fcarteracomercial numeric;

  fcartera17 numeric;
  fcarteravivienda numeric;


  freserva11 numeric;
  freserva12 numeric;
  freservaconsumo numeric;

  freserva13 numeric;
  freserva14 numeric;
  freserva15 numeric;
  freserva16 numeric;
  freservacomercial numeric;

  freserva17 numeric;
  freservavivienda numeric;

  
  fReservaint numeric;
  fEstimada numeric;
  fReserva100 numeric;
  prorratea numeric;

begin

--Nivel de la entidad
pnivel:=202;
--Clave de la entidad
pclaveentidad:='000000';

fcapitalinteres:=0;
fReserva:=0;
fcartera11:=0;
fcartera12:=0;
fcarteraconsumo:=0;

fcartera13:=0;
fcartera14:=0;
fcartera15:=0;
fcartera16:=0;
fcarteracomercial:=0;

fcartera17:=0;
fcarteravivienda:=0;




pejercicio:=cast(extract(year from pfechacierre) as integer);
pperiodo:=cast(extract(month from pfechacierre) as integer);

if (pperiodo > 1) then
  pejercicioanterior=pejercicio;
  pperiodoanterior=pperiodo-1;
else
   pejercicioanterior=pejercicio-1;
   pperiodoanterior=12;
end if;
       

select round(saldoinicialperiodo+cargosdelperiodo-abonosdelperiodo) into psaldo1303 from saldos where ejercicio=pejercicioanterior and periodo=pperiodoanterior and cuentaid='1303';

select rtrim(ltrim(claveentidad)) into  pclaveentidad from empresa;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='850000000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=0;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='851000000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=0;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='851001000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=0;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='851002000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=0;
return next r;

for r in
  select pclaveentidad,pnivel,cuentasiti,417,9,round(saldo)+round(intvigente) from clasificaxtipofinalidad(pfechacierre,'002','11','N') order by cuentasiti
  loop
    fcartera11:=fcartera11+r.dato;
    fcarteraconsumo:=fcarteraconsumo+r.dato;
    fcapitalinteres:=fcapitalinteres+r.dato;
    return next r;
  end loop;
  
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852001010000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcartera11;
return next r;

for r in
  select pclaveentidad,pnivel,cuentasiti,417,9,round(saldo)+round(intvigente) from clasificaxtipofinalidad(pfechacierre,'002','12','N') order by cuentasiti
  loop
    fcartera12:=fcartera12+r.dato;
    fcarteraconsumo:=fcarteraconsumo+r.dato;
    fcapitalinteres:=fcapitalinteres+r.dato;
    return next r;
  end loop;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852001020000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcartera12;
return next r;


r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852001000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcarteraconsumo;
return next r;

--Termina consumo


for r in
  select pclaveentidad,pnivel,cuentasiti,417,9,round(saldo)+round(intvigente) from clasificaxtipofinalidad(pfechacierre,'001','13','N') order by cuentasiti
  loop
    fcartera13:=fcartera13+r.dato;
    fcarteracomercial:=fcarteracomercial+r.dato;
    fcapitalinteres:=fcapitalinteres+r.dato;
    return next r;
  end loop;


r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002010000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcartera13;
return next r;
  
for r in
  select pclaveentidad,pnivel,cuentasiti,417,9,round(saldo)+round(intvigente) from clasificaxtipofinalidad(pfechacierre,'001','14','N') order by cuentasiti
  loop
    fcartera14:=fcartera14+r.dato;
    fcarteracomercial:=fcarteracomercial+r.dato;
    fcapitalinteres:=fcapitalinteres+r.dato;
    return next r;
  end loop;
  
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002020000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcartera14;
return next r;
  
for r in
  select pclaveentidad,pnivel,cuentasiti,417,9,round(saldo)+round(intvigente) from clasificaxtipofinalidad(pfechacierre,'001','15','N') order by cuentasiti
  loop
    fcartera15:=fcartera15+r.dato;
    fcarteracomercial:=fcarteracomercial+r.dato;
    fcapitalinteres:=fcapitalinteres+r.dato;
    return next r;
  end loop;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002030000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcartera15;
return next r;
  

for r in
  select pclaveentidad,pnivel,cuentasiti,417,9,round(saldo)+round(intvigente) from clasificaxtipofinalidad(pfechacierre,'001','16','N') order by cuentasiti
  loop
    fcartera16:=fcartera16+r.dato;
    fcarteracomercial:=fcarteracomercial+r.dato;
    fcapitalinteres:=fcapitalinteres+r.dato;
    return next r;
  end loop;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002040000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcartera16;
return next r;
  
  
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcarteracomercial;
return next r;

--Termina comercial

for r in
  select pclaveentidad,pnivel,cuentasiti,417,9,round(saldo)+round(intvigente) from clasificaxtipofinalidad(pfechacierre,'003','17','N') order by cuentasiti
  loop
    fcartera17:=fcartera17+r.dato;
    fcarteravivienda:=fcarteravivienda+r.dato;
    fcapitalinteres:=fcapitalinteres+r.dato;
    return next r;
  end loop;


r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852003000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcarteravivienda;
return next r;


r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852000000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=9;
r.DATO :=fcapitalinteres;
return next r;


--Estimaciones

freserva11:=0;
freserva12:=0;
freservaconsumo:=0;

freserva13:=0;
freserva14:=0;
freserva15:=0;
freserva16:=0;
freservacomercial:=0;

freserva17:=0;
freservavivienda:=0;



r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='851000000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=psaldo1303;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='851001000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=0;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='851002000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=psaldo1303;
return next r;

for r in
  select pclaveentidad,pnivel,cuentasiti,417,10,round(totalreserva)*-1 from clasificaxtipofinalidad(pfechacierre,'002','11','N') order by cuentasiti
  loop
    freserva11:=freserva11+r.dato;
    freservaconsumo:=freservaconsumo+r.dato;
    fReserva:=fReserva+r.dato;
    return next r;
  end loop;
  
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852001010000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freserva11;
return next r;

for r in
  select pclaveentidad,pnivel,cuentasiti,417,10,round(totalreserva)*-1 from clasificaxtipofinalidad(pfechacierre,'002','12','N') order by cuentasiti
  loop
    freserva12:=freserva12+r.dato;
    freservaconsumo:=freservaconsumo+r.dato;
    fReserva:=fReserva+r.dato;
    return next r;
  end loop;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852001020000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freserva12;
return next r;


r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852001000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freservaconsumo;
return next r;

--Termina consumo


for r in
  select pclaveentidad,pnivel,cuentasiti,417,10,round(totalreserva)*-1 from clasificaxtipofinalidad(pfechacierre,'001','13','N') order by cuentasiti
  loop
    freserva13:=freserva13+r.dato;
    freservacomercial:=freservacomercial+r.dato;
    fReserva:=fReserva+r.dato;
    return next r;
  end loop;


r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002010000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freserva13;
return next r;
  
for r in
  select pclaveentidad,pnivel,cuentasiti,417,10,round(totalreserva)*-1 from clasificaxtipofinalidad(pfechacierre,'001','14','N') order by cuentasiti
  loop
    freserva14:=freserva14+r.dato;
    freservacomercial:=freservacomercial+r.dato;
    fReserva:=fReserva+r.dato;
    return next r;
  end loop;
  
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002020000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freserva14;
return next r;

  
for r in
  select pclaveentidad,pnivel,cuentasiti,417,10,round(totalreserva)*-1 from clasificaxtipofinalidad(pfechacierre,'001','15','N') order by cuentasiti
  loop
    freserva15:=freserva15+r.dato;
    freservacomercial:=freservacomercial+r.dato;
    fReserva:=fReserva+r.dato;
    return next r;
  end loop;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002030000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freserva15;
return next r;
  
for r in
  select pclaveentidad,pnivel,cuentasiti,417,10,round(totalreserva)*-1 from clasificaxtipofinalidad(pfechacierre,'001','16','N') order by cuentasiti
  loop
    freserva16:=freserva16+r.dato;
    freservacomercial:=freservacomercial+r.dato;
    fReserva:=fReserva+r.dato;
    return next r;
  end loop;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002040000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freserva16;
return next r;
    
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852002000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freservacomercial;
return next r;

--Termina comercial

for r in
  select pclaveentidad,pnivel,cuentasiti,417,10,round(totalreserva)*-1 from clasificaxtipofinalidad(pfechacierre,'003','17','N') order by cuentasiti
  loop
    freserva17:=freserva17+r.dato;
    freservavivienda:=freservavivienda+r.dato;
    fReserva:=fReserva+r.dato;
    return next r;
  end loop;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852003000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=freservavivienda;
return next r;
    
--Totales

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='852000000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=fReserva;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='850000000000';
r.SUBREPORTE :=417;
r.TIPO_CARTERA :=10;
r.DATO :=abs(psaldo1303)-abs(fReserva);
return next r;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE FUNCTION cartera417c(date) RETURNS SETOF tcartera417
    AS $_$
declare
  pfecha alias for $1;

  r tcartera417%rowtype;

  f record;
  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente='S'
 loop

        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from cartera417('||''''||pfecha||''''||');';
		  for r in
		    select * from
		   dblink(dblink1,dblink2) as
                   t2(
                   CLAVE__ENTIDAD char(6),
                   CLAVE_NIVEL_INSTITUCION integer,
                   CONCEPTO char(12),
                   SUBREPORTE integer,
                   TIPO_CARTERA integer,
                   DATO NUMERIC
                   )
	        loop
                  return next r;
             end loop;
end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


