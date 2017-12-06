-- Ultima modificacion 2011-07-16 JAVS

CREATE or replace FUNCTION spioperacionlavado(integer,integer,integer,integer,integer,text) RETURNS integer
    AS $_$ 
declare 
 
  ptipooperacionid alias for $1; 
  -- Tipooperacionid:
  -- 1 => Operacion Relevante
  -- 2 => Operacion Inusual
  -- 3 => Operacion Preocupante
  -- 4 => Operacion Acumulativa Relevante

  ptiporegistro alias for $2; 
  -- Tiporegistro
  -- 0. Operacion Relevante, movicajaid>0
  -- 1. Operacion Inusual/Preocupante por movimiento, movicajaid >0
  -- 2. Operacion Inusual sin movicaja (por alerta lista negra), sujetoid >0
  -- 3. Operacion Preocupante por observación de trabajador, pobservacionid>0

  pmovicajaid alias for $3; 
  pobservacionid alias for $4; 
  psujetoid alias for $5; 
  pdesoper alias for $6; 
 
  r record; 
  psucid char(4);
  preferenciacaja  integer;
  pseriecaja       char(2);
  existereg integer;
 
  pCNBVlavadoid           char(10); 
  pORGANO_SUPERVISOR      char(6); 
  pCLAVE_DEL_SUJETO_OBLIGADO char(6);  
  pLOCALIDAD               char(8); 
  pSUCURSAL                char(8); 
  pENTIDAD_RFC             char(13); 
  pENTIDAD_CURP            char(20); 

  -- 
  isujetoid integer;
  fechai date;
  fechaf date;
  tdesoper text;
  trazonesreporte text;
  operid integer;
  
  iefectivo integer;
  itransferencia integer;
  icheque integer;
 
