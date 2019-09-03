CREATE FUNCTION spugarantiaprendaria(integer,character varying, character varying, character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,character varying,text,character varying,numeric,character varying,character varying,text,integer) RETURNS integer
    AS $_$
declare
	  pgarantiaid alias for $1;
	  ptipogarantia alias for $2;
	  ppropietario alias for $3;
	  pfechafactura alias for $4;
	  pnofactura alias for $5;
	  pmarca alias for $6;
	  pmodelo alias for $7;
	  panio alias for $8;
	  pcolor alias for $9;
	  pnoserie alias for $10;
	  pnomotor alias for $11;
	  ptrasmision alias for $12;
	  pnopuertas alias for $13;
	  pcilindros alias for $14;
	  pnoendosos alias for $15;
	  pdescripcion alias for $16;
	  pvalorfactura alias for $17;
	  pmonto alias for $18;
	  ptipopropiedad alias for $19;
	  pnodocampara alias for $20;
	  pubicacion alias for $21;
	  psolicitudprestamoid alias for $22;
  
begin

      update garantiaprendaria set 
			  tipogarantia=ptipogarantia,
			  propietario=ppropietario,
			  fechafactura=pfechafactura,
			  nofactura=pnofactura,
			  marca=pmarca,
			  modelo=pmodelo,
			  anio=panio,
			  color=pcolor,
			  noserie=pnoserie,
			  nomotor=pnomotor,
			  trasmision=ptrasmision,
			  nopuertas=pnopuertas,
			  cilindros=pcilindros,
			  noendosos=pnoendosos,
			  descripcion=pdescripcion,
			  valorfactura=pvalorfactura,
			  monto=pmonto,
			  tipopropiedad=ptipopropiedad,
			  nodocampara=pnodocampara,
			  ubicacion=pubicacion
      where
		garantiaid=pgarantiaid;
	 
     
     return pgarantiaid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;