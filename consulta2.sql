select count(p.claveestadocredito) as creditospagados, pf.fechaultimopago, pm.montoprestamo 
from prestamos p, 
(select max(p1.fechaultimopago) as fechaultimopago from prestamos p1 where p1.socioid=867) pf, 
(select p3.prestamoid, p3.montoprestamo, p3.fechaultimopago from prestamos p3 where p3.socioid=867) pm 
where p.socioid=867 and 
p.claveestadocredito='002' and 
pm.fechaultimopago = pf.fechaultimopago and 
p.socioid not in (select p2.socioid from prestamos p2 where p2.socioid=867 and  p2.claveestadocredito='001') 
group by pf.fechaultimopago, pm.fechaultimopago,pm.montoprestamo;

pg_dump -t pg_authid template1 > usuarios.dump