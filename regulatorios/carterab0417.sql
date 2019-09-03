-- Modificado para ser multinivel de entidad en base a tablareservas
--
-- Modo de uso select * from clasificaxtipofinalidad('2009-09-30','002','S');
-- update  tablareserva set factordisminucion=.34;

--
-- Name: clasificaxtipofinalidad(date, character, character); Type: FUNCTION; Schema: public; Owner: sistema
--
--
-- Name: tclasificaxbandas; Type: TYPE; Schema: public; Owner: sistema
--
drop type tclasificaxbandas cascade;

CREATE TYPE tclasificaxbandas AS (
	rango character(64),
	nocreditos integer,
	saldo numeric,
	intvigente numeric,
	garantia numeric,
	porrequerido numeric,
	reservaidnc numeric,
	porcentajereserva numeric,
        reservagarantia   numeric,
	reservacalculada numeric,
	totalreserva numeric,
	reservarequerida numeric,
        tablareservaid  int4,
        cuentasiti      char(24)
);



CREATE or replace FUNCTION clasificaxtipofinalidad(date, character, character) RETURNS SETOF tclasificaxbandas
    AS $_$
declare

pfecha alias for $1;
pclavefinalidad alias for $2;
pconsolida alias for $3;

r tclasificaxbandas%rowtype;
a record;

lnocreditos numeric;
fsaldo numeric;

sdescripcionfinalidad char(30);
fporrequerido numeric;
porgarantia numeric;


begin

sdescripcionfinalidad:=pclavefinalidad;

raise notice 'finalidad %  %',pclavefinalidad,sdescripcionfinalidad;
select porcentajereserva into porgarantia from tablareserva where finalidaddefault=pclavefinalidad and diainicial=-1;


lnocreditos :=1;
fsaldo :=1;
fporrequerido:=(select porcentaje/100  from porcreserva where pfecha >= fechainicial and pfecha <= fechafinal);

if pconsolida='N' then


raise notice 'Sucursal nocreditos %  Saldo %',lnocreditos,fsaldo;

  for r in

  select t.descripcion as rango,
  count(p.precorteid) as nocreditos,
  sum(p.saldoprestamo) as saldo,
  sum(p.interesdevengadomenoravencido+p.interesdevmormenor) as intvigente,
  sum(p.depositogarantia) as garantia,
  p.factoraplicado as porrequerido,
  sum(p.reservaidnc),
  t.porcentajereserva,
  sum(p.depositogarantia)*porgarantia,
  sum(p.reservacalculada),
  (sum(p.reservaidnc)+sum(p.reservacalculada))+(sum(p.depositogarantia)*porgarantia) as totalreserva,
  ((sum(p.reservaidnc)+sum(p.reservacalculada))+(sum(p.depositogarantia)*porgarantia))*p.factoraplicado as reservarequerida,
  p.tablareservaid
  
  from precorte p, tablareserva t where p.fechacierre=pfecha and p.saldoprestamo >0 and  p.finalidaddefault = pclavefinalidad and p.tablareservaid=t.tablareservaid
  group by t.descripcion,p.tablareservaid,t.porcentajereserva,t.factordisminucion,p.factoraplicado  union

  select t.descripcion as rango,0 as nocreditos,0 as saldo,0 as intvigente,0 as garantia,fporrequerido as porrequerido,0,t.porcentajereserva,0,0,0 as totalreserva,0 as reservarequerida,t.tablareservaid
  from  tablareserva t where t.finalidaddefault = pclavefinalidad and t.tablareservaid not in (select tablareservaid from precorte where fechacierre=pfecha and finalidaddefault = pclavefinalidad  group by tablareservaid)


  loop   
    return next r;
  end loop;


else


