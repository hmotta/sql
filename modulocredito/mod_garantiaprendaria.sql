alter table garantiaprendaria OWNER TO sistema;
alter table garantiaprendaria add column garantiaid serial not null;
alter table garantiaprendaria add primary key(garantiaid);
alter table garantiaprendaria add column solicitudprestamoid integer;
alter table garantiaprendaria add constraint  solicitudprestamoid foreign  key (solicitudprestamoid) references solicitudprestamo(solicitudprestamoid);