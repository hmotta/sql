CREATE FUNCTION spugarantiahipotecaria(integer,text,text,integer,text,text,character varying,integer,text,text,text,text,numeric,text,text,integer,text,text,integer,character varying,numeric,integer) RETURNS integer
    AS $_$
declare
	  pgarantiaid alias for $1;
		ppropietario alias for $2;
		ptipodoc alias for $3;
		ptomodoc alias for $4;
		ppoblaciondoc alias for $5;
		pedodoc alias for $6;
		pfechadoc alias for $7;
		pnumnotario alias for $8;
		pestadonotario alias for $9;
		pdirpropdad alias for $10;
		pmunipropdad alias for $11;
		pedopropdad alias for $12;
		psuperficepropdad alias for $13;
		pcolindancias alias for $14;
		pseccioncontrato alias for $15;
		ptomocontrato alias for $16;
		pdistritocontrato alias for $17;
		pedocontrato alias for $18;
		pnumcontrato alias for $19;
		pfechacontrato alias for $20;
		pmonto alias for $21;
		psolicitudprestamoid alias for $22;
  
begin

      update garantiahipotecaria set 
		propietario=ppropietario,
		tipodoc=ptipodoc,
		tomodoc=ptomodoc,
		poblaciondoc=ppoblaciondoc,
		edodoc=pedodoc,
		fechadoc=pfechadoc,
		numnotario=pnumnotario,
		estadonotario=pestadonotario,
		dirpropdad=pdirpropdad,
		munipropdad=pmunipropdad,
		edopropdad=pedopropdad,
		superficepropdad=psuperficepropdad,
		colindancias=pcolindancias,
		seccioncontrato=pseccioncontrato,
		tomocontrato=ptomocontrato,
		distritocontrato=pdistritocontrato,
		edocontrato=pedocontrato,
		numcontrato=pnumcontrato,
		fechacontrato=pfechacontrato,
		monto=pmonto
      where
		garantiaid=pgarantiaid;
	 
     
     return pgarantiaid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;