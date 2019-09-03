alter table sabana add referenciabanco character(20);
alter table sabana add foliogrupal integer default 0;

CREATE or replace FUNCTION spisabana(integer, integer, character, integer, date, numeric, integer, integer, character varying, character varying, character varying, character varying, integer) RETURNS integer
    AS $_$
declare
   pdenominacionid  alias for $1;
   psocioid         alias for $2;
   pseriecaja       alias for $3;
   preferenciacaja  alias for $4;
   pfecha           alias for $5;
   pvalor           alias for $6;
   pcantidad        alias for $7;
   pentradasalida   alias for $8;
   pnumcheque       alias for $9;
   pbanco           alias for $10;
   pnocta           alias for $11;
   preferenciabanco alias for $12;
   pfoliogrupal     alias for $13;   
   
   iefectivo integer;

     --Bancos

   snocta char(20);
   scuentabanco char(24);
   sno_cuenta char(20);

   ppolizaid integer;
   pmovipolizaid integer;
   
   stipomovibancoid char(2);
  
   snombresocio varchar(80);
   sconcepto text;
   iconsecutivo integer;
   sreferenciamovi char(14);
   scuentacaja char(24);
   scuentadeposito char(24);
   ptipomovimientoid char(2);

   r record;

   isocioid integer;
   sfoliogrupal char(8);
   sseriecaja char(2);
   ireferenciacaja integer;
   sdescripcion char(29);
   sgrupo char(15);
  
begin

   insert into sabana(denominacionid,socioid,seriecaja,referenciacaja,fecha,valor,cantidad,entradasalida,numcheque,banco,nocta,referenciabanco,foliogrupal)
   values(pdenominacionid,psocioid,pseriecaja,preferenciacaja,pfecha,pvalor,pcantidad,pentradasalida,pnumcheque,pbanco,pnocta,preferenciabanco,0);

 
return currval('sabana_sabanaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
