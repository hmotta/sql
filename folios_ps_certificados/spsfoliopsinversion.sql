CREATE OR REPLACE FUNCTION spsfoliopsinversion(inversionid1 integer) RETURNS text
    AS $$
declare
  --r record;
  --psocioid alias for $1;
  texto text;
  tfolioini text;
  tfoliofin text;
  nsaldo numeric;
  ipartes real;
  ifolioini integer;
  ifoliofin integer;
  csucid character(2);
begin
	select SUM((case when mp.cuentaid=t.cuentapasivo then mp.haber-mp.debe else 0 end)) into nsaldo from polizas p, movicaja m, movipolizas mp, inversion i,tipoinversion t where i.fechainversion<=current_date and m.inversionid = i.inversionid and p.polizaid = m.polizaid and p.fechapoliza <= CURRENT_DATE and t.tipoinversionid = i.tipoinversionid and mp.polizaid = p.polizaid and i.inversionid=inversionid1;
	
	select folioini,foliofin into ifolioini,ifoliofin from foliops where inversionid=inversionid1 and vigente='S';
	ipartes = nsaldo/500;
	--raise notice 'saldo=%',nsaldo;
	--raise notice '% partes',ipartes;
	if ipartes>1 then
		if ipartes<>((ifoliofin-ifolioini)+1) then
			--raise notice 'Error en saldo % % socioid=%',ifoliofin,ifolioini,isocioid;
			return 'X';
		end if;
	else
		if ifolioini<>ifoliofin then
			--raise notice 'Error en saldo socioid=%',isocioid;
			return 'X';
		end if;
	end if;
	select substr(sucid,2,2) into csucid from empresa;
	select csucid||(case when tipomovimientoid='P3' then 'C' else (case when tipomovimientoid='PSO' then 'D' else (case when tipomovimientoid='PSV' then 'B' else 'X' end) end) end)||substr(to_char(ejercicio,'9999'),4,2)||lpad(periodo,2,'0')||lpad(folioini,6,'0') into tfolioini from foliops where inversionid=inversionid1 and vigente='S';
	
	select csucid||(case when tipomovimientoid='P3' then 'C' else (case when tipomovimientoid='PSO' then 'D' else (case when tipomovimientoid='PSV' then 'B' else 'X' end) end) end)||substr(to_char(ejercicio,'9999'),4,2)||lpad(periodo,2,'0')||lpad(foliofin,6,'0') into tfoliofin from foliops where inversionid=inversionid1 and vigente='S';
	texto = 'No. '||tfolioini||' al '||tfoliofin;
return texto;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;