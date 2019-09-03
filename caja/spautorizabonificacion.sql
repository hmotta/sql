CREATE OR REPLACE FUNCTION spautorizabonificacion(numeric) RETURNS SETOF rautorizabonifica
    AS $_$
declare
  pautorizacionid alias for $1;

  r rautorizabonifica%rowtype;

  iautorizacionid integer;
  iaplicado integer;
begin


iautorizacionid:=trunc(pautorizacionid);

select aplicado into iaplicado from autorizabonificacion where autorizacionid=iautorizacionid;

IF iaplicado=0 THEN
	select inormal,imoratorio,cobranza,seguro,comision,ahorro into r.inormal,r.imoratorio,r.cobranza,r.seguro,r.comision,r.ahorro from autorizabonificacion where autorizacionid=iautorizacionid and movicajaid=0 and aplicado =0;

	r.inormal:=coalesce(r.inormal,0);
	r.imoratorio:=coalesce(r.imoratorio,0);
	r.cobranza:=coalesce(r.cobranza,0);
	r.seguro:=coalesce(r.seguro,0);
	r.comision:=coalesce(r.comision,0);
	r.ahorro:=coalesce(r.ahorro,0);

	r.totalbonificacion:=r.inormal+r.imoratorio+r.cobranza+r.seguro+r.comision+r.ahorro;

	return next r;
ELSE
	raise exception 'El ID de la bonificación ya fue aplicado!! ';
END IF;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;