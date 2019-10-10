CREATE OR REPLACE FUNCTION solicitudesdiarias(date, date)
  RETURNS SETOF tsolicitudesdiarias AS $BODY$
declare
  pfechacierre alias for $1;
  pfechacierre2 alias for $2;
r tsolicitudesdiarias%rowtype;

 rconyuge integer;
  rnombreconyuge  character varying(120);
 rnoaval1 integer;
 rnoaval2 integer;
 rnoaval3 integer;
 rnoaval4 integer;
 rsocioaval1  character varying(20);
 rsocioaval2  character varying(20);
 rsocioaval3  character varying(20);
 rsocioaval4  character varying(20);
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
su.edad,
su.fecha_nacimiento,
		 sl.solicitudprestamoid,

               	 sl.socioid,
		 sl.sujetoid,
		 su.rfc,
		 su.curp,
		 d.ciudadmexid,
		 d.teldomicilio,
		  d.calle||' '||d.numero_ext||' '||d.colonia||' '||d.comunidad as domicilio,
		 (case when si.nivelestudiosid=0 then 'Ninguno' else (case when si.nivelestudiosid=1 then 'Primaria' else (case when si.nivelestudiosid=2 then 'Secundaria' 
	else (case when si.nivelestudiosid=3 then 'Preparatoria' else (case when si.nivelestudiosid=4 then 'Licenciatura'   else (case when si.nivelestudiosid=5 then 'Maestria' else 'doctorado' end)
	end)end)end) end ) end) as escolaridad,
	(case when si.estadocivilid=0 then 'Soltero(a)' else (case when si.estadocivilid=1 then 'Casado(a)' 
    else (case when si.estadocivilid=2 then 'Divorciado(a)' else (case when si.estadocivilid=3 then 'Viudo(a)' else 'Union Libre' end) end) end ) end) as estadocivil,
 '' as garantia,
		 t.desctipoprestamo,
		 sl.tipoprestamoid,
		 ( select f.descripcionfinalidad from cat_finalidad_contable f where f.clavefinalidad=sl.clavefinalidad limit 1),
		 sl.clavegarantia,
		 d.domicilioid,
		 sl.nosolicitud,
		 sl.fechasolicitud,
		 (select ic.salariomensual from ingresoegresoconceatucliente ic where ic.solicitudingresoid=si.solicitudingresoid limit 1) as salariomensual,
		 (select cc.ingresomensual from conyugeconceatucliente cc where cc.solicitudingresoid=si.solicitudingresoid limit 1) as ingresomensual,
		 '' as conyuge,
		 (select ic.otrosingresos from ingresoegresoconceatucliente ic where ic.solicitudingresoid=si.solicitudingresoid limit 1) as otrosingresos,
		 (select ic.ingresototal from ingresoegresoconceatucliente ic where ic.solicitudingresoid=si.solicitudingresoid limit 1) as ingresototal,
		 '0',
		 '0',
		 '0',
		 (select ic.egresomensual from ingresoegresoconceatucliente ic where ic.solicitudingresoid=si.solicitudingresoid limit 1) as egresomensual,
		 sl.capacidadpago,
		 (select valormuebles from conoceatucliente c where c.socioid=s.socioid) as valormuebles,
		 '0',
		 sl.abonospropuestos,
		 sl.montosolicitado, 
		 sl.periodopagoid, 
		 sl.tasanormal,
		 sl.tasamoratorio,
		 (select fechadictaminacion from dictaminacredito dc where dc.solicitudprestamoid=sl.solicitudprestamoid limit 1) as fechadictaminacion,
		 sl.fechaentrega,
		 (select dc.actano from dictaminacredito dc where dc.solicitudprestamoid=sl.solicitudprestamoid limit 1) as actano,
		 '0',
		 '0',
		 '0',
		 sl.usuarioid,
		 '',
		 sl.lastupdate,
		 sl.primerpago,
		 (select trc.empresatrabajo from trabajoconceatucliente trc where trc.solicitudingresoid=si.solicitudingresoid limit 1) as empresatrabajo,
		 (select trc.nombrejefe from trabajoconceatucliente trc where trc.solicitudingresoid=si.solicitudingresoid limit 1) as nombrejefe,
		 '0',
		 (select vi.observaciones from viviendainvestigacion vi where vi.solicitudprestamoid=sl.solicitudprestamoid  limit 1) as observaciones,
		 (select dc.observaciones from dictaminacredito dc where dc.solicitudprestamoid=sl.solicitudprestamoid limit 1) as observaciones,
		 '0',
		 '0',
		 '0',
		 '0',
		 '0',
		 sl.dias_de_cobro,
		 sl.meses_de_cobro,
		 sl.dia_mes_cobro,
		 sl.estatus,
		 '0',
		 (select datc.tiemporesidencia from datosingresoconceatucliente datc where datc.solicitudingresoid=si.solicitudingresoid limit 1) as tiemporesidencia,
		 (select trc.tiempolaborando from trabajoconceatucliente trc where trc.solicitudingresoid=si.solicitudingresoid limit 1) as tiempolaborando,
		 (select dependienteseconomicos from conoceatucliente c where c.socioid=s.socioid) as dependienteseconomicos,
		 sl.consultaburoid,
		 sl.grupo,
		 '0',
		 '0',
		 '0',
		 '0',
		 '0',
		 '0',
		 '0',
		 (select dc.montoautorizado from dictaminacredito dc where dc.solicitudprestamoid=sl.solicitudprestamoid limit 1) as montoautorizado,
		 '0',
		 '0',
		 '0',
		 '0',
		 '0',
		 '0',
		 '0',
		 si.solicitudingresoid,
		 saldomov(s.socioid,'PA',pfechacierre) as PA,
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

		from solicitudprestamo sl,socio s, sujeto su, tipoprestamo t, domicilio d, solicitudingreso si    
		 where (sl.fechasolicitud >= pfechacierre and sl.fechasolicitud <= pfechacierre2)and sl.socioid=s.socioid and su.sujetoid=s.sujetoid and sl.tipoprestamoid=t.tipoprestamoid and  d.sujetoid=su.sujetoid and si.sujetoid=su.sujetoid  
		loop 
         select  conyugeid into rconyuge from solicitudingreso where  solicitudingresoid=r.solicitudingresoid;
		 select nombre||' '||paterno||' '||materno into rnombreconyuge from sujeto where sujetoid=rconyuge;
		 r.conyuge:=rnombreconyuge;
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

		
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;