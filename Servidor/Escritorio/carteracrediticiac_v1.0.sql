CREATE FUNCTION carteracrediticiac(integer, integer) RETURNS SETOF tcarteracrediticia
    AS $_$
declare
  pejercicio alias for $1;
  pperiodo   alias for $2;

  r tcarteracrediticia%rowtype;

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
            p.fechaultamorpagada,finalidaddefault(pr.tipoprestamoid),p.montoprestamo,pr.fecha_vencimiento,
            t.tantos,p.depositogarantia,
            pr.tasanormal,pr.tasa_moratoria,
            fnombresocio(su.nombre,su.paterno,su.materno) AS nombresocio,
            d.calle,d.numero_ext,d.colonia,d.comunidad,d.codpostal,c.nombreciudadmex,
            p.ultimoabono,p.diastraspasoavencida,p.ultimoabonointeres,
            pr.numero_de_amor, pr.fecha_otorga, f.descripcionfinalidad,
            (case when p.fecha_vencimiento>p.fechacierre and
                       p.saldoprestamo>0
                  then p.fecha_vencimiento-p.fechacierre
                  else 0 end) as diasrestantes,
            (case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end),
            interesdevmormenor,interesdevmormayor,
                        (case when pr.numero_de_amor > 1 then '||''''||'Pagos periodicos de principal e intereses'||''''||' else '||''''||'Pago Unico de principal e intereses '||''''||' end) as condicionpago,
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid not in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||','||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Normal'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid not in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||','||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Normal'||''''||' else
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||') then '||''''||'Reestructurado'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||') then '||''''||'Reestructurado'||''''||' else
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Renovado'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Renovado'||''''||' end) end) end) end) end) end) as estacion,(case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end),pr.prestamodescontado,
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid not in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||','||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Vigente'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid not in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||','||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Vencido'||''''||' else
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||') then '||''''||'Vigente'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'T1'||''''||','||''''||'T2'||''''||','||''''||'T3'||''''||') then '||''''||'Vencido'||''''||' else
                        (case when p.diasvencidos <= p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Vigente'||''''||' else
                        (case when p.diasvencidos > p.diastraspasoavencida and p.tipoprestamoid in ('||''''||'R1'||''''||','||''''||'R2'||''''||','||''''||'R3'||''''||') then '||''''||'Vencido'||''''||' end) end) end) end) end) end) as estacion1,pr.norenovaciones,pr.clavegarantia,pr.monto_garantia,devengadoanterior(p.prestamoid,p.fechacierre) as interesanterior,(case when  p.diasvencidos <= p.diastraspasoavencida then interesdevengadomenoravencido+interesdevmormenor else 0 end) as devengadovigente,
                        (case when  p.diasvencidos > p.diastraspasoavencida then interesdevengadomenoravencido+interesdevmormenor else 0 end) as devengadovencido,p.primerincumplimiento,pr.fecha_1er_pago,
                        su.rfc,
                        pr.fechavaluaciongarantia,
                        (select coalesce(count(avalid),0) from avales where prestamoid=p.prestamoid) as numeroavales,
                        pr.sujetoid as sujetoidrelacionado,
                        t.cuentaactivo as clasificacioncontable,(case when p.pagosvencidos = 0 then '||''''||'Sin pagos vencidos'||''''||' else (case when p.pagosvencidos = 1 then '||''''||'Con pagos vencidos'||''''||' else '||''''||'Cobranza administrativa'||''''||' end) end),(case when si.personajuridicaid = 0 then '||''''||'FISICA'||''''||' else  '||''''||'MORAL'||''''||' end),p.reservaidnc,p.diascapital,p.diasinteres,pr.tipoprestamoid,pr.calculonormalid,
(select  ffinalidad(fl.finalidad,fl.subfinalidad1,fl.subfinalidad2) AS desfinalidad   from finalidad fl,solicitudprestamo sp  where fl.solicitudprestamoid=sp.solicitudprestamoid and pr.solicitudprestamoid=sp.solicitudprestamoid)

      from precorte p,prestamos pr,socio s,tipoprestamo t, sujeto su, solicitudingreso si, domicilio d,
           ciudadesmex c, finalidades f
     where p.ejercicio='||pejercicio||' and p.periodo='||pperiodo||' and pr.prestamoid=p.prestamoid and
           s.socioid=pr.socioid and t.tipoprestamoid = pr.tipoprestamoid and
           su.sujetoid=s.sujetoid and s.socioid=si.socioid and d.sujetoid=s.sujetoid and
           c.ciudadmexid = d.ciudadmexid and f.clavefinalidad=p.clavefinalidad 
  order by p.diasvencidos,s.clavesocioint;';

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
 desctipoprestamo   char(30),
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
 prestamodescontado  char(2),
 estacion1            varchar(30),
 norenovaciones       int4,
 clavegarantia        char(3),
 monto_garantia        numeric,
 interesanterior      numeric,
 devengadovigente     numeric,
 devengadovencido     numeric,
 primerincumplimiento date,
 fecha_1er_pago date, rfc    character(16),
 fechavaluaciongarantia date,
 numeroavales   integer,
 sujetoidrelacionado integer,
 clasificacioncontable varchar(24),
 tipocobranza varchar(50),
 personajuridica varchar(10),reservaidnc numeric,
 diascapital integer,
 diasinteres integer,
 tipoprestamoid character(3),
 calculonormalid integer,
 desfinalidad character(120))

  loop

    return next r;

  end loop;


end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


--ALTER FUNCTION public.carteracrediticiac(integer, integer) OWNER TO sistema;