raise notice 'Consolidado nocreditos %  Saldo %',lnocreditos,fsaldo;

 for r in

  select t.descripcion as rango,
  count(p.referenciaprestamo) as nocreditos,
  sum(p.saldoprestamo) as saldo,
  sum(p.interesdevengadomenoravencido+p.interesdevmormenor) as intvigente,
  sum(p.depositogarantia) as garantia,
  p.factoraplicado as porrequerido,
  sum(p.reservaidnc),
  t.porcentajereserva,
  sum(p.depositogarantia)*porgarantia,
  sum(p.reservacalculada),
  (sum(p.reservaidnc)+sum(p.reservacalculada))+(sum(p.depositogarantia)*porgarantia) as totalreserva,
  ((sum(p.reservaidnc)+sum(p.reservacalculada))+(sum(p.depositogarantia)*porgarantia))*p.factoraplicado as reservarequerida,
  p.tablareservaid
  from  precorteconsolidado( cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int)) p, tablareserva t where p.fechacierre=pfecha  and p.saldoprestamo >0 and  p.finalidaddefault = pclavefinalidad and p.tablareservaid=t.tablareservaid
  group by t.descripcion,p.tablareservaid,t.porcentajereserva,t.factordisminucion,p.factoraplicado
  union
  select t.descripcion as rango,0 as nocreditos,0 as saldo,0 as intvigente,0 as garantia,fporrequerido as porrequerido,0,t.porcentajereserva,0,0,0 as totalreserva,0 as reservarequerida,t.tablareservaid
  from  tablareserva t where t.finalidaddefault = pclavefinalidad and t.tablareservaid not in (select tablareservaid from precorteconsolidado( cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int)) where fechacierre=pfecha and finalidaddefault = pclavefinalidad  group by tablareservaid)

  loop   
    return next r;
  end loop;

end if;

return;

END;
$_$
    LANGUAGE plpgsql;




CREATE or replace FUNCTION clasificaxtipofinalidad(date, character, character, character) RETURNS SETOF tclasificaxbandas
    AS $_$
declare

pfecha alias for $1;
pclavefinalidad alias for $2;
ptipocartera alias for $3;
pconsolida alias for $4;

r tclasificaxbandas%rowtype;
a record;

lnocreditos numeric;
fsaldo numeric;

sdescripcionfinalidad char(30);
fporrequerido numeric;
porgarantia numeric;


begin

sdescripcionfinalidad:=pclavefinalidad;

raise notice 'finalidad %  %',pclavefinalidad,sdescripcionfinalidad;
select porcentajereserva into porgarantia from tablareserva where finalidaddefault=pclavefinalidad and diainicial=-1;


lnocreditos :=1;
fsaldo :=1;
fporrequerido:=(select porcentaje/100  from porcreserva where pfecha >= fechainicial and pfecha <= fechafinal);

if pconsolida='N' then


raise notice 'Sucursal nocreditos %  Saldo %',lnocreditos,fsaldo;

  for r in

  select t.descripcion as rango,
  count(p.precorteid) as nocreditos,
  sum(p.saldoprestamo) as saldo,
  sum(p.interesdevengadomenoravencido+p.interesdevmormenor) as intvigente,
  sum(p.depositogarantia) as garantia,
  p.factoraplicado as porrequerido,
  sum(p.reservaidnc),
  t.porcentajereserva,
  sum(p.depositogarantia)*porgarantia,
  sum(p.reservacalculada),
  (sum(p.reservaidnc)+sum(p.reservacalculada))+(sum(p.depositogarantia)*porgarantia) as totalreserva,
  ((sum(p.reservaidnc)+sum(p.reservacalculada))+(sum(p.depositogarantia)*porgarantia))*p.factoraplicado as reservarequerida,
  p.tablareservaid,t.cuentasiti
  
  from precorte p, tablareserva t where p.fechacierre=pfecha and p.saldoprestamo >0 and  p.finalidaddefault = pclavefinalidad and  p.tipocartera = ptipocartera and p.tablareservaid=t.tablareservaid
  group by t.descripcion,p.tablareservaid,t.porcentajereserva,t.factordisminucion,p.factoraplicado,t.cuentasiti  union

  select t.descripcion as rango,0 as nocreditos,0 as saldo,0 as intvigente,0 as garantia,fporrequerido as porrequerido,0,t.porcentajereserva,0,0,0 as totalreserva,0 as reservarequerida,t.tablareservaid,t.cuentasiti
  from  tablareserva t where t.finalidaddefault = pclavefinalidad and t.tipocartera = ptipocartera and t.tablareservaid not in (select tablareservaid from precorte where fechacierre=pfecha and finalidaddefault = pclavefinalidad  group by tablareservaid)

  loop   
    return next r;
  end loop;


else


