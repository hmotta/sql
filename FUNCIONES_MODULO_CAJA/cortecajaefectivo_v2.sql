CREATE or replace FUNCTION cortecajaefectivo(character, date, integer) RETURNS SETOF rcortecaja
    AS $_$
declare
 pserie alias for $1;
 pfecha alias for $2;
 presumido alias for $3;
 r rcortecaja%rowtype;
 l record;
 i int;

 fcapital numeric;
 fnormal numeric;
 fmoratorio numeric;
 fiva numeric;
 fcobranza numeric;

 tipomovimiento char;
 
begin
 -------------------------------------------
 -- Movimientos de deposito retiro en caja
 -------------------------------------------

 for r in

   select m.referenciacaja as folio,p.numero_poliza,m.seriecaja as serie,m.socioid,s.clavesocioint,
          p.fechapoliza as fecha, 0 as capital, 0 as interes, 0 as moratorio, 0 as iva,
          mp.debe as deposito, mp.haber as retiro, m.tipomovimientoid, ' ' as tipoprestamoid, 0 as cobranza
     from movicaja m, polizas p, movipolizas mp, socio s, parametros pa
    where (m.seriecaja = pserie or pserie=' ') and
          p.polizaid = m.polizaid and
          p.fechapoliza = pfecha and
          mp.movipolizaid = m.movipolizaid and
          mp.polizaid = p.polizaid and
          pa.serie_user = m.seriecaja and 
          mp.cuentaid = pa.cuentacaja and 
          s.socioid = m.socioid and 
          m.efectivo=1 and 
          m.tipomovimientoid <> 'IN' and
          m.tipomovimientoid <> '00' and
          m.tipomovimientoid <> 'CO'
 order by m.referenciacaja

 loop
  -- Movimientos normales en Caja   
   return next r;
 end loop;

 -------------------------------------------
 -- Movimientos     CO
 -------------------------------------------

for l in

   select distinct(m.movicajaid),m.referenciacaja as folio,p.numero_poliza as referencia ,m.seriecaja as serie,m.socioid,s.clavesocioint,
          p.fechapoliza as fecha, 0 as capital, 0 as interes, 0 as moratorio, 0 as iva,
          mp.debe as retiro, mp.haber as deposito, m.tipomovimientoid, ' ' as tipoprestamoid
     from movicaja m, polizas p, movipolizas mp, socio s, parametros pa
    where (m.seriecaja = pserie or pserie=' ') and
          p.polizaid = m.polizaid and
          p.fechapoliza = pfecha and
          mp.cuentaid = '4-09-02-08-01-  -' and
          mp.polizaid = p.polizaid and
          pa.serie_user = m.seriecaja and 
          --mp.cuentaid = pa.cuentacaja and 
          s.socioid = m.socioid and 
	  m.efectivo=1 and 
          m.tipomovimientoid = 'CO' 
 order by m.referenciacaja


 loop
   r.folio := l.folio;
   r.referencia := l.referencia;
   r.serie := l.serie;
   r.socioid := l.socioid;
   r.clavesocioint := l.clavesocioint;
   r.fecha := l.fecha;
   r.capital := 0;
   r.interes := 0;
   r.moratorio := 0;
   r.iva := 0;
   r.deposito := l.deposito;
   r.retiro := l.retiro;
   r.tipomovimientoid := l.tipomovimientoid;
   r.tipoprestamoid = l.tipoprestamoid;
   r.cobranza = 0;


   return next r;
 end loop;
 
 -------------------------------------------
 -- Movimientos Prestamos    00
 -------------------------------------------


