--delete from disposicion;
--delete from carteradisposicion;
insert into disposicion values('505700001800000005',1,2500000.00,2500000.00);
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012130-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012132-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012160-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012161-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012163-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012183-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012184-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012296-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012297-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012299-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012301-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012303-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='012305-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='005-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001725-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001726-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001727-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001728-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001729-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001730-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001731-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001733-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001735-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001736-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001737-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
insert into carteradisposicion (prestamoid,disposicionid) (select (select prestamoid from prestamos where referenciaprestamo='001738-') as prestamoid,'505700001800000005' as disposicionid where exists (select sucid from empresa where sucid='011-'));
