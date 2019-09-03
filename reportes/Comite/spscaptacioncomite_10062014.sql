CREATE or replace FUNCTION spscaptacioncomite(date) RETURNS SETOF tcaptacioncomite
    AS $_$
declare
  pfechacierre alias for $1;
  r tcaptacioncomite%rowtype;
  psucid char(4);

begin
select sucid into psucid from empresa where empresaid=1;
	for r in
select
--01-ClaveSocio
	Rtrim(clavesocioint),
--02-Nombresocio 
	Rtrim(nombresocio), 
--03-numero de contrato 
	(case when inversionid>0 then substring(clavesocioint,1,3)||ltrim(to_char(inversionid,'999999'))||'IN' else substring(clavesocioint,1,3)||substring(clavesocioint,5,5)||substring(clavesocioint,11,3)||substring(tipomovimientoid,1,2) end),
--04-sucursal 
	(select Rtrim(nombresucursal) from empresa where empresaid=1),  
--05-fecha de apertura o contratacion
	(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','P3','PA','PB','PR','TA','AI','PR','AM') then (select min(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else fechainversion end),
--06-tipo de depsoito 
	Rtrim(desctipoinversion),
--07-Fecha_del_Deposito
	(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','P3','PB','PR','TA','AI','PR','AM') then (select max(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else (case when tipomovimientoid in ('IN') then fechainversion else (select fechaingreso from solicitudingreso where socioid=captaciontotal.socioid ) end ) end),
--08-fecha de vencimiento
	--(case when inversionid>0 then to_char(fechavencimiento,'DD/MM/YYYY') else (case when tipomovimientoid in ('P3') then to_char(fechadegeneracion,'DD/MM/YYYY') else to_char(fechavencimiento,'DD/MM/YYYY') end) end),
--09-plazo deposto en dias 

--08-fecha de vencimiento
(case when inversionid>0 then to_char(fechavencimiento,'DD/MM/YYYY') else (case when tipomovimientoid in ('AA') then (case when exists (select p.fecha_vencimiento from prestamos p where saldoprestamo>0 and claveestadocredito<>'008' and p.socioid=captaciontotal.socioid) then (select to_char(max(p.fecha_vencimiento),'DD/MM/YYYY') from prestamos p where saldoprestamo>0 and claveestadocredito<>'008' and p.socioid=captaciontotal.socioid) else to_char(pfechacierre+1,'DD/MM/YYYY') end) else 'A LA VISTA' end) end),

	plazo,
--10-forma de pago rendimiento (dias)
	(case when tipomovimientoid in ('IN') then (case when (select i.noderenovaciones from inversion i where i.socioid=captaciontotal.socioid and i.inversionid=captaciontotal.inversionid)=3 then '30' else  formapagorendimiento end) else formapagorendimiento end),
--11-tasa de interes nominal pactada (anual)
	tasainteresnormalinversion,
--nuevo
saldopromedio,
--12-Monto de Original(Capital solo de Depositos a Plazo) 
	deposito,
--13-intereses devengados no pagados al cierre del mes dep a plzo fijo (acumulados)
	--(case when tipomovimientoid in ('IN') then intdevacumulado else intdevmensual end),
intdevacumulado,
--14-saldo total 
	saldototal,
intdevmensual
	from captaciontotal 
	where fechadegeneracion=pfechacierre 
	and sucursal=psucid and tipomovimientoid not in ('IP','ID')
	group by clavesocioint,nombresocio,inversionid,tipomovimientoid,socioid,fechainversion,desctipoinversion,fechavencimiento,plazo,formapagorendimiento,tasainteresnormalinversion,saldopromedio,deposito,intdevacumulado,saldototal,intdevmensual order by clavesocioint, tipomovimientoid

loop 
  
  return next r;

end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;