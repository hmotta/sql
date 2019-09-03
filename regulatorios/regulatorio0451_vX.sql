--Verificar el RFC ultimos 6 ok
--Suma de interes a la responsabilidad
--Validación del negativo en la estimacion
--alter table tipoprestamo add clasificacioncontable char(24);
--comerciales

--update tipoprestamo set clasificacioncontable='130150000000' where substring(cuentaactivo,1,12)='130101010601';
--update tipoprestamo set clasificacioncontable='130171000000' where substring(cuentaactivo,1,10)='1301020201';
--update tipoprestamo set clasificacioncontable='130180000000' where substring(cuentaactivo,1,10)='1301030201';
update tipoprestamo set clasificacioncontable='130171000000' where tipoprestamoid<>'CAS';
update tipoprestamo set clasificacioncontable='130150000000' where tipoprestamoid<>'CAS' and desctipoprestamo ilike '%COMERCIAL%';


drop type tcartera451 cascade;

CREATE TYPE tcartera451 AS (
CLAVE__ENTIDAD char varying(6),
CLAVE_NIVEL_INSTITUCION char varying(6),
SUBREPORTE char varying(6),
NUMERO_SECUENCIA integer,
RAZON_SOCIAL text,
NUMERO_DEL_DEUDOR char(20),
NUMERO_DEL_CREDITO char(20),
PERSONA integer,
RFC char(15),
CLASIFICACION_CONTABLE char(12), --catalogo
MONTO_CREDITO_OTORGADO numeric,
RESP_TOTAL_A_LA_FECHA numeric,
FECHA_DISPOSICION char(8),
FECHA_VENCIMIENTO char(8),
FORMA_AMORTIZACION integer, --catalogo 
TASA_INTERES_BRUTA numeric,
INT_DEV_NO_COBRADOS numeric,
INTERESES_VENCIDOS numeric,
INT_REFINANCIADOS numeric,
SITUACION_DEL_CREDITO integer, --catalogo
NUM_REESTRUCTURAS integer,
CALIF_PARTE_CUBIERTA char(2), --catalogo
CALIF_PARTE_EXPUESTA char(2), --catalogo
ESTIMAC_PARTE_CUBIERTA numeric,
ESTIMAC_PARTE_EXPUESTA numeric,
ESTIMAC_PREV_TOTALES numeric,
PORC_GARANTIZA_AVAL numeric,
VALOR_GARANTIA numeric,
FECHA_VALUAC_GTIA char(8),
GRADO_PRELAC_GTIA numeric,
ACRED_RELACIONADO numeric,
TIPO_ACRED_RELAC numeric,
NUM_DIAS_DE_MORA numeric,
RECIPROCIDAD numeric
);


CREATE or replace FUNCTION cartera451(date) RETURNS SETOF tcartera451
    AS $_$
declare

  pfechacierre alias for $1;

  r tcartera451%rowtype;

  pejercicio integer;
  pperiodo  integer;
  fReserva numeric;
  fReservaint numeric;
  fEstimada numeric;
  fReserva100 numeric;
  prorratea numeric;
  i integer;

begin

 i:=0;
 pejercicio:=date_part('year',pfechacierre);
 pperiodo:=date_part('month',pfechacierre);

 select saldoinicialperiodo+cargosdelperiodo-abonosdelperiodo into fReserva from saldos where ejercicio=pejercicio and periodo=pperiodo and cuentaid='1303';

 fReserva:=coalesce(fReserva,0);
 fReserva:=fReserva*-1; 

 select coalesce(sum(reservaidnc),0),coalesce(sum(reservacalculada),0) into fReservaint,fEstimada from precorte where ejercicio=pejercicio and periodo=pperiodo;
        
 fReserva100:=fReservaint+fEstimada;
 if fReserva100 <> 0 then 
   prorratea:=fReserva/fReserva100;
 else
   prorratea:=0;
 end if;

raise notice ' Prorratea %  %  %  %  % ',prorratea,fReservaint,fEstimada,fReserva,fReserva100;

