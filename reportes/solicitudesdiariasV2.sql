--
-- Name: tanalisiscartera; Type: TYPE; Schema: public; Owner: sistema
--
drop TYPE tsolicitudesdiarias cascade;
CREATE TYPE tsolicitudesdiarias AS (
	 sucursal character(4),
         clavesocioint           character(12),
	 paterno  		character varying(30),
	 materno		character varying(30),
	 nombre			text,
	 solicitudprestamoid    integer,
         garantia               character varying(15),
	 socioid                integer,
	 sujetoid                integer,
	 tipoprestamoid         character(3),
	 clavefinalidad         character(3),
	 clavegarantia           character(3),
	 domicilioid             integer,
	 nosolicitud             integer,
	 fechasolicitud          date ,
	 sueldo                  numeric,
	 sueldoconyuge           numeric,
	 otrosingresos           numeric,
	 totalingresos           numeric,
	 gastosordinarios       numeric,
	 otrosgastos             numeric,
	 otrosabonos             numeric,
	 totalegresos            numeric,
	 capacidadpago           numeric, 
	 valorpropiedades        numeric,
	 totaldeudas             numeric,
	 abonospropuestos        integer,
	 montosolicitado         numeric, 
	 periodopagoid           integer, 
	 tasanormal              numeric,
	 tasamoratorio           numeric,
	 fecharesultado          date,
	 fechaentrega            date,
	 actano                  character varying(30),
	 fechacomite             date,
	 resolucionid            integer,
	 entregado               integer,
	 usuarioid               character(20),
	 lastusuarioid           character(20),
	 lastupdate              date,
	 primerpago              date,
	 empresatrabaja          character varying(80),
	 jefedirecto             character varying(50),
	 verificado              integer ,
	 obsinvestigacion        text,
	 observaciones           text,
	 presidente              character varying(50),
	 vicepresidente          character varying(50),
	 oficialcredito          character varying(50),
	 analistacredito         character varying(50),
	 secretario              character varying(50),
	 dias_de_cobro           integer,
	 meses_de_cobro          integer,
	 dia_mes_cobro           integer,
	 estatus                 integer,
	 obsingresos             text,
	 tiempoendomicilio       integer,
	 tiempoentrabajo         integer,
	 dependienteseconomicos  integer,
	 calificacionburo        integer,
	 grupo                   character(25),
	 contratogrupo           integer,
	 folioprocampo           character(20),
	 nohectareas             numeric,
	 credxhec                numeric,
	 comxhec                 numeric,
	 comxch                  numeric,
	 interes                 numeric, 
	 montoentregado          numeric,
	 comasesor               numeric, 
	 montoprocampo           numeric,
	 diadecorte              integer,
	 porcentajepagominimo    numeric, 
	 diadepago               integer,
	 gastoscobranza          numeric,
	 limitedecredito         numeric,
	 socioaval1 character varying(12),
	 nombreaval1 character varying(120),
	 direccionaval1 character varying(200),
	 porcentajeavalado1 numeric,
	 socioaval2  character varying(12),
	 nombreaval2 character varying(120),
	 direccionaval2 character varying(200),
	 porcentajeavalado2 numeric,
	 socioaval3  character varying(12),
	 nombreaval3 character varying(120),
	 direccionaval3 character varying(200),
	 porcentajeavalado3 numeric,
	 socioaval4  character varying(12),
	 nombreaval4 character varying(120),
	 direccionaval4 character varying(200),
	 porcentajeavalado4 numeric
);

CREATE or replace FUNCTION solicitudesdiarias(date) RETURNS SETOF tsolicitudesdiarias
    AS $_$
declare
  pfechacierre alias for $1;
r tsolicitudesdiarias%rowtype;

 rnoaval1 integer;
 rnoaval2 integer;
 rnoaval3 integer;
 rnoaval4 integer;
 rsocioaval1  character varying(12);
 rsocioaval2  character varying(12);
 rsocioaval3  character varying(12);
 rsocioaval4  character varying(12);
 rnombreaval1  character varying(120);
 rnombreaval2  character varying(120);
 rnombreaval3  character varying(120);
 rnombreaval4  character varying(120);
 rdiraval1  character varying(200);
 rdiraval2  character varying(200);
 rdiraval3  character varying(200);
 rdiraval4  character varying(200);
 rpor1 numeric; 
 rpor2 numeric; 
 rpor3 numeric; 
 rpor4 numeric; 

