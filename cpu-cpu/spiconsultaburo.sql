drop FUNCTION spiconsultaburo(character,character,character,character varying,character varying,character varying,character varying,date,character varying,char,char,character varying,character,character varying,character varying,character varying,character varying,character varying,character,date,character varying,char,date,time,character,text);

CREATE or replace FUNCTION spiconsultaburo(character,character,character,character,character varying,character varying,character varying,character varying,date,character varying,char,char,character varying,character,character varying,character 
varying,character varying,character varying,character varying,character,date,character varying,char,date,time,character,text) RETURNS integer
    AS $_$
declare
	pnumerodecontrol alias for $1;
	pproducto alias for $2;
	presponsabilidad alias for $3;
	pcontrato alias for $4;
	ppaterno alias for $5;
	pmaterno alias for $6;
	pprimer_nombre alias for $7;
	psegundo_nombre alias for $8;
	pfecha_nacimiento alias for $9;
	prfc alias for $10;
	pedo_civil alias for $11;
	pgenero alias for $12;
	pno_ife alias for $13;
	pcurp alias for $14;
	pdireccion1 alias for $15;
	pdireccion2 alias for $16;
	pcolonia alias for $17;
	pciudad alias for $18;
	pestado alias for $19;
	pcp alias for $20;
	pfecha_residencia alias for $21;
	ptelefono alias for $22;
	ptipo_domicilio alias for $23;
	pfecha alias for $24;
	phora alias for $25;
	pusuarioid alias for $26;
	pcadena alias for $27;

begin
   insert into consultaburo (numerodecontrol,producto,responsabilidad,contrato,paterno,materno,primer_nombre,segundo_nombre,fecha_nacimiento,rfc,edo_civil,genero,no_ife,curp,direccion1,direccion2,colonia,ciudad,estado,cp,fecha_residencia,telefono,tipo_domicilio,fecha,hora,usuarioid,cadena) values (pnumerodecontrol,pproducto,presponsabilidad,pcontrato,ppaterno,pmaterno,pprimer_nombre,psegundo_nombre,pfecha_nacimiento,prfc,pedo_civil,pgenero,pno_ife,pcurp,pdireccion1,pdireccion2,pcolonia,pciudad,pestado,pcp,pfecha_residencia,ptelefono,ptipo_domicilio,pfecha,phora,pusuarioid,pcadena);

return currval('consultaburo_consultaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;