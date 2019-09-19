drop TYPE ramortizaciones cascade;
CREATE TYPE ramortizaciones AS (
  amortizacionid int4,
  numamortizacion numeric,
  fechapago date,
  importeamortizacion numeric,
  interesnormal numeric,
  interesmoratorio numeric,
  iva numeric,
  totalpago numeric,
  estatus varchar(25),
  dias_mora_capital integer,
  fechapagoreal date,
  abonopagado numeric,
  interespagado numeric,
  cobranza numeric,
  cobranzapagado numeric
);

CREATE OR REPLACE FUNCTION spsamortizaciones(int4)
  RETURNS SETOF ramortizaciones AS $BODY$
declare
  r ramortizaciones%rowtype;
  pprestamoid alias for $1;
begin

   for r in
		SELECT
			amortizacionid,
			numamortizacion,
			fechadepago,
			importeamortizacion,
			interesnormal,
			0,
			iva,
			totalpago,
			(CASE WHEN ( CEIL(numamortizacion) > numamortizacion) THEN
				'ANTICIPADA'
			ELSE
				(CASE WHEN ( fechadepago < CURRENT_DATE AND importeamortizacion > abonopagado ) THEN
					'VENCIDA' 
				ELSE 
					( CASE WHEN ( abonopagado - importeamortizacion ) >= 0 AND importeamortizacion > 0 THEN 'PAGADA' ELSE NULL END ) 
				END )
			END ) as estatus,
			(CASE WHEN ( fechadepago < CURRENT_DATE AND importeamortizacion > abonopagado ) THEN
				( CURRENT_DATE - fechadepago ) 
			ELSE 
				( CASE WHEN ( abonopagado - importeamortizacion ) >= 0 THEN ( ultimoabono - fechadepago ) ELSE NULL END ) 
			END) as dias_mora_capital,
			(CASE WHEN abonopagado >= importeamortizacion THEN ultimoabono ELSE NULL END ) as fechapagoreal,
			abonopagado,
			interespagado,
			cobranza,
			cobranzapagado
		FROM
			amortizaciones 
		WHERE
			prestamoid = pprestamoid
		ORDER BY
			numamortizacion
    loop
      return next r;
    end loop;

return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;