
select * from socio where sujetoid not in (select sujetoid from domicilio);

select count(sujetoid),sujetoid from domicilio group by sujetoid having count(sujetoid) >1;

select sujetoid from conoceatucliente group by sujetoid having count(sujetoid) >1;

delete from conoceatucliente where sujetoid in (select sujetoid from conoceatucliente group by sujetoid having  count(sujetoid) >1);

\i llenaconoceatucliente.sql

update colonia set claveconapo=(select claveconapo from ciudadesmex where ciudadmexid=colonia.ciudadmexid) where claveconapo in (null,'');

update conoceatucliente set comunidadconapo=(select claveconapo from colonia where coloniaid=(select coloniaid from domicilio where sujetoid=conoceatucliente.sujetoid)) where comunidadconapo in (null,'');


