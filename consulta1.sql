select count(p.claveestadocredito) as creditospagados, max(p.fechaultimopago) as fechaultimopago, pm.montoprestamo 
from prestamos p, 

where p.socioid=867 and 
p.claveestadocredito='002' and 

p.socioid not in (select p2.socioid from prestamos p2 where p2.socioid=867 and  p2.claveestadocredito='001') 
group by pm.fechaultimopago,pm.montoprestamo;