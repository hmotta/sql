--002
update precorte set tipocartera=12 where prestamoid in (select prestamoid from prestamos where referenciaprestamo in ('006772-','006770-','006771-')) and fechacierre='2013-12-31' and exists (select sucid from empresa where sucid='002-');
--005
update precorte set tipocartera=12 where prestamoid in (select prestamoid from prestamos where referenciaprestamo in ('010019-','003922-','011608-','010452-')) and fechacierre='2013-12-31' and exists (select sucid from empresa where sucid='005-');