raise notice 'Consolidado nocreditos %  Saldo %',lnocreditos,fsaldo;

 for r in

  select t.descripcion as rango,
  count(p.referenciaprestamo) as nocreditos,
  sum(p.saldoprestamo) as saldo,
  sum(p.interesdevengadomenoravencido+p.interesdevmormenor) as intvigente,
  sum(p.depositogarantia) as garantia,
  p.factoraplicado as porrequerido,
  sum(p.reservaidnc),
  t.porcentajereserva,
  sum(p.depositogarantia)*porgarantia,
  sum(p.reservacalculada),
  (sum(p.reservaidnc)+sum(p.reservacalculada))+(sum(p.depositogarantia)*porgarantia) as totalreserva,
  ((sum(p.reservaidnc)+sum(p.reservacalculada))+(sum(p.depositogarantia)*porgarantia))*p.factoraplicado as reservarequerida,
  p.tablareservaid,t.cuentasiti
  from  precorteconsolidado( cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int)) p, tablareserva t where p.fechacierre=pfecha  and p.saldoprestamo >0 and  p.finalidaddefault = pclavefinalidad and  p.tipocartera = ptipocartera and p.tablareservaid=t.tablareservaid
  group by t.descripcion,p.tablareservaid,t.porcentajereserva,t.factordisminucion,p.factoraplicado,t.cuentasiti
  union
  select t.descripcion as rango,0 as nocreditos,0 as saldo,0 as intvigente,0 as garantia,fporrequerido as porrequerido,0,t.porcentajereserva,0,0,0 as totalreserva,0 as reservarequerida,t.tablareservaid,t.cuentasiti
  from  tablareserva t where t.finalidaddefault = pclavefinalidad and  t.tipocartera = ptipocartera and t.tablareservaid not in (select tablareservaid from precorteconsolidado( cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int)) where fechacierre=pfecha and finalidaddefault = pclavefinalidad  group by tablareservaid)

  loop   
    return next r;
  end loop;

end if;

return;

END;
$_$
    LANGUAGE plpgsql;


drop type  tprecierre cascade;   
CREATE TYPE tprecierre AS (
	clavesocioint character(15),
	referenciaprestamo character(18),
	ejercicio integer,
	periodo integer,
	fechacierre date,
	diasvencidos integer,
	porcentajeaplicado numeric,
	factoraplicado numeric,
	saldoprestamo numeric,
	reservacalculada numeric,
	interesdevengadomenoravencido numeric,
	interesdevengadomayoravencido numeric,
	pagocapitalenperiodo numeric,
	pagointeresenperiodo numeric,
	pagomoratorioenperiodo numeric,
	bonificacionenperiodo numeric,
	bonificacionmorenperiodo numeric,
	noamorvencidas integer,
	saldovencidomernoavencido numeric,
	saldovencidomayoravencido numeric,
	fechaultamorpagada date,
	tipoprestamoid character(3),
	montoprestamo numeric,
	fecha_vencimiento date,
	tantos integer,
	depositogarantia numeric,
	tasanormal numeric,
	tasa_moratoria numeric,
	nombresocio character(82),
	calle character varying(30),
	numero_ext character varying(15),
	colonia character varying(50),
	comunidad character varying(50),
	codpostal integer,
	nombreciudadmex character varying(50),
	ultimoabono date,
	diastraspasoavencida integer,
	ultimoabonointeres date,
	numero_de_amor integer,
	fecha_otorga date,
	descripcionfinalidad character varying(30),
	diasrestantes integer,
	frecuencia numeric,
	interesdevmormenor numeric,
	interesdevmormayor numeric,
	condiciones character varying(50),
	estacion character varying(30),
	dias_cobro integer,
	pagosvencidos integer,
	finalidaddefault character(3),
	saldopromediodelmes numeric,
	interesdevengadomes numeric,
	dias_de_cobro integer,
	meses_de_cobro integer,
	primerincumplimiento date,
	reservaidnc numeric,
	tablareservaid integer,
        tipocartera char(2)
);
    

CREATE FUNCTION precorteconsolidado(integer, integer) RETURNS SETOF tprecierre
    AS $_$
