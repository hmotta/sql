
alter table tipomovimiento add desglosaiva integer;
--update tipomovimiento set desglosaiva=0;

create or replace function verificacomisionmovimiento(character,numeric) RETURNS SETOF rcomision as
'
declare
  ptipomovimientoid alias for $1;
  pdeposito alias for $2;
  
  r rcomision%rowtype;

  montocomision numeric;
  nporcomision numeric;
  nporivacomision numeric;
  
  fcomision numeric;
  fivacomision numeric;
  idesglosaiva integer;
 
  
begin

--return 50;

select comision,porcomision,porivacomision,desglosaiva into montocomision,nporcomision,nporivacomision,idesglosaiva from tipomovimiento where tipomovimientoid=ptipomovimientoid;

if idesglosaiva = 1 then
      raise notice '' %  %  %  %'',montocomision,nporcomision,nporivacomision,pdeposito;
      r.comision:=0;
      r.ivacomision:= round(((pdeposito * nporivacomision)/100),2);
      return next r;

else
   if nporcomision>0 then
  
      r.comision:=(nporcomision/100)*pdeposito;
      r.ivacomision:=(nporcomision/100)*pdeposito*(nporivacomision/100);
      return next r;

      --raise notice '' %  %  %  %'',montocomision,nporcomision,nporivacomision,pdeposito;
    
   else

      r.comision:=montocomision;
      r.ivacomision:=montocomision*(nporivacomision/100);
      return next r;

   end if;
   
end if;

end
'
language 'plpgsql' security definer;


