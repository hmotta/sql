select count(*) from movicaja mc natural join polizas p natural join socio s where seriecaja not in ('ZA','WW') and tipomovimientoid not in ('RE') and fechapoliza between '2013-01-01' and '2013-03-31';