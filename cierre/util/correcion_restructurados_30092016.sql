update precorte set diasvencidos=87, pagosvencidos=1  where fechacierre='2016-09-30' and prestamoid=(select prestamoid from prestamos where referenciaprestamo='010878-S');
update precorte set diasvencidos=59, pagosvencidos=1  where fechacierre='2016-09-30' and prestamoid=(select prestamoid from prestamos where referenciaprestamo='018009-S');
update precorte set diasvencidos=88, pagosvencidos=1  where fechacierre='2016-09-30' and prestamoid=(select prestamoid from prestamos where referenciaprestamo='015945-S');
update precorte set diasvencidos=65, pagosvencidos=1  where fechacierre='2016-09-30' and prestamoid=(select prestamoid from prestamos where referenciaprestamo='002782-S');
