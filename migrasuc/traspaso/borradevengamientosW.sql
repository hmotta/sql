

delete from movicaja where polizaid in (select polizaid from polizas where fechapoliza ='2016-01-01' and tipo='W');
delete from movipolizas where polizaid in (select polizaid from polizas where fechapoliza ='2016-01-01' and tipo='W');
delete from logpoliza where polizaid in (select polizaid from polizas where fechapoliza ='2016-01-01' and tipo='W');
delete from polizas where fechapoliza='2016-01-01' and tipo='W';
