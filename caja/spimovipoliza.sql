CREATE FUNCTION spimovipoliza(integer, character, character, character, numeric, numeric, character, character, character varying, integer, integer) RETURNS integer
    AS $_$
declare
   ppolizaid         alias for $1;	
   pcuentaid         alias for $2;
   preferencia_mov   alias for $3;
   ptipo_mov         alias for $4;
   pdebe             alias for $5;
   phaber	     alias for $6;
   pdiario_mov       alias for $7;
   pidentific_descr  alias for $8;
   pdescripcion      alias for $9;
   pprestamoid       alias for $10;
   pinversionid      alias for $11;

begin

   insert into movipolizas(polizaid,cuentaid,referencia_mov,tipo_mov,debe,haber,diario_mov,identific_descr,descripcion,prestamoid,inversionid)
    values(ppolizaid,pcuentaid,preferencia_mov,ptipo_mov,round(pdebe,2),round(phaber,2),pdiario_mov,pidentific_descr,pdescripcion,pprestamoid,pinversionid);
            
return currval('movipolizas_movipolizaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;