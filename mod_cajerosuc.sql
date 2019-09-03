alter table cajerosuc add column servidor character varying (15);

update cajerosuc set servidor='10.2.2.1';

update cajerosuc set servidor='192.168.3.3' where serie='AG';
update cajerosuc set servidor='192.168.3.3' where serie='AY';
update cajerosuc set servidor='192.168.3.3' where serie='P3';
update cajerosuc set servidor='192.168.3.3' where serie='P9';
update cajerosuc set servidor='192.168.3.3' where serie='V5';
update cajerosuc set servidor='192.168.3.3' where serie='V8';