begin
	 for r in
			select 
	         substring(s.clavesocioint,1,4),
		 RTrim(s.clavesocioint),
		 su.paterno,
		 su.materno,
		 su.nombre,
	         sl.solicitudprestamoid,
                '' as garantia,
		 sl.socioid,
		 sl.sujetoid,
		 sl.tipoprestamoid,
		 sl.clavefinalidad,
		 sl.clavegarantia,
		 sl.domicilioid,
		 sl.nosolicitud,
		 sl.fechasolicitud,
		 sl.sueldo,
		 sl.sueldoconyuge,
		 sl.otrosingresos,
		 sl.totalingresos,
		 sl.gastosordinarios,
		 sl.otrosgastos,
		 sl.otrosabonos,
		 sl.totalegresos,
		 sl.capacidadpago,
		 sl.valorpropiedades,
		 sl.totaldeudas,
		 sl.abonospropuestos,
		 sl.montosolicitado, 
		 sl.periodopagoid, 
		 sl.tasanormal,
		 sl.tasamoratorio,
		 sl.fecharesultado,
		 sl.fechaentrega,
		 sl.actano,
		 sl.fechacomite,
		 sl.resolucionid,
		 sl.entregado,
		 sl.usuarioid,
		 sl.lastusuarioid,
		 sl.lastupdate,
		 sl.primerpago,
		 sl.empresatrabaja,
		 sl.jefedirecto,
		 sl.verificado,
		 sl.obsinvestigacion,
		 sl.observaciones,
		 sl.presidente,
		 sl.vicepresidente,
		 sl.oficialcredito,
		 sl.analistacredito,
		 sl.secretario,
		 sl.dias_de_cobro,
		 sl.meses_de_cobro,
		 sl.dia_mes_cobro,
		 sl.estatus,
		 sl.obsingresos,
		 sl.tiempoendomicilio,
		 sl.tiempoentrabajo,
		 sl.dependienteseconomicos,
		 sl.calificacionburo,
		 sl.grupo,
		 sl.contratogrupo,
		 sl.folioprocampo,
		 sl.nohectareas,
		 sl.credxhec,
		 sl.comxhec,
		 sl.comxch,
		 sl.interes, 
		 sl.montoentregado,
		 sl.comasesor,
		 sl.montoprocampo,
		 sl.diadecorte,
		 sl.porcentajepagominimo,
		 sl.diadepago,
		 sl.gastoscobranza,
		 sl.limitedecredito,
		0 as socioaval1,
		'' as nombreaval1,
		'' as direccionaval1,
		0,
		0 as socioaval1,
		'' as nombreaval2,
		'' as direccionaval2,
		0,
		0 as socioaval1,
		'' as nombreaval3,
		'' as direccionaval3,
		0,
		0 as socioaval1,
		'' as nombreaval4,
		'' as direccionaval4,
		0

		from solicitudprestamo sl,socio s, sujeto su
		 where sl.fechasolicitud = pfechacierre and sl.socioid=s.socioid and su.sujetoid=s.sujetoid
		loop 

		   ---dias mora cierre actual-----
		select  sujetoid into rnoaval1 from avales where noaval=1 and solicitudprestamoid=r.solicitudprestamoid;
		select porcentajeavala into rpor1 from avales where sujetoid=rnoaval1;
		select clavesocioint into rsocioaval1 from socio where sujetoid=rnoaval1;
		select nombre||' '||paterno||' '||materno into rnombreaval1 from sujeto where sujetoid=rnoaval1;
		select calle||' '||numero_ext||' '||comunidad ||' Tel. '||teldomicilio into rdiraval1 from domicilio where sujetoid=rnoaval1;
	 		r.socioaval1:=rsocioaval1;
			r.nombreaval1:=rnombreaval1;
			r.direccionaval1:=rdiraval1;
			r.porcentajeavalado1=rpor1;
		select  sujetoid into rnoaval2 from avales where noaval=2 and solicitudprestamoid=r.solicitudprestamoid;
		select porcentajeavala into rpor2 from avales where sujetoid=rnoaval2;
		select clavesocioint into rsocioaval2 from socio where sujetoid=rnoaval2;
		select nombre||' '||paterno||' '||materno into rnombreaval2 from sujeto where sujetoid=rnoaval2;
		select calle||' '||numero_ext||' '||comunidad ||' Tel. '||teldomicilio into rdiraval2 from domicilio where sujetoid=rnoaval2;
	 		r.socioaval2:=rsocioaval2;
			r.nombreaval2:=rnombreaval2;
			r.direccionaval2:=rdiraval2;
			r.porcentajeavalado2=rpor2;
		select  sujetoid into rnoaval3 from avales where noaval=3 and solicitudprestamoid=r.solicitudprestamoid;
		select porcentajeavala into rpor3 from avales where sujetoid=rnoaval3;
		select clavesocioint into rsocioaval3 from socio where sujetoid=rnoaval3;
		select nombre||' '||paterno||' '||materno into rnombreaval3 from sujeto where sujetoid=rnoaval3;
		select calle||' '||numero_ext||' '||comunidad ||' Tel. '||teldomicilio into rdiraval3 from domicilio where sujetoid=rnoaval3;
	 		r.socioaval3:=rsocioaval3;
			r.nombreaval3:=rnombreaval3;
			r.direccionaval3:=rdiraval3;
			r.porcentajeavalado3=rpor3;
		select  sujetoid into rnoaval4 from avales where noaval=4 and solicitudprestamoid=r.solicitudprestamoid;
		select porcentajeavala into rpor4 from avales where sujetoid=rnoaval4;
		select clavesocioint into rsocioaval4 from socio where sujetoid=rnoaval4;
		select nombre||' '||paterno||' '||materno into rnombreaval4 from sujeto where sujetoid=rnoaval4;
		select calle||' '||numero_ext||' '||comunidad ||' Tel. '||teldomicilio into rdiraval4 from domicilio where sujetoid=rnoaval4;
	 		r.socioaval4:=rsocioaval4;
			r.nombreaval4:=rnombreaval4;
			r.direccionaval4:=rdiraval4;
			r.porcentajeavalado4=rpor4;
		IF r.clavegarantia ='01' then
                   r.garantia:='GARANTIA';
		END IF;
		IF r.clavegarantia ='02' then
                   r.garantia:='AHORRO';
		END IF;
		IF r.clavegarantia ='03' then
                   r.garantia:='AVALES';
		END IF;
		IF r.clavegarantia ='04' then
                  r.garantia:='HIPOTECA';
		END IF;
		IF r.clavegarantia ='05' then
                   r.garantia:='DEPOSITO';
		END IF;
		IF r.clavegarantia ='06' then
                   r.garantia:='AVAL';
		END IF;
		IF r.clavegarantia ='07' then
                   r.garantia:='INVERSION';
		END IF;
		IF r.clavegarantia ='08' then
                   r.garantia:='RECIPROCIDAD';
		END IF;
		
		  
		  
		return next r;

		end loop;
