drop table carteradisposicion;
CREATE TABLE carteradisposicion(
    prestamoid integer NOT NULL,
    disposicionid character (18) NOT NULL references disposicion(disposicionid),
	unique (prestamoid,disposicionid)
);