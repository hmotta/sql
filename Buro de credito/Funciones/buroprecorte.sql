--alter table precorte add importeultimaamort numeric;
--alter table precorte add importevencidoamort numeric;

update precorte set  importeultimaamort=coalesce((select importeamortizacion from amortizaciones where prestamoid=precorte.prestamoid and fechadepago=precorte.fechaultamorpagada),(select min(importeamortizacion) from amortizaciones where prestamoid=precorte.prestamoid )) where fechacierre>='2010-09-30';

update precorte set  importevencidoamort=coalesce(((select sum(importeamortizacion-abonopagado) from amortizaciones where prestamoid=precorte.prestamoid and fechadepago<=precorte.fechacierre)-(select sum(importeamortizacion-abonopagado) from amortizaciones where prestamoid=precorte.prestamoid and fechadepago<precorte.fechaultamorpagada)),0) where fechacierre>='2010-09-30';

update precorte set noamorvencidas=(select count(*) from amortizaciones where prestamoid=precorte.prestamoid and importeamortizacion<>abonopagado and fechadepago<=precorte.fechacierre) where fechacierre>='2010-09-30';
