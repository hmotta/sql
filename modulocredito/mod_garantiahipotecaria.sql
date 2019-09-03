alter table garantiahipotecaria OWNER TO sistema;
alter table garantiahipotecaria add column garantiaid serial not null;
alter table garantiahipotecaria add primary key(garantiaid);
alter table garantiahipotecaria add column solicitudprestamoid integer;
alter table garantiahipotecaria add constraint  solicitudprestamoid foreign  key (solicitudprestamoid) references solicitudprestamo(solicitudprestamoid);