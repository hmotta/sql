drop function spiingresosterceros(character varying,character varying,character varying,character varying,character varying,numeric,character varying,character varying,character,date,integer,integer); 
CREATE FUNCTION spiingresosterceros(character varying,character varying,character varying,character varying,character varying,numeric,character varying,character varying,character,date,integer,integer) RETURNS integer
AS $_$
	declare
		pmotivo alias for $1;
		pactividadotorgante alias for $2;
		pantiguedad alias for $3;
		pnombreotorgante alias for $4;
		prelacion alias for $5;
		pingresomensual alias for $6;
		pubicacion alias for $7;
		ptipodebien alias for $8;
		pcontratovigente alias for $9;
		pfechatermino alias for $10;
		pedadmenor alias for $11;
		pedadmayor alias for $12;
	begin

      insert into ingresosterceros (motivo,
			actividadotorgante,
			antiguedad,
			nombreotorgante,
			relacion,
			ingresomensual,
			ubicacion,
			tipodebien,	
			contratovigente,
			fechatermino,
			edadmenor,
			edadmayor
		)
        values(pmotivo,
			pactividadotorgante,
			pantiguedad,
			pnombreotorgante,
			prelacion,
			pingresomensual,
			pubicacion,
			ptipodebien,	
			pcontratovigente,
			pfechatermino,
			pedadmenor,
			pedadmayor
		);
     
     return currval('ingresosterceros_ingresoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;