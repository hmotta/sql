drop function spigarantiahipotecaria(text,text,integer,text,text,character varying,integer,text,text,text,text,numeric,text,text,integer,text,text,integer,character varying,numeric,integer);
CREATE FUNCTION spigarantiahipotecaria(text,text,integer,text,text,character varying,integer,text,text,text,text,numeric,text,text,integer,text,text,integer,character varying,numeric,integer) RETURNS integer
    AS $_$
declare
		ppropietario alias for $1;
		ptipodoc alias for $2;
		ptomodoc alias for $3;
		ppoblaciondoc alias for $4;
		pedodoc alias for $5;
		pfechadoc alias for $6;
		pnumnotario alias for $7;
		pestadonotario alias for $8;
		pdirpropdad alias for $9;
		pmunipropdad alias for $10;
		pedopropdad alias for $11;
		psuperficepropdad alias for $12;
		pcolindancias alias for $13;
		pseccioncontrato alias for $14;
		ptomocontrato alias for $15;
		pdistritocontrato alias for $16;
		pedocontrato alias for $17;
		pnumcontrato alias for $18;
		pfechacontrato alias for $19;
		pmonto alias for $20;
		psolicitudprestamoid alias for $21;
begin

      insert into garantiahipotecaria (propietario,
		tipodoc,
		tomodoc,
		poblaciondoc,
		edodoc,
		fechadoc,
		numnotario,
		estadonotario,
		dirpropdad,
		munipropdad,
		edopropdad,
		superficepropdad,
		colindancias,
		seccioncontrato,
		tomocontrato,
		distritocontrato,
		edocontrato,
		numcontrato,
		fechacontrato,
		monto,
		solicitudprestamoid
		)
        values(ppropietario,
		ptipodoc,
		ptomodoc,
		ppoblaciondoc,
		pedodoc,
		pfechadoc,
		pnumnotario,
		pestadonotario,
		pdirpropdad,
		pmunipropdad,
		pedopropdad,
		psuperficepropdad,
		pcolindancias,
		pseccioncontrato,
		ptomocontrato,
		pdistritocontrato,
		pedocontrato,
		pnumcontrato,
		pfechacontrato,
		pmonto,
		psolicitudprestamoid
		);
     
     return currval('garantiahipotecaria_garantiaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;