for r in
select
--CLAVE_ENTIDAD char(6),
'029159',
--CLAVE_NIVEL_ENTIDAD integer,
'202',
--SUBREPORTE integer,
451,
--NUMERO_SECUENCIA integer,
0,
--RAZON_SOCIAL char(25),
(case when si.personajuridicaid=0 then replace(ltrim(rtrim(su.paterno||' '||su.materno||' '||su.nombre)),'.','') else ltrim(rtrim(su.razonsocial)) end) ,
--NUMERO_DEL_DEUDOR char(20),
s.clavesocioint,
--NUMERO_DEL_CREDITO char(20),
(select substring(sucid,1,3) from empresa where empresaid=1)||substring(pr.referenciaprestamo,1,6)||substring(pr.referenciaprestamo,8,10),
--PERSONA integer,
(case when si.personajuridicaid = 0 then 1 else 2 end),
--RFC char(13),
r451rfc(su.rfc,s.clavesocioint),
--CLASIFICACION_CONTABLE char(12), --catalogo
ltrim(rtrim(t.clasificacioncontable)),
--MONTO_CREDITO_OTORGADO numeric,
round(p.montoprestamo,2),
--RESP_TOTAL_A_LA_FECHA numeric,
round(p.saldoprestamo)+round(p.interesdevengadomenoravencido),
--FECHA_DISPOSICION char(8),
to_char(pr.fecha_otorga,'YYYYMMDD'),
--FECHA_VENCIMIENTO char(8),
to_char(pr.fecha_vencimiento,'YYYYMMDD'),
--FORMA_AMORTIZACION integer, --catalogo
(case when pr.numero_de_amor > 1 then 3 else 1 end),
--TASA_INTERES_BRUTA numeric,
round(pr.tasanormal,4),
--INT_DEV_NO_COBRADOS numeric,
(case when  p.saldovencidomayoravencido=0 then round(p.interesdevengadomenoravencido) else 0 end),
--INTERESES_VENCIDOS numeric,
(case when  p.saldovencidomayoravencido>0 then round(p.interesdevengadomayoravencido) else 0 end),
--INT_REFINANCIADOS numeric,
0,
--SITUACION_DEL_CREDITO integer, --catalogo
(case when  p.diasvencidos > 0 and p.saldovencidomayoravencido>0 then 3 else (case when  p.diasvencidos > 0 and p.saldovencidomayoravencido=0 then 2 else 1 end) end),
--NUM_REESTRUCTURAS integer,
(case when p.tipoprestamoid in ('T1','T2','T3') then 1 else 0),
--CALIF_PARTE_CUBIERTA char(2), --catalogo
0,
--CALIF_PARTE_EXPUESTA char(2), --catalogo
0,
--ESTIMAC_PARTE_CUBIERTA numeric,
round(p.reservacalculada*prorratea),
--ESTIMAC_PARTE_EXPUESTA numeric,
round(p.saldoprestamo-(p.reservacalculada*prorratea)),
--28 ESTIMAC_PREV_TOTALES numeric,
(case when p.reservacalculada > 0 then round(-1*p.reservacalculada) else p.reservacalculada end),
--PORC_GARANTIZA_AVAL numeric,
0,
--VALOR_GARANTIA numeric,
round(pr.monto_garantia),
--FECHA_VALUAC_GTIA ,
(case when pr.fechavaluaciongarantia is not null then to_char( pr.fechavaluaciongarantia ,'YYYYMMDD') else '' end),
--GRADO_PRELAC_GTIA numeric,
0,
--ACRED_RELACIONADO integer,  relacionado=1 no relacionado= 2
2,
--TIPO_ACRED_RELAC numeric --catalogo
0,
--NUM_DIAS DE MORA integer,
p.diasvencidos,
--RECIPROCIDAD numeric
round(p.depositogarantia)