declare
  pejercicio alias for $1;
  pperiodo   alias for $2;

  r tprecierre%rowtype;
  f record;
  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente='S'
 loop

        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;

        dblink2:='set search_path to public,'||f.esquema||';
            select s.clavesocioint,pr.referenciaprestamo,p.ejercicio,p.periodo,p.fechacierre,
            p.diasvencidos,p.porcentajeaplicado,p.factoraplicado,p.saldoprestamo,
            p.reservacalculada,p.interesdevengadomenoravencido,
            p.interesdevengadomayoravencido,p.pagocapitalenperiodo,
            p.pagointeresenperiodo,p.pagomoratorioenperiodo,
            p.bonificacionintenperiodo,p.bonificacionmorenperiodo,
            p.noamorvencidas,p.saldovencidomenoravencido,p.saldovencidomayoravencido,
            p.fechaultamorpagada,p.tipoprestamoid,p.montoprestamo,pr.fecha_vencimiento,
            t.tantos,p.depositogarantia,
            pr.tasanormal,pr.tasa_moratoria,
            fnombresocio(su.nombre,su.paterno,su.materno) AS nombresocio,
            d.calle,d.numero_ext,d.colonia,d.comunidad,d.codpostal,c.nombreciudadmex,
            p.ultimoabono,p.diastraspasoavencida,p.ultimoabonointeres,
            pr.numero_de_amor, pr.fecha_otorga, finalidaddefault(pr.tipoprestamoid),
            (case when p.fecha_vencimiento>p.fechacierre and
                       p.saldoprestamo>0
                  then p.fecha_vencimiento-p.fechacierre
                  else 0 end) as diasrestantes,
            round((pr.fecha_vencimiento-pr.fecha_otorga)/(pr.numero_de_amor*0.1/0.1)),
            interesdevmormenor,interesdevmormayor,
                        (case when pr.numero_de_amor > 1 then '||''''||'Pago periodico de principal e intereses '||''''||' else '||''''||'Pago Unico de principal e intereses '||''''||' end) as condicionpago,
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid not in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||','||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Normal vigente'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid not in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||','||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Normal Vencido'||''''||' else
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||') then '||''''||'Reestructurado Vigente'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||') then '||''''||'Reestructurado Vencido'||''''||' else
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Renovado Vigente'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Renovado Vencido'||''''||' end) end) end) end) end) end) as estacion,pr.dias_de_cobro,p. pagosvencidos,p.finalidaddefault,p.saldopromediodelmes,p.interesdevengadomes,p.dias_de_cobro,p.meses_de_cobro,p.primerincumplimiento,p.reservaidnc,p.tablareservaid,p.tipocartera 
      from precorte p,prestamos pr,socio s,tipoprestamo t, sujeto su,domicilio d,
           ciudadesmex c, finalidades f
     where p.ejercicio='||to_char(pejercicio,'9999')||' and p.periodo='||to_char(pperiodo,'99')||' and pr.prestamoid=p.prestamoid and
           s.socioid=pr.socioid and t.tipoprestamoid = pr.tipoprestamoid and
           su.sujetoid=s.sujetoid and d.sujetoid=s.sujetoid and
           c.ciudadmexid = d.ciudadmexid and f.clavefinalidad=p.clavefinalidad
  order by p.diasvencidos,s.clavesocioint;';

  --raise notice 'dblink % %',dblink1,dblink2;


  for r in
   select * from
    dblink(dblink1,dblink2) as 
t (
 clavesocioint      char(15),
 referenciaprestamo char(18),
 ejercicio          int4,
 periodo            int4,
 fechacierre        date,
 diasvencidos       int4,
 porcentajeaplicado numeric,
 factoraplicado     numeric,
 saldoprestamo      numeric,
 reservacalculada   numeric,
 interesdevengadomenoravencido numeric,
 interesdevengadomayoravencido numeric,
 pagocapitalenperiodo numeric,
 pagointeresenperiodo numeric,
 pagomoratorioenperiodo numeric,
 bonificacionenperiodo numeric,
 bonificacionmorenperiodo numeric,
 noamorvencidas     int4,
 saldovencidomernoavencido numeric,
 saldovencidomayoravencido numeric,
 fechaultamorpagada date,
 tipoprestamoid     char(3),
 montoprestamo      numeric,
 fecha_vencimiento  date,
 tantos             int4,
 depositogarantia   numeric,
 tasanormal         numeric,
 tasa_moratoria     numeric,
 nombresocio        char(82),
 calle              varchar(30),
 numero_ext         varchar(15),
 colonia            varchar(50),
 comunidad          varchar(50),
 codpostal          int4,
 nombreciudadmex    varchar(50),
 ultimoabono        date,
 diastraspasoavencida int4,
 ultimoabonointeres   date,
 numero_de_amor       int4,
 fecha_otorga         date,
 descripcionfinalidad varchar(30),
 diasrestantes        int4,
 frecuencia           numeric,
 interesdevmormenor   numeric,
 interesdevmormayor   numeric,
 condiciones         varchar(50),
 estacion            varchar(30),
 dias_cobro          int4,
 pagosvencidos integer,
 finalidaddefault char(3),
 saldopromediodelmes numeric,
 interesdevengadomes numeric,
 dias_de_cobro integer,
 meses_de_cobro integer,
 primerincumplimiento   date,
 reservaidnc numeric,
 tablareservaid int4,
 tipocartera char(2))

  loop
    return next r;

  end loop;

end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    


