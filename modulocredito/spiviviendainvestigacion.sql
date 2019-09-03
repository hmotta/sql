drop FUNCTION spiviviendainvestigacion(integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,character varying,character varying,date,text);
CREATE FUNCTION spiviviendainvestigacion(integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,character varying,character varying,date,text) RETURNS integer
AS $_$
	declare
		psolicitudprestamoid alias for $1;
		psujetoid alias for $2;
		paguapotable alias for $3;
		pelectricidad alias for $4;
		ptelefono alias for $5;
		pdrenaje alias for $6;
		ptvcable alias for $7;
		pintenet alias for $8;
		ptipovivienda alias for $9;
		pfamilia alias for $10;
		pamigos alias for $11;
		pparientes alias for $12;
		potros alias for $13;
		pnumpersonas alias for $14;
		psala alias for $15;
		pcocina alias for $16;
		pcomedor alias for $17;
		pcochera alias for $18;
		pbano alias for $19;
		pnumrecamaras alias for $20;
		ptipoparedes alias for $21;
		ptipopiso alias for $22;
		ptipotecho alias for $23;
		pestereo alias for $24;
		pestufa alias for $25;
		pcomputadora alias for $26;
		ptelevisor alias for $27;
		plavadora alias for $28;
		prefrigerador alias for $29;
		ptipopropiedad alias for $30;
		pclavecatrastal alias for $31;
		pinscripcion alias for $32;
		pfechainscripcion alias for $33;
		pobservaciones alias for $34;
	begin
      insert into viviendainvestigacion (solicitudprestamoid,
				sujetoid,
				aguapotable,
				electricidad,
				telefono,
				drenaje,
				tvcable,
				intenet,
				tipovivienda,
				familia,
				amigos,
				parientes,
				otros,
				numpersonas,
				sala,
				cocina,
				comedor,
				cochera,
				bano,
				numrecamaras,
				tipoparedes,
				tipopiso,
				tipotecho,
				estereo,
				estufa,
				computadora,
				televisor,
				lavadora,
				refrigerador,
				tipopropiedad,
				clavecatrastal,
				inscripcion,
				fechainscripcion,
				observaciones
		)
        values(psolicitudprestamoid,
					psujetoid,
					paguapotable,
					pelectricidad,
					ptelefono,
					pdrenaje,
					ptvcable,
					pintenet,
					ptipovivienda,
					pfamilia,
					pamigos,
					pparientes,
					potros,
					pnumpersonas,
					psala,
					pcocina,
					pcomedor,
					pcochera,
					pbano,
					pnumrecamaras,
					ptipoparedes,
					ptipopiso,
					ptipotecho,
					pestereo,
					pestufa,
					pcomputadora,
					ptelevisor,
					plavadora,
					prefrigerador,
					ptipopropiedad,
					pclavecatrastal,
					pinscripcion,
					pfechainscripcion,
					pobservaciones
		);
     
     return currval('viviendainvestigacion_viviendaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