for l in

   select m.referenciacaja as folio,p.numero_poliza as referencia,m.seriecaja as serie,m.socioid,
          s.clavesocioint,
          p.fechapoliza as fecha, 0 as capital, 0 as interes, 0 as moratorio, 0 as iva,
          0 as deposito, 0 as retiro, m.tipomovimientoid, 0 as cobranza, p.polizaid,
          t.cuentaactivo,t.cuentaintnormal,t.cuentaintmora,t.cuentaiva, pr.tipoprestamoid,t.cuentafondorecuperacion
     from movicaja m, polizas p, movipolizas mp,socio s, prestamos pr, tipoprestamo t
    where (m.seriecaja = pserie or pserie=' ') and
          p.polizaid = m.polizaid and
          p.fechapoliza = pfecha and
          mp.polizaid = p.polizaid and
          mp.movipolizaid = m.movipolizaid and
          s.socioid = m.socioid and
	  m.efectivo=1 and 
          m.tipomovimientoid='00' and
          pr.prestamoid = m.prestamoid and
          t.tipoprestamoid = pr.tipoprestamoid
 order by m.referenciacaja

 loop 
   -- Movimientos capital
   fcapital := 0;
   fnormal := 0;
   fmoratorio := 0;
   fiva := 0;

   select (case when l.tipoprestamoid <> 'CAS' then coalesce(sum(haber),0) else abs(coalesce(sum(debe),0)-coalesce(sum(haber),0)) end) into fcapital
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentaactivo;
   select coalesce(sum(haber),0) into fnormal
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentaintnormal;

   select coalesce(sum(haber),0) into fmoratorio
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentaintmora;

   select coalesce(sum(haber),0) into fiva
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentaiva;

   select coalesce(sum(haber),0) into fcobranza
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentafondorecuperacion;

   -- Formar renglon
   r.folio := l.folio;
   r.referencia := l.referencia;
   r.serie := l.serie;
   r.socioid := l.socioid;
   r.clavesocioint := l.clavesocioint;
   r.fecha := l.fecha;
   r.capital := fcapital;
   r.interes := fnormal;
   r.moratorio := fmoratorio;
   r.iva := fiva;
   r.deposito := 0;
   r.retiro := 0;
   r.tipomovimientoid := l.tipomovimientoid;
   r.tipoprestamoid := l.tipoprestamoid;
   r.cobranza := fcobranza;

   return next r;
 end loop;


 ---------------------------------------
 -- Movimientos Inversiones  IN
 ---------------------------------------
for l in
   select m.referenciacaja as folio,p.numero_poliza as referencia,m.seriecaja as serie,
          m.socioid,s.clavesocioint,p.fechapoliza as fecha,
          0 as capital, 0 as interes, 0 as moratorio, 0 as iva,0 as deposito, 0 as retiro,
          m.tipomovimientoid, p.polizaid, t.cuentaintinver,t.cuentaivainver,t.cuentapasivo,t.cuentariesgocred,0 as cobranza
     from movicaja m, polizas p, movipolizas mp, socio s, inversion ix, tipoinversion t, parametros pa
    where (m.seriecaja = pserie or pserie=' ') and 
          p.polizaid = m.polizaid and
          p.fechapoliza = pfecha and
          mp.polizaid = p.polizaid and
          pa.serie_user = m.seriecaja and 
          mp.cuentaid = pa.cuentacaja and         
          s.socioid = m.socioid and
	  m.efectivo=1 and 
          m.tipomovimientoid='IN' and
          ix.inversionid = m.inversionid and
          t.tipoinversionid = ix.tipoinversionid
group by m.referenciacaja,p.numero_poliza,m.seriecaja,
          m.socioid,s.clavesocioint,p.fechapoliza,
          m.tipomovimientoid, p.polizaid, t.cuentaintinver,t.cuentaivainver,t.cuentapasivo,t.cuentariesgocred
   order by m.referenciacaja

 loop 
   -- Movimientos capital

   fnormal := 0;
   fmoratorio := 0;
   fiva := 0;
   fcapital := 0;

   select coalesce(haber-debe,0) into fcapital
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentapasivo;

   select coalesce(SUM(haber-debe),0) into fnormal
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentaintinver;

   select coalesce(SUM(haber-debe),0) into fiva
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentariesgocred;

   -- Formar renglon
   r.folio := l.folio;
   r.referencia := l.referencia;
   r.serie := l.serie;
   r.socioid := l.socioid;
   r.clavesocioint := l.clavesocioint;
   r.fecha := l.fecha;
   r.capital := 0;
   r.interes := fnormal;
   r.moratorio := fmoratorio;
   r.iva := fiva;
   if fcapital>0 then
     r.deposito := fcapital;
     r.retiro := 0;
   else
     r.deposito := 0;
     r.retiro := -1*fcapital;
   end if;
   r.tipomovimientoid := l.tipomovimientoid;
   r.cobranza :=0;
   return next r;
 end loop;

return;
end;
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
