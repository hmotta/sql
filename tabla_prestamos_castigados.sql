CREATE TABLE prestamos_castigados (
	prestamoid integer REFERENCES prestamos(prestamoid),
	dias_mora integer,
	saldo_capital numeric,
	int_ordinario numeric,
	int_moratorio numeric,
	int_ord_cond numeric,
	int_mor_cond numeric,
	PRIMARY KEY (prestamoid)
);