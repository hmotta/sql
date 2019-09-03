ALTER TABLE amortizaciones ADD COLUMN dias_mora_capital int4;
ALTER TABLE amortizaciones ALTER COLUMN numamortizacion TYPE decimal(10,1);