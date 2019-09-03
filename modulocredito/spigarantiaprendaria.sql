CREATE FUNCTION spigarantiaprendaria(character varying, character varying, character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,text,character varying,numeric,character varying,character varying,text,integer) RETURNS integer
    AS $_$
declare
	  ptipogarantia alias for $1;
	  ppropietario alias for $2;
	  pfechafactura alias for $3;
	  pnofactura alias for $4;
	  pmarca alias for $5;
	  pmodelo alias for $6;
	  panio alias for $7;
	  pcolor alias for $8;
	  pnoserie alias for $9;
	  pnomotor alias for $10;
	  ptrasmision alias for $11;
	  pnopuertas alias for $12;
	  pcilindros alias for $13;
	  pnoendosos alias for $14;
	  pdescripcion alias for $15;
	  pvalorfactura alias for $16;
	  pmonto alias for $17;
	  ptipopropiedad alias for $18;
	  pnodocampara alias for $19;
	  pubicacion alias for $20;
	  psolicitudprestamoid alias for $21;
  
begin

      insert into garantiaprendaria (tipogarantia,
			  propietario,
			  fechafactura,
			  nofactura,
			  marca,
			  modelo,
			  anio,
			  color,
			  noserie,
			  nomotor,
			  trasmision,
			  nopuertas,
			  cilindros,
			  noendosos,
			  descripcion,
			  valorfactura,
			  monto,
			  tipopropiedad,
			  nodocampara,
			  ubicacion,
			  solicitudprestamoid)
        values( ptipogarantia,
	  ppropietario,
	  pfechafactura,
	  pnofactura,
	  pmarca,
	  pmodelo,
	  panio,
	  pcolor,
	  pnoserie,
	  pnomotor,
	  ptrasmision,
	  pnopuertas,
	  pcilindros,
	  pnoendosos,
	  pdescripcion,
	  pvalorfactura,
	  pmonto,
	  ptipopropiedad,
	  pnodocampara,
	  pubicacion,
	  psolicitudprestamoid);
     
     return currval('garantiaprendaria_garantiaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;