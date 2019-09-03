CREATE OR REPLACE FUNCTION corrigefoliospso() RETURNS integer
    AS $$
declare
  r record;
  foliocorrectoini integer;
  foliocorrectofin integer;
  folioactual integer;
begin
	select folioini into folioactual from foliops where tipomovimientoid='PSO' limit 1;
    for r in
      select * from foliops where tipomovimientoid='PSO'
    loop
		foliocorrectoini:=r.folioini-folioactual+1;
		foliocorrectofin:=r.foliofin-folioactual+1;
		update foliops set folioini=foliocorrectoini,foliofin=foliocorrectofin where folioid=r.folioid;
      --return next r;
    end loop;
return 1;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;