return;
end

		
$_$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE or replace FUNCTION solicitudesdiariasc(date) RETURNS SETOF tsolicitudesdiarias
AS $_$
declare
	
	pfecha alias for $1;
	r tsolicitudesdiarias%rowtype;
  		f record;
  	dblink1 text;
  	dblink2 text;
begin
for f in
		select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
		dblink2:='set search_path to public,'||f.esquema||';select * from  solicitudesdiarias('||''''||pfecha||''''||');';
        

        for r in
           select * from
           dblink(dblink1,dblink2) as
           t2(
        sucursal character(4),
         clavesocioint           character(12),
	 paterno  		character varying(30),
	 materno		character varying(30),
	 nombre			text,
	 solicitudprestamoid    integer,
         garantia               character varying(15),
	 socioid                integer,
	 sujetoid                integer,
	 tipoprestamoid         character(3),
	 clavefinalidad         character(3),
	 clavegarantia           character(3),
	 domicilioid             integer,
	 nosolicitud             integer,
	 fechasolicitud          date ,
	 sueldo                  numeric,
	 sueldoconyuge           numeric,
	 otrosingresos           numeric,
	 totalingresos           numeric,
	 gastosordinarios       numeric,
	 otrosgastos             numeric,
	 otrosabonos             numeric,
	 totalegresos            numeric,
	 capacidadpago           numeric, 
	 valorpropiedades        numeric,
	 totaldeudas             numeric,
	 abonospropuestos        integer,
	 montosolicitado         numeric, 
	 periodopagoid           integer, 
	 tasanormal              numeric,
	 tasamoratorio           numeric,
	 fecharesultado          date,
	 fechaentrega            date,
	 actano                  character varying(30),
	 fechacomite             date,
	 resolucionid            integer,
	 entregado               integer,
	 usuarioid               character(20),
	 lastusuarioid           character(20),
	 lastupdate              date,
	 primerpago              date,
	 empresatrabaja          character varying(80),
	 jefedirecto             character varying(50),
	 verificado              integer ,
	 obsinvestigacion        text,
	 observaciones           text,
	 presidente              character varying(50),
	 vicepresidente          character varying(50),
	 oficialcredito          character varying(50),
	 analistacredito         character varying(50),
	 secretario              character varying(50),
	 dias_de_cobro           integer,
	 meses_de_cobro          integer,
	 dia_mes_cobro           integer,
	 estatus                 integer,
	 obsingresos             text,
	 tiempoendomicilio       integer,
	 tiempoentrabajo         integer,
	 dependienteseconomicos  integer,
	 calificacionburo        integer,
	 grupo                   character(25),
	 contratogrupo           integer,
	 folioprocampo           character(20),
	 nohectareas             numeric,
	 credxhec                numeric,
	 comxhec                 numeric,
	 comxch                  numeric,
	 interes                 numeric, 
	 montoentregado          numeric,
	 comasesor               numeric, 
	 montoprocampo           numeric,
	 diadecorte              integer,
	 porcentajepagominimo    numeric, 
	 diadepago               integer,
	 gastoscobranza          numeric,
	 limitedecredito         numeric,
	 socioaval1 character varying(12),
	 nombreaval1 character varying(120),
	 direccionaval1 character varying(200),
	 porcentajeavalado1 numeric,
	 socioaval2  character varying(12),
	 nombreaval2 character varying(120),
	 direccionaval2 character varying(200),
	 porcentajeavalado2 numeric,
	 socioaval3  character varying(12),
	 nombreaval3 character varying(120),
	 direccionaval3 character varying(200),
	 porcentajeavalado3 numeric,
	 socioaval4  character varying(12),
	 nombreaval4 character varying(120),
	 direccionaval4 character varying(200),
	 porcentajeavalado4 numeric
	)
	

        loop
              return next r;
        end loop;

end loop;
return;
end
$_$
    LANGUAGE plpgsql;
