update catalogominimo2 set cmacumulable ='1' where cmcuenta in ('1301','1302','1303');


drop TYPE rcatalogominimo cascade;
CREATE TYPE rcatalogominimo AS (
	cmcuenta character(24),
        cmacumulable character (24),    
	ordenpresentacion integer,
	c1 character varying,
	c2 character varying,
	c3 character varying,
	c4 character varying,
	c5 character varying,
	saldo numeric,
	naturaleza character(10),
	rubro character(10),
        cuentasiti character(24)
);



CREATE or replace FUNCTION imprimircatalogominimo(integer, integer, integer) RETURNS SETOF rcatalogominimo
    AS $_$
declare
  r rcatalogominimo%rowtype;
  f record;
  ejercicio alias for $1;
  periodo alias for $2;
  consolidado alias for $3;
  fsaldo numeric;
  ilargo integer;

begin

update catalogominimo2 set saldo=0,saldocalculado=0;
 
if consolidado=0 then

   update catalogominimo2 set saldo=round(saldocuenta(cuentaid,ejercicio,periodo)),saldocalculado=round(saldocuenta(cuentaid,ejercicio,periodo)) ;

else

   update catalogominimo2 set saldo=round(saldocuentac(cuentaid,ejercicio,periodo)),saldocalculado=round(saldocuentac(cuentaid,ejercicio,periodo));

end if;

for f in
select cmcuenta,cmacumulable,ordenpresentacion,c1,c2,c3,c4,c5,naturaleza,rubro,cuentasiti from catalogominimo2 group by cmcuenta,cmacumulable,ordenpresentacion,c1,c2,c3,c4,c5,naturaleza,rubro,cuentasiti order by cuentasiti
  
    loop

      --raise notice 'saldos % %',r.cmcuenta,r.saldo;
      
      if f.cmcuenta  in (select cmacumulable  from catalogominimo2 where cmacumulable=f.cmcuenta) then

         ilargo:=length(rtrim(f.cmcuenta));
         --raise notice 'acumulando % %',f.cmcuenta,ilargo;
         
         update catalogominimo2 set saldocalculado= (select coalesce(sum(saldo),0) from catalogominimo2 where substring(cmcuenta,1,ilargo)=f.cmcuenta and tipo_cta='A') where cmcuenta=f.cmcuenta;
         
         --raise notice 'acumulando % %',r.cmcuenta,r.saldo;
      else
         
         --update catalogominimo2 set saldocalculado= saldo where cuentaid=f.cuentaid;  
         
      end if;
         
    end loop;

    
for r in
select cmcuenta,cmacumulable,ordenpresentacion,c1,c2,c3,c4,c5,sum(saldo),naturaleza,rubro,cuentasiti from catalogominimo2 group by cmcuenta,cmacumulable,ordenpresentacion,c1,c2,c3,c4,c5,naturaleza,rubro,cuentasiti order by cuentasiti
  
    loop

      --raise notice 'saldos % %',r.cmcuenta,r.saldo;
      
      if r.cmcuenta  in (select cmacumulable  from catalogominimo2 where cmacumulable=r.cmcuenta) then
     
         select coalesce(sum(a.saldocalculado),0) into r.saldo from (select saldocalculado as saldocalculado from catalogominimo2 where cmacumulable=r.cmcuenta group by saldocalculado) as a ;

         if r.cmcuenta='4' then

             if consolidado=0 then
                r.saldo:=r.saldo + round(saldocuenta('5',ejercicio,periodo)) + round(saldocuenta('6',ejercicio,periodo));       
             else
                r.saldo:=r.saldo + round(saldocuentac('5',ejercicio,periodo)) + round(saldocuentac('6',ejercicio,periodo));       
             end if;
         end if;     

         --raise notice 'acumulando % %',r.cmcuenta,r.saldo;
         
      end if;
         
      return next r;

    end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



alter table catalogominimo2 drop tipo_cta;
alter table catalogominimo2 drop saldo;
alter table catalogominimo2 drop saldocalculado;

alter table catalogominimo2 add tipo_cta char(1);
alter table catalogominimo2 add saldo numeric;
alter table catalogominimo2 add saldocalculado numeric;



update catalogominimo2 set tipo_cta='A';
update catalogominimo2 set tipo_cta='C' where cmcuenta in (select cmacumulable from catalogominimo2);
update catalogominimo2 set tipo_cta='C' where cmcuenta in ('1','2','3','4','5','6','7','8');