begin 
existereg:=0;
trazonesreporte:='';
 
  select sucid into psucid from empresa where empresaid=1;
  
  --datos movicaja
  select referenciacaja,seriecaja into preferenciacaja,pseriecaja from movicaja where movicajaid=pmovicajaid;
 
 -- datos reporte prevencion
  select cnbvlavadoid,organo_supervisor,clave_del_sujeto_obligado,localidad,clavesucursal,entidad_rfc,entidad_curp into pcnbvlavadoid,porgano_supervisor,pclave_del_sujeto_obligado,plocalidad,psucursal,pentidad_rfc,pentidad_curp from cnbvlavado where sucid=psucid;

  
  -- validando operacion relevante ya almacenada
  if ptipooperacionid = 1 then
    if (select count(*) from operacionlavado where tipo_de_reporte='1' and movicajaid=pmovicajaid)>0 then
      existereg:=1;
    end if;
  end if;

  -- validando operacion inusual ya almacenada
  if ptipooperacionid = 2 then
    if ptiporegistro=1 then 
      if (select count(*) from operacionlavado where tipo_de_reporte='2' and movicajaid=pmovicajaid)>0 then
        existereg:=1;
      end if;
    end if;
    if ptiporegistro=2 then 
      if (select count(*) from operacionlavado where tipo_de_reporte='2' and movicajaid=0 and sujetoid=psujetoid)>0 then
        existereg:=1;
      end if;
    end if;    
  end if;

  -- validando operacion preocupante ya almacenada
  if ptipooperacionid = 3 then
    if ptiporegistro=1 then 
      if (select count(*) from operacionlavado where tipo_de_reporte='3' and movicajaid=pmovicajaid)>0 then
        existereg:=1;
      end if;
    end if;
    if ptiporegistro=3 then 
      if (select count(*) from operacionlavado where tipo_de_reporte='3' and observacionpersonalid=pobservacionid)>0 then
        existereg:=1;
      end if;
    end if;    
  end if;

 -- Procesando Operacion
  if existereg=0 then

  tdesoper:=pdesoper;

  if ptiporegistro in (0,1) then 
    select fechapoliza,su.sujetoid into fechai,isujetoid from socio s, sujeto su, polizas po, movicaja mc where s.socioid=mc.socioid and su.sujetoid=s.sujetoid and mc.polizaid=po.polizaid and movicajaid=pmovicajaid;

  elsif ptiporegistro =3 then 
    select dp.fechaalta,usu.sujetoid,coalesce(texto,''),coalesce(datosoficial,'') into fechai,isujetoid,tdesoper,trazonesreporte from denunciaspersonal dp, usuarios usu where usu.usuarioid=dp.usuarioid_reportado and id=pobservacionid;
    
  else
    fechai:=current_date;
    isujetoid:=psujetoid;
  end if;
    
	--operaciones en efectivo de la sabana
	select coalesce(count(*),0) into iefectivo from sabana where seriecaja=pseriecaja and referenciacaja=preferenciacaja and denominacionid between 1 and 14;
	--operaciones en Cheque de la sabana
	--select coalesce(count(*),0) into icheque from sabana where seriecaja=pseriecaja and referenciacaja=preferenciacaja and denominacionid in (15,17);
	--operaciones en Transferencia de la sabana
	--select coalesce(count(*),0) into itransferencia from sabana where seriecaja=pseriecaja and referenciacaja=preferenciacaja and denominacionid=16;
	
        insert into operacionlavado (
	fechainicial , --1
	fechafinal , --2
	tipooperacioninicial , --3
	tipo_de_reporte , --4
	periodo_del_reporte ,--5 
	folio , --6
	organo_supervisor , --7
	clave_del_sujeto_obligado , --8
	localidad , --9
	sucursal , --10
	tipo_de_operacion , --11
	instrumento_monetario , --12
	numero_de_cuenta , --13
	monto , --14
	moneda , --15
	fecha_de_la_operacion , --16
	fecha_de_deteccion , --17
	nacionalidad , --18
	tipodepersona , --19
	razonsocial , --20
	nombre , --21
	apellido_paterno , --22
	apellido_materno , --23
	rfc , --24
	curp , --25
	fnacimientoconstitucion , --26
	domicilio , --27
	colonia , --28
	ciudadopoblacion , --29
	telefono , --30
	actividadeconomica , --31
	agenteseg_nombre , --32
	agenteseg_paterno , --33
	agenteseg_materno , --34
	entidad_rfc , --35
	entidad_curp , --36
	cta_persona_relacionada , --37
	numero_per_relacionada , --38
	clavedelsujetoobligado , --39
	personarel_nombre , --40
	personarel_paterno , --41
	personarel_materno , --42
	descripcion_operacion , --43
	razones_inusual_preopupante , --44
	reportarautoridad, --45
	movicajaid, --46
	observacionpersonalid, --47
	sujetoid, --48
	estatus
	) 
 
        (select 
  --fechainicial            date, 
   fechai, --1
  --fechafinal              date, 
   fechai, --2
  --tipooperacioninicial    char(1) 
  trim(to_char(ptipooperacionid,'9')),  --3
  --TIPO_DE_REPORTE         char(1), 
  trim(to_char(ptipooperacionid,'9')), --4
  --PERIODO_DEL_REPORTE     char(8),
  --(case when ptipooperacionid=1 then to_char(fechai,'YYYYMM') else to_char(fechai,'YYYYMMDD') end), --5
  to_char(fechai,'YYYYMM'),
  --FOLIO                   integer, 
  1, --6
  --ORGANO_SUPERVISOR       char(6), 
  pORGANO_SUPERVISOR, --7
  --CLAVE_DEL_SUJETO_OBLIGADO char(6), 
  pCLAVE_DEL_SUJETO_OBLIGADO, --8
  pLOCALIDAD, --9
  pSUCURSAL, --10
  --TIPO_DE_OPERACIoN       char(2), 01 Deposito, 02 Retiro, 08 Otorgamiento de Credito
  (case when ptipooperacionid in (1,2,3) then '01' else (case when ptipooperacionid in (4) then '02' else '09' end) end), --11
  --INSTRUMENTO_MONETARIO   char(2), 
  (case when icheque>0 and iefectivo=0 and itransferencia=0 then '02' else (case when itransferencia>0 and iefectivo=0 and icheque=0 then '03' else '01' end) end), --12
  --NUMERO_DE_CUENTA        char(16), 
  (case when ptipooperacionid=3 then '0' else (cadena2alfanum(coalesce((select clavesocioint from socio where sujetoid=su.sujetoid),''))) end), --13
  --MONTO                   numeric, 
  --(case when ptipooperacionid in (4) then (select coalesce(round(sum(valor),2),0) from sabana where referenciacaja =preferenciacaja and seriecaja=pseriecaja and entradasalida=1) else (select coalesce(round(sum(valor),2),0) from sabana where referenciacaja =preferenciacaja and seriecaja=pseriecaja and entradasalida=0) end) as monto,   --14
  (case when ptipooperacionid in (4) then (select sum(haber) from movipolizas where movipolizaid=(select movipolizaid from movicaja where movicajaid=pmovicajaid)) else (select sum(debe) from movipolizas where movipolizaid=(select movipolizaid from movicaja where movicajaid=pmovicajaid)) end) as monto,
  --MONEDA                  char(3), 
  'MNX', --15
  --FECHA_DE_LA_OPERACIoN   char(8), 
  to_char(fechai,'YYYYMMDD'), --16
  --FECHA_DE_DETECCION      char(8), 
  (case when ptiporegistro=1 then '' else to_char(fechai,'YYYYMMDD') end),   --17
  --NACIONALIDAD            char(1), 
  '1', --18
  --TIPODEPERSONA           char(1), 
  (case when ptipooperacionid=3 then '1' else (select (case when si.personajuridicaid = 1 then '2' else '1' end) as  tipodepersona from solicitudingreso si, sujeto su where su.sujetoid=si.sujetoid and su.sujetoid=isujetoid) end), --19
  --RAZONSOCIALO            char(60), 
  (select (case when si.personajuridicaid = 1 then su.razonsocial else '' end) from solicitudingreso si, sujeto su where su.sujetoid=si.sujetoid and su.sujetoid=isujetoid), --20
  --NOMBRE                  char(60), 
  su.nombre, --21
  --APELLIDO_PATERNO        char(60), 
  su.paterno, --22
  --APELLIDO_MATERNO        char(60), 
  su.materno, --23
  --RFC                     char(13), 
  substring(cadena2alfanum(su.rfc),1,13), --24
  --CURP                    char(20), 
  su.curp, --25
  --FNACIMIENTOCONSTITUCION char(8), 
   to_char(su.fecha_nacimiento,'yyyymmdd'), --26
  --DOMICILIO               char(60), 
  d.calle||' '||d.numero_ext as domicilio, --27
  --COLoNIA                 char(30), 
  coalesce(substring(c.nombrecolonia,1,30),''), --28
  --CIUDADOPOBLACION        char(8), 
  --to_char(cm.ciudadmexid,'999999'), 
  '',--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --29
  --TELEFONO                char(40), 
  d.teldomicilio, --30
  --ACTIVIDADECONOMICA      char(7), 
  coalesce((select trim(cas.clave) from 
catalogo_activ_sat cas, 
conoceatucliente ctc 
where trim(cas.clave)=trim(ctc.actividad) and ctc.conoceatuclienteid=(select max(conoceatuclienteid) from conoceatucliente where socioid=(select socioid from socio where sujetoid=isujetoid))),''), 
  --AGENTESEG_NOMBRE        char(60), 
  '', --32
  --AGENTESEG_PATERNO       char(60), 
  '', --33
  --AGENTESEG_MATERNO       char(60), 
  '', --34
--  pENTIDAD_RFC, 
  '',--35
--  pENTIDAD_CURP,   
  '',--36
  --CTA_PERSONA_RELACIONADA 
  1, --37
  --NUMERO_PER_RELACIONADA 
  '', --38
  --CLAVEDELSUJETOOBLIGADO  char(6), 
--  pCLAVE_DEL_SUJETO_OBLIGADO, 
  '', --39
  --PERSONAREL_NOMBRE       char(30), 
  '', --40
  --PERSONAREL_PATERNO      char(30), 
  '', --41
  --PERSONAREL_MATERNO      char(30), 
  '', --42
  --Descripcion_operacion   text, 
  --al.observaciones, 
  cadena2alfanum(tdesoper), --43
  --RAZONES_inusual_preopupante text, 
  trazonesreporte, --44
  --reportarautoridad       char(1) 
  'N', --45
  pmovicajaid, --46
  pobservacionid, --47
  psujetoid, --48
  (case when ptiporegistro=3 then 1 else 0 end )
 
        from 
	       sujeto su,
	       domicilio d,
	       colonia c
         where 
	       su.sujetoid=d.sujetoid and 
	       d.coloniaid=c.coloniaid and
	       su.sujetoid=isujetoid)
	 returning operacionlavadoid into operid;
   else                     
     raise notice 'Ya existe registro';
   end if;     
   operid:=coalesce(operid,0);
 
return operid; 
end 
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
