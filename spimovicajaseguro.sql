CREATE or replace FUNCTION spimovicajaseguro(integer, character, integer, integer, character, integer, integer, character, integer) RETURNS integer
    AS $_$
declare
   psocioid          alias for $1;	
   ptipomovimientoid alias for $2;
   ppolizaid         alias for $3;
   preferenciacaja   alias for $4;
   pseriecaja        alias for $5;
   pmovipolizaid     alias for $6;
   pprestamoid       alias for $7;
   pestatusmovicaja  alias for $8;
   pinversionid      alias for $9;

   fprestamos numeric;
   fretiro numeric;
   fdeposito numeric;
   fsaldo  numeric;

   iestatussocio int;

   saplicasaldo char(1);
   saceptadeposito char(1);
   saceptaretiro   char(1);

   stiposocioid char(2);

   fmontopartesocial numeric;
   fsaldopa numeric;
   ipartesocialcompleta int4;
  
   lsocioid int4;

   irepetido int4;

-- IDE

   fdepositoefectivo numeric;
   fsumaefectivo numeric;
   psaldo numeric;
   pefectivo integer;

   pfecha date;

   scuentacaja char(24);
   scuentadeposito char(24);

   pnumero_poliza int4;
   preferencia int4;

   lreferenciacaja int4;

   ppolizaid1 int4;
   pmovipolizaid1 int4;
   pmovipolizaid2 int4;
   fideexento numeric;
   fporide numeric;
      
begin

   select estatussocio,tiposocioid into iestatussocio,stiposocioid
     from socio
    where socioid=psocioid;

  select montopartesocial,partesocialcompleta,ideexento,poride
       into fmontopartesocial,ipartesocialcompleta,fideexento,fporide
       from empresa where empresaid=1;

   select aplicasaldo,aceptadeposito,aceptaretiro
     into saplicasaldo,saceptadeposito,saceptaretiro
     from tipomovimiento where tipomovimientoid=ptipomovimientoid;

   pefectivo:=3;

   insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,saldoactual,efectivo)
   values(psocioid,ptipomovimientoid,ppolizaid,preferenciacaja,pseriecaja,pmovipolizaid,pprestamoid,pestatusmovicaja,pinversionid,fsaldo,pefectivo);

   
return currval('movicaja_movicajaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;