from precorte p,prestamos pr,socio s,tipoprestamo t, sujeto su, finalidades f, solicitudingreso si
     where p.fechacierre=pfechacierre and pr.prestamoid=p.prestamoid and
           s.socioid=pr.socioid and t.tipoprestamoid = pr.tipoprestamoid and
           su.sujetoid=s.sujetoid and s.socioid=si.socioid and f.clavefinalidad=p.clavefinalidad 
  order by p.diasvencidos,s.clavesocioint

loop 
	raise notice 'Estoy aqui';
--if r.CREDITO_REDESCONTADO = 'RD' then

   --r.Institucion_fuente_de_recursos:= 'FIRA';
   --r.Por_Garantia_efectiva_contratada := .50;
   --r.Parte_cubierta_con_garantia_contratada :=round((r.Capital_vigente+r.Capital_vencido)/2,2);

--end if;
  i:=i+1;
  r.NUMERO_SECUENCIA:=i;

return next r;

end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE FUNCTION cartera451c(date) RETURNS SETOF tcartera451
    AS $_$
declare
  pfecha alias for $1;

  r tcartera451%rowtype;

  f record;
  dblink1 text;
  dblink2 text;
	i integer;
begin
i:=0;
for f in
 select * from sucursales where vigente='S'
 loop

        --raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from cartera451('||''''||pfecha||''''||');';
        raise notice ' % % ',dblink1,dblink2;
		  for r in
		    select * from
		   dblink(dblink1,dblink2) as
                   t2(
                   CLAVE__ENTIDAD char varying(6),
                   CLAVE_NIVEL_INSTITUCION char varying(6),
                   SUBREPORTE char varying(6),
                   NUMERO_SECUENCIA integer,
                   RAZON_SOCIAL text,
                   NUMERO_DEL_DEUDOR char(20),
                   NUMERO_DEL_CREDITO char(20),
                   PERSONA integer,
                   RFC char(15),
                   CLASIFICACION_CONTABLE char(12), --catalogo
                   MONTO_CREDITO_OTORGADO numeric,
                   RESP_TOTAL_A_LA_FECHA numeric,
                   FECHA_DISPOSICION char(8),
                   FECHA_VENCIMIENTO char(8),
                   FORMA_AMORTIZACION integer, --catalogo 
                   TASA_INTERES_BRUTA numeric,
                   INT_DEV_NO_COBRADOS numeric,
                   INTERESES_VENCIDOS numeric,
                   INT_REFINANCIADOS numeric,
                   SITUACION_DEL_CREDITO integer, --catalogo
                   NUM_REESTRUCTURAS integer,
                   CALIF_PARTE_CUBIERTA char(2), --catalogo
                   CALIF_PARTE_EXPUESTA char(2), --catalogo
                   ESTIMAC_PARTE_CUBIERTA numeric,
                   ESTIMAC_PARTE_EXPUESTA numeric,
                   ESTIMAC_PREV_TOTALES numeric,
                   PORC_GARANTIZA_AVAL numeric,
                   VALOR_GARANTIA numeric,
                   FECHA_VALUAC_GTIA char(8),
                   GRADO_PRELAC_GTIA numeric,
                   ACRED_RELACIONADO numeric,
                   TIPO_ACRED_RELAC numeric,
                   NUM_DIAS_DE_MORA numeric,
                   RECIPROCIDAD numeric                                      
                   )
	        loop
				  i:=i+1;
				  r.NUMERO_SECUENCIA:=i;
                  return next r;
             end loop;
end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE or replace FUNCTION r451rfc(text,char(15)) RETURNS text
    AS $_$
declare
  scampo alias for $1;
  clavesocioint alias for $2;
  stmp text;
begin

  stmp:=ltrim(rtrim(upper(scampo)));
  stmp:=replace(stmp,' ','');
  stmp:=replace(stmp,'-','');
  stmp:=replace(stmp,'.','');
  
  --if length(stmp) < 13 then
  --   stmp:='ANTE'||substring(replace(clavesocioint,'-',''),5,6);
  --end if;
  
return stmp;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
