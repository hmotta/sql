select 	si.grupo
			from 	prestamos p, 
					solicitudingreso si
			where 	si.grupo in (select grupo from grupo where grupo <> '<NINGUNO>') and 
					p.claveestadocredito='001'  group by si.grupo;