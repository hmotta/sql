--ALTER TABLE amortizaciones ADD COLUMN dias_mora_capital int4;
--ALTER TABLE amortizaciones ALTER COLUMN numamortizacion TYPE decimal(10,1);

alter table amortizaciones alter column dias_mora_capital set default 0;
update amortizaciones set dias_mora_capital=0 where dias_mora_capital is null;

alter table amortizaciones alter column moratoriopagado set default 0;
update amortizaciones set moratoriopagado=0 where moratoriopagado is null;