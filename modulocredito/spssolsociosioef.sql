
--funcion para reportear 
drop type rsolprestamosioef cascade;
CREATE TYPE rsolprestamosioef AS (
	
        x1  character(14),
	x2 numeric,
	x3 character varying(130),
	x4 character varying(150),
	x5 character varying(100),
	x6 character varying(6),
	x7 character varying(15),
	x8 text,
	x9 text,
	x10 text,
	x11 text,
	x12 text,
	x13 text,
	x14  text,
	x15  text,
	x16  text,
	x17  text,
	x18  text,
	x19  text,
	x20  text,
	x21  text,
	x22  text,
	x23  text,
	x24  text,
	x25  text,
	x26  text,
	x27  text,
	x28 numeric,
	x29  text,
	x30  text,
	x31  text,
	x32  text,
	x33  text,
	x34  text,
	x35 numeric,
	x36  text,
	x37  text,
	x38  text,
	x39  text,
	x40  text,
	x41  text,
	x42  text,
	x43  text,
	x44 numeric	
);


CREATE OR REPLACE FUNCTION spssolsociosioef(integer) RETURNS SETOF rsolprestamosioef
AS $_$
declare
	r rsolprestamosioef%rowtype;
	nosolicitud alias for $1;
  	
begin
	    for r in
			select s.clavesocioint,sp.socioid, su.nombre||' '||su.paterno||' '||su.materno as nombre,
	d.calle||' '||d.numero_ext||' COL.  '||c.nombrecolonia as domicilio,
	cd.nombreciudadmex||' , '||e.nombreestadomex as ciudad,d.codpostal, d.teldomicilio,
	su.rfc,su.curp, sexo(si.sexo),nivelestudios(si.nivelestudiosid),estadocivil(si.estadocivilid),
	regimen(si.regimenmatrimonial),tipocasa(si.tipocasaid)as vivienda,
	si.tiempovivirendomicilio as antiguedad,to_char(sp.totalingresos,'9,999,999.99'),to_char(sp.totalegresos,'9,999,999.99'),
	to_char(saldomov(s.socioid,'AA',current_date), '9,999,999.99')as ahorro,
	to_char(saldomov(s.socioid,'00',current_date), '9,999,999.99') as creditos,
	to_char(saldomov(s.socioid,'PA',current_date), '9,999,999.99') as partesocial,
	to_char(saldomov(s.socioid,'IN',current_date), '99,99,999.99') as plazofijo,
	to_char(saldomov(s.socioid,'P3',current_date), '9,999,999.99') as corriente,
	tp.desctipoprestamo, f.descripcionfinalidad,
	to_char(sp.montosolicitado,'9,999,999.99')as monto, tg.descripciongarantia as tiporespaldo,
	sp.abonospropuestos,sp.periodopagoid,sp.primerpago,
	sp.tipoprestamoid, sp.fecharesultado,cast((substring((sp.primerpago),9)) as int)as diaprimerpago,
	si.ocupacion, substring((sp.obsinvestigacion),1,60), ((current_date-su.fecha_nacimiento)/365) as edad,
	to_char(sp.valorpropiedades, '999,999,999.99'), to_char(sp.otrosgastos, '9,999,999.99'), fechaletra(s.fechaalta), sp.fecharesultado,            	  sp.actano,to_char(sp.tasanormal,'999999.99')as 			tasanormal,to_char(sp.tasamoratorio,'999999.99') as tasamora,sp.dependienteseconomicos,(case when si.conyugeid>0 then to_char(si.conyugeid,'99999999') else '0' end )
	from socio s , sujeto su, domicilio d, colonia c, ciudadesmex cd, estadosmex e,
	solicitudingreso si, solicitudprestamo sp, tipoprestamo tp, finalidades f, tipo_garantia tg
	where s.sujetoid = su.sujetoid and
	su.sujetoid = d.sujetoid and
	d.ciudadmexid = cd.ciudadmexid and
	d.coloniaid = c.coloniaid and
	cd.estadomexid = e.estadomexid and 
	s.socioid = si.socioid and
	s.socioid = sp.socioid and
	sp.tipoprestamoid = tp.tipoprestamoid and
	sp.clavefinalidad = f.clavefinalidad and
	sp.clavegarantia = tg.clavegarantia and
	sp.nosolicitud = nosolicitud
	    loop
			
      		return next r;
    	    end loop;
return;
end
$_$
    LANGUAGE plpgsql;

--

