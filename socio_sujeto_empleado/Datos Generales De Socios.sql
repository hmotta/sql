select clavesocioint,nombre,fecha_nacimiento,(case when b.tiposocioid='02' then 'MAYOR' else 'MENOR' end),(case when sexo=0 then 'MASCULINO' else 'FEMENINO' end), fechasolicitud,fechaingreso,fechaalta,partesocial,(case when nivelestudiosid=0 then 'Ninguno' else (case when nivelestudiosid=1 then 'Primaria' else (case when nivelestudiosid=2 then 'Secundaria' else (case when nivelestudiosid=3 then 'Preparatoria' else (case when nivelestudiosid=4 then 'Licenciatura' else (case when nivelestudiosid=5 then 'Maestr�a' else 'Doctorado' end)end)end)end)end)end),(case when  tipocasaid=0 then 'Rentada' else (case when tipocasaid=1 then 'Propia' else (case when tipocasaid=2 then 'Familiar' else (case when tipocasaid=3 then 'Compartida' else 'Otra' end) end) end) end),(case when estadocivilid=0  then 'Soltero(a)' else (case when estadocivilid=1 then 'Casado(a)' else (case when estadocivilid=2 then 'Divorciado(a)' else (case when estadocivilid=3 then 'Viudo(a)' else 'Union Libre' end) end) end) end),(select totalingresos from solicitudprestamo where socioid = b.socioid order by fechasolicitud desc limit 1) as totalingresos  from (select * from (select sujetoid,socioid,tiposocioid,clavesocioint,fechaalta,estatussocio,solicitudingresoid,nombre||' '||paterno||' '||' '||materno as nombre,fecha_nacimiento,saldomov(socioid,'PA',current_date) as partesocial from socio natural join sujeto where (estatussocio=1 or estatussocio=3)) as a where fechaalta<='2013-12-31' and tiposocioid in ('02','01','08') and (partesocial>500 and partesocial<=1000)) as b, solicitudingreso si where b.socioid=si.socioid order by clavesocioint;