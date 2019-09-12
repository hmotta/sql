CREATE or replace FUNCTION spibeneficiario(integer, integer, integer, character varying, numeric) RETURNS integer
    AS $_$
declare
  pinversionid alias for $1;
  psocioid alias for $2;
  psujetoid alias for $3;
  pparentesco alias for $4;
  pporcentajebeneficiario alias for $5;
 
begin

   insert into beneficiario(inversionid,socioid,sujetoid,parentesco,porcentajebeneficiario)
    values( pinversionid,
            psocioid,
            psujetoid,
            pparentesco,
            pporcentajebeneficiario);

return currval('beneficiario_beneficiarioid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- Name: spibeneficiario(integer, integer, integer, character varying, numeric, integer); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION spibeneficiario(integer, integer, integer, character varying, numeric, integer) RETURNS integer
    AS $_$
declare
  pinversionid alias for $1;
  psocioid alias for $2;
  psujetoid alias for $3;
  pparentesco alias for $4;
  pporcentajebeneficiario alias for $5;
  pcontratoid alias for $6;
 
begin

   insert into beneficiario(inversionid,socioid,sujetoid,parentesco,porcentajebeneficiario,contratoid)
    values( pinversionid,
            psocioid,
            psujetoid,
            pparentesco,
            pporcentajebeneficiario,
            pcontratoid);

return currval('beneficiario_beneficiarioid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

--
-- Name: spibeneficiario(integer, integer, integer, character varying, numeric, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION spibeneficiario(integer, integer, integer, character varying, numeric, integer, integer, integer, integer) RETURNS integer
    AS $_$
declare
  pinversionid alias for $1;
  psocioid alias for $2;
  psujetoid alias for $3;
  pparentesco alias for $4;
  pporcentajebeneficiario alias for $5;
  pcontratoid alias for $6;
  pesbeneficiario alias for $7;
  pesrepresentante alias for $8;
  pescootitular alias for $9;
 
begin

   insert into beneficiario(inversionid,socioid,sujetoid,parentesco,porcentajebeneficiario,contratoid,esbeneficiario,esrepresentante,escootitular)
    values( pinversionid,
            psocioid,
            psujetoid,
            pparentesco,
            pporcentajebeneficiario,
            pcontratoid,
            pesbeneficiario,
            pesrepresentante,
            pescootitular);

return currval('beneficiario_beneficiarioid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- Name: spibeneficiario(integer, integer, integer, character varying, numeric, integer, integer); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION spibeneficiario(integer, integer, integer, character varying, numeric, integer, integer) RETURNS integer
    AS $_$
declare
  pinversionid alias for $1;
  psocioid alias for $2;
  psujetoid alias for $3;
  pparentesco alias for $4;
  pporcentajebeneficiario alias for $5;
  pbeneficiario alias for $6;
  pcotitular alias for $7;
 
begin

   insert into beneficiario(inversionid,socioid,sujetoid,parentesco,porcentajebeneficiario,esbeneficiario,escootitular)
    values( pinversionid,
            psocioid,
            psujetoid,
            pparentesco,
            pporcentajebeneficiario,pbeneficiario,pcotitular);

return currval('beneficiario_beneficiarioid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
