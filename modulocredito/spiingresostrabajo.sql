CREATE FUNCTION spiingresostrabajo(character varying,character varying,numeric,text,integer) RETURNS integer
AS $_$
	declare
		pempresatrabajo alias for $1;
		pnombrejefe alias for $2;
		psueldonetomensual alias for $3;
		pobservaciones alias for $4;
		pdomicilioid alias for $5;
	begin

      insert into ingresostrabajo (empresatrabajo,
		nombrejefe,
		sueldonetomensual,
		observaciones,
		domicilioid
		)
        values(pempresatrabajo,
		pnombrejefe,
		psueldonetomensual,
		pobservaciones,
		pdomicilioid
		);
     
     return currval('ingresostrabajo_ingresoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;