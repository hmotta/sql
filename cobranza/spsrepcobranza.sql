drop type rrepcobranza cascade;
CREATE TYPE rrepcobranza AS (
	prestamoid integer,
	clavesocioint character varying(15),
	nombre character varying(50),	
	referenciaprestamo character varying(18),
	grupo character varying (25),
	desctipoprestamo character varying(30),
	pagosvencidos integer,
	diasmora integer,
	fechacompromiso date,
	oportunidad character varying(10),
	cobrador character varying(50),
	montocomprimiso numeric,
	montoprestamo numeric,
	saldo numeric,
	llamada1 text,
	acuerdocumplido1 character (1),
	llamada2 text,
	acuerdocumplido2 character (1),
	llamada3 text,
	acuerdocumplido3 character (1),
	llamada4 text,
	acuerdocumplido4 character (1)
);

CREATE OR REPLACE FUNCTION spsrepcobranza() RETURNS SETOF rrepcobranza
    AS $_$
declare
  r rrepcobranza%rowtype;
  l record;
  i integer;
begin	
    
		for r in
		  select * from spscobranza(1)
		loop
			i:=1;
			for l  in 
				select 'Motivo Atraso:'||' '||motivoatraso||' / Acuerdo:'||' '||acuerdo||chr(10)||' Atendio:'||nombreatiende||' Comportamiento:'||comportamiento||chr(10)||' Gestion:'||usuariogestiona||' '||fechagestion||' '||substr(horagestion,1,5) as texto,acuerdocumplido from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=r.prestamoid order by fechagestion
			loop
				if i=1 then
					r.llamada1:=l.texto;
					r.acuerdocumplido1:=l.acuerdocumplido;
				elseif i=2 then
					r.llamada2:=l.texto;
					r.acuerdocumplido2:=l.acuerdocumplido;
				elseif i=3 then
					r.llamada3:=l.texto;
					r.acuerdocumplido3:=l.acuerdocumplido;
				elseif i=4 then
					r.llamada4:=l.texto;
					r.acuerdocumplido4:=l.acuerdocumplido;
				end if;
			end loop;
			return next r;
		end loop;
	
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;