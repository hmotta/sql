CREATE FUNCTION spiingresosactividad(character varying,character varying,character varying,numeric,numeric,numeric,integer) RETURNS integer
AS $_$
	declare
		pactividad alias for $1;
		pperiodicidad alias for $2;
		pantiguedad alias for $3;
		pventasmensual alias for $4;
		pcostosmensual alias for $5;
		premanentemensual alias for $6;
		pdomicilioid alias for $7;
	begin

      insert into ingresosactividad (actividad,
		periodicidad,
		antiguedad,
		ventasmensual,
		costosmensual,
		remanentemensual,
		domicilioid
		)
        values(pactividad,
		pperiodicidad,
		pantiguedad,
		pventasmensual,
		pcostosmensual,
		premanentemensual,
		pdomicilioid
		);
     
     return currval('ingresosactividad_ingresoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;