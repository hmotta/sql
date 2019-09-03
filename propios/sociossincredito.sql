drop  type rsociossincredito cascade;

CREATE TYPE rsociossincredito AS (
		socioid numeric,
		clavesocioint character(15),
        grupo  character(25),
		nombre character varying(80),
		sucursal character(4),        
        direccion character varying(80),
        colonia character varying(50),
		comunidadmigrada character varying(50),
        ciudadsepomex  character varying(50),     
		creditospagados numeric,
		novecesmora numeric,
		promvecesmora numeric,
		totalmoratoriopagado numeric,
		fechaultimopagoprestamo date,
		montoultimoprestamo numeric,
		montomaximoprestamo numeric,
        Parte_Social_PA numeric,
        Parte_Adicional_PB numeric,
        Parte_P3 numeric,
        profesion character varying(40),
        ocupacion character varying(40),
        estado_civil character(15),
        SALDO_AHORRO numeric,
        fechaultimoahorro date,
        SALDO_PROMEDIO_inver numeric,
        fechaultimoinversion date,
		edad integer
);


CREATE or replace FUNCTION sociossincredito(date) RETURNS SETOF rsociossincredito
    AS $_$
declare

  r rsociossincredito%rowtype;
  pfechac alias for $1;

  f record;

begin

    for r in

        select
		s.socioid,
        s.clavesocioint,
        si.grupo,
        ltrim(su.nombre)||' '||ltrim(su.paterno)||' '||ltrim(su.materno),
        (select sucid from empresa where empresaid=1) as sucursal,
        d.calle||d.numero_ext as direccion,
        col.nombrecolonia,
        d.comunidad,
        cd.nombreciudadmex,
		
		0 as creditospagados,
		0 as novecesmora,
		0 as promvecesmora,
		0 as totalmoratoriopagado,
		'1990-01-01' as fechaultimopagoprestamo,
		0 as montoultimoprestamo,
		0 as montomaximoprestamo,
        sum(sd.PA) as parteadicional,
        sum(sd.PB) as partesocial,
        sum(sd.P3) as partep3,
        si.profesion,
        si.ocupacion,
        estadocivil(si.estadocivilid) as estadocivil,
        
        sum(sd.ahorro) as saldoahorro,
        (select max(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=s.socioid and mc.tipomovimientoid in
        	('AO','AC','AA','AF','AP') and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechac+1 ),
        sum(sd.plazofijo) as plazofijo, --este es el saldo_promedio_inver
		(select max(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=s.socioid and mc.tipomovimientoid ='IN' and mc.polizaid=p.polizaid and p.fechapoliza < pfechac+1 ),
		trunc((pfechac-su.fecha_nacimiento)/365) as edad

        from socio s, sujeto  su, solicitudingreso si, domicilio d, colonia col, ciudadesmex cd,-- prestamos p, --conoceatucliente ce,

        (select mc.socioid, sum(mp.debe)-sum(mp.haber) as PA,0 as PB,0 as P3, 0 as ahorro, 0 as plazofijo, 0 as prestamo, 0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='PA' and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1  group by mc.socioid  union 

        select mc.socioid,0 as PA, sum(mp.debe)-sum(mp.haber) as PB,0 as P3,0 as ahorro, 0 as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='PB' and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid union

		select mc.socioid,0 as PA,0 as PB , sum(mp.debe)-sum(mp.haber) as P3,0 as ahorro, 0 as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='P3' and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid union

        select mc.socioid,0 as PA,0 as PB,0 as P3,sum(mp.debe)-sum(mp.haber) as ahorro,0 as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid in ('AO','AC','AA','AF','AP') and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid union

        select mc.socioid,0 as PA,0 as PB,0 as P3,0 as ahorro,sum(mp.haber)-sum(mp.debe) as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mc.polizaid=mp.polizaid and (mp.cuentaid=tm.cuentadeposito or mp.cuentaid=2102010108) and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='IN' and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid) sd

        where s.fechaalta < pfechac+1 and  s.sujetoid=su.sujetoid and s.socioid=si.socioid and s.socioid=sd.socioid and d.sujetoid=su.sujetoid and d.coloniaid=col.coloniaid and col.ciudadmexid=cd.ciudadmexid and s.estatussocio <> 2 and s.tiposocioid='02' and  s.socioid not in (select socioid from prestamos  where  claveestadocredito='001')
 
        group by  s.clavesocioint,si.grupo,s.tiposocioid,si.personajuridicaid,ltrim(su.nombre)||' '||ltrim(su.paterno)||' '||ltrim(su.materno),s.fechaalta,col.coloniaid,d.calle,d.numero_ext,d.comunidad,col.nombrecolonia,cd.nombreciudadmex,si.profesion,si.ocupacion,su.fecha_nacimiento,s.socioid,si.sexo,si.estadocivilid,si.profesion order by s.clavesocioint

        loop
            select count(p.claveestadocredito) into r.creditospagados from prestamos p where p.socioid = r.socioid;
			select max(fechaultimopago) into r.fechaultimopagoprestamo from prestamos where  socioid= r.socioid;
			select montoprestamo into r.montoultimoprestamo from prestamos where  socioid= r.socioid and fechaultimopago = r.fechaultimopagoprestamo;
			select max(montoprestamo) into r.montomaximoprestamo from prestamos where  socioid= r.socioid;
			select count(refmovimiento) into r.novecesmora from movimientoscaja(r.clavesocioint,'  ') where desctipomovimiento='Int. Morat.';
			if r.creditospagados > 0 then
				r.promvecesmora = r.novecesmora / r.creditospagados ;
			end if;
			select sum(debe) into r.totalmoratoriopagado from movimientoscaja(r.clavesocioint,'  ') where desctipomovimiento='Int. Morat.';
            return next r;

        end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

