
drop type tcartera411 cascade;

CREATE TYPE tcartera411 AS (
CLAVE__ENTIDAD char(6),
CLAVE_NIVEL_INSTITUCION integer,
CONCEPTO char(12),
SUBREPORTE integer,
TIPO_SALDO integer,
DATO NUMERIC
);




CREATE or replace FUNCTION cartera411c(integer,integer) RETURNS SETOF tcartera411
    AS $_$
declare
--Modificado 4-08-2011
  
  pejercicio alias for $1;
  pperiodo alias for $2;

  r tcartera411%rowtype;
  f record ;
  
  pnivel integer;
  pclaveentidad char(6);

  ptiposaldo1 numeric;
  ptiposaldo2 numeric;
  ptiposaldo3 numeric;
  ptiposaldo4 numeric;
  
  pcomercial1 numeric;
  pcomercial2 numeric;
  pcomercial3 numeric;
  pcomercial4 numeric;
  pcomercial11 numeric;
  pcomercial12 numeric;
  pcomercial13 numeric;
  pcomercial14 numeric;
  pcomercial21 numeric;
  pcomercial22 numeric;
  pcomercial23 numeric;
  pcomercial24 numeric;

  pconsumo1 numeric;
  pconsumo2 numeric;
  pconsumo3 numeric;
  pconsumo4 numeric;
  pconsumo11 numeric;
  pconsumo12 numeric;
  pconsumo13 numeric;
  pconsumo14 numeric;
  pconsumo21 numeric;
  pconsumo22 numeric;
  pconsumo23 numeric;
  pconsumo24 numeric;

  pvivienda1 numeric;
  pvivienda2 numeric;
  pvivienda3 numeric;
  pvivienda4 numeric;
  pvivienda11 numeric;
  pvivienda12 numeric;
  pvivienda13 numeric;
  pvivienda14 numeric;
  pvivienda21 numeric;
  pvivienda22 numeric;
  pvivienda23 numeric;
  pvivienda24 numeric;

  i integer;
  
begin

  pnivel:=202;
  ptiposaldo1 :=0;
  ptiposaldo2 :=0;
  ptiposaldo3 :=0;
  ptiposaldo4 :=0;
  
  pcomercial1 :=0;
  pcomercial2 :=0;
  pcomercial3 :=0;
  pcomercial4 :=0;
  pcomercial11 :=0;
  pcomercial12 :=0;
  pcomercial13 :=0;
  pcomercial14 :=0;
  pcomercial21 :=0;
  pcomercial22 :=0;
  pcomercial23 :=0;
  pcomercial24 :=0;

  pconsumo1 :=0;
  pconsumo2 :=0;
  pconsumo3 :=0;
  pconsumo4 :=0;
  pconsumo11 :=0;
  pconsumo12 :=0;
  pconsumo13 :=0;
  pconsumo14 :=0;
  pconsumo21 :=0;
  pconsumo22 :=0;
  pconsumo23 :=0;
  pconsumo24 :=0;

  pvivienda1 :=0;
  pvivienda2 :=0;
  pvivienda3 :=0;
  pvivienda4 :=0;
  pvivienda11 :=0;
  pvivienda12 :=0;
  pvivienda13 :=0;
  pvivienda14 :=0;
  pvivienda21 :=0;
  pvivienda22 :=0;
  pvivienda23 :=0;
  pvivienda24 :=0;

select rtrim(ltrim(substring(claveentidad,1,6))) into  pclaveentidad from empresa;

for f in

select pagosvencidos,finalidaddefault,round(sum(saldoprestamo)) as tsaldo1,round(sum(interesdevengadomenoravencido+interesdevmormenor)) as tsaldo2,round(sum(saldoprestamo+interesdevengadomenoravencido+interesdevmormenor)) as tsaldo3, round(sum(pagointeresenperiodo)) as tsaldo4 from precorteconsolidado(pejercicio,pperiodo) where tipoprestamoid<>'CAS' group by pagosvencidos,finalidaddefault order by pagosvencidos,finalidaddefault 
loop
 if f.finalidaddefault='001' then 
   ptiposaldo1:=ptiposaldo1+f.tsaldo1;
   ptiposaldo2:=ptiposaldo2+f.tsaldo2;
   ptiposaldo3:=ptiposaldo3+f.tsaldo3;
   ptiposaldo4:=ptiposaldo4+f.tsaldo4;

   if f.pagosvencidos=0 then
   
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=2;
     r.DATO :=f.tsaldo1;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=3;
     r.DATO :=f.tsaldo2;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=1;
     r.DATO :=f.tsaldo3;
     return next r;
     
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=4;
     r.DATO :=f.tsaldo4;
     return next r;
    
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=5;
     r.DATO :=0;
     return next r;

     pcomercial1:=pcomercial1+f.tsaldo1;
     pcomercial2:=pcomercial2+f.tsaldo2;
     pcomercial3:=pcomercial3+f.tsaldo3;
     pcomercial4:=pcomercial4+f.tsaldo4;

   else 
     if f.pagosvencidos=1 then

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=2;
       r.DATO :=f.tsaldo1;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=3;
       r.DATO :=f.tsaldo2;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=1;
       r.DATO :=f.tsaldo3;
       return next r;
     
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=4;
       r.DATO :=f.tsaldo4;
       return next r;
    
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=5;
       r.DATO :=0;
       return next r;

       pcomercial11:=pcomercial11+f.tsaldo1;
       pcomercial12:=pcomercial12+f.tsaldo2;
       pcomercial13:=pcomercial13+f.tsaldo3;
       pcomercial14:=pcomercial14+f.tsaldo4;
     

     else
       if f.pagosvencidos=2 then
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=2;
         r.DATO :=f.tsaldo1;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=3;
         r.DATO :=f.tsaldo2;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=1;
         r.DATO :=f.tsaldo3;
         return next r;
     
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=4;
         r.DATO :=f.tsaldo4;
         return next r;
    
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=5;
         r.DATO :=0;
         return next r;

         pcomercial21:=pcomercial21+f.tsaldo1;
         pcomercial22:=pcomercial22+f.tsaldo2;
         pcomercial23:=pcomercial23+f.tsaldo3;
         pcomercial24:=pcomercial24+f.tsaldo4;
       end if;
     end if;
   end if;
 else
 -- Consumo 
 if f.finalidaddefault='002' then 
   ptiposaldo1:=ptiposaldo1+f.tsaldo1;
   ptiposaldo2:=ptiposaldo2+f.tsaldo2;
   ptiposaldo3:=ptiposaldo3+f.tsaldo3;
   ptiposaldo4:=ptiposaldo4+f.tsaldo4;

   if f.pagosvencidos=0 then
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=2;
     r.DATO :=f.tsaldo1;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=3;
     r.DATO :=f.tsaldo2;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=1;
     r.DATO :=f.tsaldo3;
     return next r;
     
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=4;
     r.DATO :=f.tsaldo4;
     return next r;
    
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=5;
     r.DATO :=0;
     return next r;

     pconsumo1:=pconsumo1+f.tsaldo1;
     pconsumo2:=pconsumo2+f.tsaldo2;
     pconsumo3:=pconsumo3+f.tsaldo3;
     pconsumo4:=pconsumo4+f.tsaldo4;

   else 
     if f.pagosvencidos=1 then

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=2;
       r.DATO :=f.tsaldo1;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=3;
       r.DATO :=f.tsaldo2;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=1;
       r.DATO :=f.tsaldo3;
       return next r;
     
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=4;
       r.DATO :=f.tsaldo4;
       return next r;
    
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=5;
       r.DATO :=0;
       return next r;

       pconsumo11:=pconsumo11+f.tsaldo1;
       pconsumo12:=pconsumo12+f.tsaldo2;
       pconsumo13:=pconsumo13+f.tsaldo3;
       pconsumo14:=pconsumo14+f.tsaldo4;
     

     else
       if f.pagosvencidos=2 then
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=2;
         r.DATO :=f.tsaldo1;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=3;
         r.DATO :=f.tsaldo2;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=1;
         r.DATO :=f.tsaldo3;
         return next r;
     
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=4;
         r.DATO :=f.tsaldo4;
         return next r;
    
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=5;
         r.DATO :=0;
         return next r;

         pconsumo21:=pconsumo21+f.tsaldo1;
         pconsumo22:=pconsumo22+f.tsaldo2;
         pconsumo23:=pconsumo23+f.tsaldo3;
         pconsumo24:=pconsumo24+f.tsaldo4;
       end if;
     end if;
   end if;
 else
 --Vivienda
 
 if f.finalidaddefault='003' then 
   ptiposaldo1:=ptiposaldo1+f.tsaldo1;
   ptiposaldo2:=ptiposaldo2+f.tsaldo2;
   ptiposaldo3:=ptiposaldo3+f.tsaldo3;
   ptiposaldo4:=ptiposaldo4+f.tsaldo4;

   if f.pagosvencidos=0 then
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=2;
     r.DATO :=f.tsaldo1;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=3;
     r.DATO :=f.tsaldo2;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=1;
     r.DATO :=f.tsaldo3;
     return next r;
     
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=4;
     r.DATO :=f.tsaldo4;
     return next r;
    
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=5;
     r.DATO :=0;
     return next r;

     pvivienda1:=pvivienda1+f.tsaldo1;
     pvivienda2:=pvivienda2+f.tsaldo2;
     pvivienda3:=pvivienda3+f.tsaldo3;
     pvivienda4:=pvivienda4+f.tsaldo4;

   else 
     if f.pagosvencidos=1 then

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=2;
       r.DATO :=f.tsaldo1;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=3;
       r.DATO :=f.tsaldo2;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=1;
       r.DATO :=f.tsaldo3;
       return next r;
     
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=4;
       r.DATO :=f.tsaldo4;
       return next r;
    
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=5;
       r.DATO :=0;
       return next r;

       pvivienda11:=pvivienda11+f.tsaldo1;
       pvivienda12:=pvivienda12+f.tsaldo2;
       pvivienda13:=pvivienda13+f.tsaldo3;
       pvivienda14:=pvivienda14+f.tsaldo4;
     

     else
       if f.pagosvencidos=2 then
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=2;
         r.DATO :=f.tsaldo1;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=3;
         r.DATO :=f.tsaldo2;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=1;
         r.DATO :=f.tsaldo3;
         return next r;
     
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=4;
         r.DATO :=f.tsaldo4;
         return next r;
    
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=5;
         r.DATO :=0;
         return next r;

         pvivienda21:=pvivienda21+f.tsaldo1;
         pvivienda22:=pvivienda22+f.tsaldo2;
         pvivienda23:=pvivienda23+f.tsaldo3;
         pvivienda24:=pvivienda24+f.tsaldo4;
       end if;
     end if;
   end if;
 end if;

 ---
 end if;
 end if;

end loop;

--Totales

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=ptiposaldo1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=ptiposaldo2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=ptiposaldo3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=ptiposaldo4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800100000000;Cartera de credito vigente sin pagos vencidos;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial1+pconsumo1+pvivienda1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial2+pconsumo2+pvivienda2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial3+pconsumo3+pvivienda3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial4+pconsumo4+pvivienda4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800101000000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800101010000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800102000000;Creditos de consumo;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pconsumo1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pconsumo2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pconsumo3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pconsumo4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800103000000;Creditos a la vivienda;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pvivienda1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pvivienda2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pvivienda3;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pvivienda4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800200000000;Cartera de credito vigente con pagos vencidos;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial11+pconsumo11+pvivienda11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial12+pconsumo12+pvivienda12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial13+pconsumo13+pvivienda13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial14+pconsumo14+pvivienda14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800201000000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800201010000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800202000000;Creditos al consumo;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pconsumo11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pconsumo12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pconsumo13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pconsumo14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800203000000;Creditos a la vivienda;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pvivienda11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pvivienda12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pvivienda13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pvivienda14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800500000000;Cartera de credito vencida;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial21+pconsumo21+pvivienda21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial22+pconsumo22+pvivienda22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial23+pconsumo23+pvivienda23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial24+pconsumo24+pvivienda24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800501000000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800501010000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800502000000;Creditos al consumo;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pconsumo21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pconsumo22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pconsumo23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pconsumo24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800503000000;Creditos a la vivienda;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pvivienda21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pvivienda22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pvivienda23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pvivienda24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--- Todas los productos que no se utilizan en la entidad.

--411;800101000000;Creditos comerciales;
--i:=1;
--while i < 6
--loop
--  r.CLAVE__ENTIDAD:= pclaveentidad;
--  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
--  r.CONCEPTO:='800101000000';
--  r.SUBREPORTE :=411;
--  r.TIPO_SALDO :=i;
--  r.DATO :=0;
--  i:=i+1;
--  return next r;
--end loop;
--411;800101010000;Actividad empresarial o comercial;
--i:=1;
--while i < 6
--loop
--  r.CLAVE__ENTIDAD:= pclaveentidad;
--  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
--  r.CONCEPTO:='800101010000';
--  r.SUBREPORTE :=411;
--  r.TIPO_SALDO :=i;
--  r.DATO :=0;
--  i:=i+1;
--  return next r;
--end loop;


--411;800101010100;Operaciones quirografarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010100';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101010200;Operaciones prendarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010200';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101010300;Creditos puente;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010300';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101010400;Operaciones de factoraje;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010400';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101010500;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010500';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101020000;Prestamos de liquidez a otras Entidades de Ahorro y Credito Popular;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101020000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800102010000;Tarjeta de credito;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800102010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800102030000;ABCD;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800102030000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800102040000;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800102040000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800102900000;Otros creditos de consumo;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800102900000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800103010000;Residencial;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800103010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201010000;Actividad empresarial o comercial;
--i:=1;
--while i < 6
--loop
--  r.CLAVE__ENTIDAD:= pclaveentidad;
--  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
--  r.CONCEPTO:='800201010000';
--  r.SUBREPORTE :=411;
--  r.TIPO_SALDO :=i;
--  r.DATO :=0;
--  i:=i+1;
--  return next r;
--end loop;



--411;800201010100;Operaciones quirografarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010100';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800201010200;Operaciones prendarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010200';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201010300;Creditos puente;

i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010300';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201010400;Operaciones de factoraje;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010400';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201010500;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010500';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201020000;Prestamos de liquidez a otras Entidades de Ahorro y Credito Popular;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201020000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800202010000;Tarjeta de credito;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800202010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800202030000;ABCD;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800202030000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800202040000;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800202040000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800202900000;Otros creditos de consumo;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800202900000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800203010000;Media o residencial;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800203010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800501010000;Actividad empresarial o comercial;
--i:=1;
--while i < 6
--loop
--  r.CLAVE__ENTIDAD:= pclaveentidad;
--  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
--  r.CONCEPTO:='800501010000';
--  r.SUBREPORTE :=411;
--  r.TIPO_SALDO :=i;
--  r.DATO :=0;
--  i:=i+1;
--  return next r;
--end loop;

--411;800501010100;Operaciones quirografarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010100';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800501010200;Operaciones prendarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010200';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800501010300;Creditos puente;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010300';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800501010400;Operaciones de factoraje;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010400';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800501010500;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010500';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800501020000;Prestamos de liquidez a otras Entidades de Ahorro y Credito Popular;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501020000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800502010000;Tarjeta de credito;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800502010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800502030000;ABCD;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800502030000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800502040000;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800502040000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800502050000;Otros creditos de consumo;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800502050000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800503020000;Residencial;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800503010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


--Del ultimo

CREATE or replace FUNCTION cartera411(integer, integer) RETURNS SETOF tcartera411
    AS $_$
declare
  --Modificado 4-08-2011
  
  pejercicio alias for $1;
  pperiodo alias for $2;

  r tcartera411%rowtype;
  f record ;
  
  pnivel integer;
  pclaveentidad char(6);

  ptiposaldo1 numeric;
  ptiposaldo2 numeric;
  ptiposaldo3 numeric;
  ptiposaldo4 numeric;
  
  pcomercial1 numeric;
  pcomercial2 numeric;
  pcomercial3 numeric;
  pcomercial4 numeric;
  pcomercial11 numeric;
  pcomercial12 numeric;
  pcomercial13 numeric;
  pcomercial14 numeric;
  pcomercial21 numeric;
  pcomercial22 numeric;
  pcomercial23 numeric;
  pcomercial24 numeric;

  pconsumo1 numeric;
  pconsumo2 numeric;
  pconsumo3 numeric;
  pconsumo4 numeric;
  pconsumo11 numeric;
  pconsumo12 numeric;
  pconsumo13 numeric;
  pconsumo14 numeric;
  pconsumo21 numeric;
  pconsumo22 numeric;
  pconsumo23 numeric;
  pconsumo24 numeric;

  pvivienda1 numeric;
  pvivienda2 numeric;
  pvivienda3 numeric;
  pvivienda4 numeric;
  pvivienda11 numeric;
  pvivienda12 numeric;
  pvivienda13 numeric;
  pvivienda14 numeric;
  pvivienda21 numeric;
  pvivienda22 numeric;
  pvivienda23 numeric;
  pvivienda24 numeric;

  i integer;
  
begin

  pnivel:=202;
  ptiposaldo1 :=0;
  ptiposaldo2 :=0;
  ptiposaldo3 :=0;
  ptiposaldo4 :=0;
  
  pcomercial1 :=0;
  pcomercial2 :=0;
  pcomercial3 :=0;
  pcomercial4 :=0;
  pcomercial11 :=0;
  pcomercial12 :=0;
  pcomercial13 :=0;
  pcomercial14 :=0;
  pcomercial21 :=0;
  pcomercial22 :=0;
  pcomercial23 :=0;
  pcomercial24 :=0;

  pconsumo1 :=0;
  pconsumo2 :=0;
  pconsumo3 :=0;
  pconsumo4 :=0;
  pconsumo11 :=0;
  pconsumo12 :=0;
  pconsumo13 :=0;
  pconsumo14 :=0;
  pconsumo21 :=0;
  pconsumo22 :=0;
  pconsumo23 :=0;
  pconsumo24 :=0;

  pvivienda1 :=0;
  pvivienda2 :=0;
  pvivienda3 :=0;
  pvivienda4 :=0;
  pvivienda11 :=0;
  pvivienda12 :=0;
  pvivienda13 :=0;
  pvivienda14 :=0;
  pvivienda21 :=0;
  pvivienda22 :=0;
  pvivienda23 :=0;
  pvivienda24 :=0;

select rtrim(ltrim(substring(claveentidad,1,6))) into  pclaveentidad from empresa;

for f in

select pagosvencidos,finalidaddefault,round(sum(saldoprestamo)) as tsaldo1,round(sum(interesdevengadomenoravencido+interesdevmormenor)) as tsaldo2,round(sum(saldoprestamo+interesdevengadomenoravencido+interesdevmormenor)) as tsaldo3, round(sum(pagointeresenperiodo)) as tsaldo4 from precorte where ejercicio=pejercicio and periodo=pperiodo and tipoprestamoid<>'CAS' group by pagosvencidos,finalidaddefault order by pagosvencidos,finalidaddefault 
loop
 if f.finalidaddefault='001' then 
   ptiposaldo1:=ptiposaldo1+f.tsaldo1;
   ptiposaldo2:=ptiposaldo2+f.tsaldo2;
   ptiposaldo3:=ptiposaldo3+f.tsaldo3;
   ptiposaldo4:=ptiposaldo4+f.tsaldo4;

   if f.pagosvencidos=0 then
   
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=2;
     r.DATO :=f.tsaldo1;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=3;
     r.DATO :=f.tsaldo2;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=1;
     r.DATO :=f.tsaldo3;
     return next r;
     
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=4;
     r.DATO :=f.tsaldo4;
     return next r;
    
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800101019000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=5;
     r.DATO :=0;
     return next r;

     pcomercial1:=pcomercial1+f.tsaldo1;
     pcomercial2:=pcomercial2+f.tsaldo2;
     pcomercial3:=pcomercial3+f.tsaldo3;
     pcomercial4:=pcomercial4+f.tsaldo4;

   else 
     if f.pagosvencidos=1 then

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=2;
       r.DATO :=f.tsaldo1;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=3;
       r.DATO :=f.tsaldo2;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=1;
       r.DATO :=f.tsaldo3;
       return next r;
     
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=4;
       r.DATO :=f.tsaldo4;
       return next r;
    
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800201019000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=5;
       r.DATO :=0;
       return next r;

       pcomercial11:=pcomercial11+f.tsaldo1;
       pcomercial12:=pcomercial12+f.tsaldo2;
       pcomercial13:=pcomercial13+f.tsaldo3;
       pcomercial14:=pcomercial14+f.tsaldo4;
     

     else
       if f.pagosvencidos=2 then
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=2;
         r.DATO :=f.tsaldo1;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=3;
         r.DATO :=f.tsaldo2;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=1;
         r.DATO :=f.tsaldo3;
         return next r;
     
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=4;
         r.DATO :=f.tsaldo4;
         return next r;
    
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800501019000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=5;
         r.DATO :=0;
         return next r;

         pcomercial21:=pcomercial21+f.tsaldo1;
         pcomercial22:=pcomercial22+f.tsaldo2;
         pcomercial23:=pcomercial23+f.tsaldo3;
         pcomercial24:=pcomercial24+f.tsaldo4;
       end if;
     end if;
   end if;
 else
 -- Consumo 
 if f.finalidaddefault='002' then 
   ptiposaldo1:=ptiposaldo1+f.tsaldo1;
   ptiposaldo2:=ptiposaldo2+f.tsaldo2;
   ptiposaldo3:=ptiposaldo3+f.tsaldo3;
   ptiposaldo4:=ptiposaldo4+f.tsaldo4;

   if f.pagosvencidos=0 then
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=2;
     r.DATO :=f.tsaldo1;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=3;
     r.DATO :=f.tsaldo2;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=1;
     r.DATO :=f.tsaldo3;
     return next r;
     
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=4;
     r.DATO :=f.tsaldo4;
     return next r;
    
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800102020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=5;
     r.DATO :=0;
     return next r;

     pconsumo1:=pconsumo1+f.tsaldo1;
     pconsumo2:=pconsumo2+f.tsaldo2;
     pconsumo3:=pconsumo3+f.tsaldo3;
     pconsumo4:=pconsumo4+f.tsaldo4;

   else 
     if f.pagosvencidos=1 then

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=2;
       r.DATO :=f.tsaldo1;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=3;
       r.DATO :=f.tsaldo2;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=1;
       r.DATO :=f.tsaldo3;
       return next r;
     
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=4;
       r.DATO :=f.tsaldo4;
       return next r;
    
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800202020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=5;
       r.DATO :=0;
       return next r;

       pconsumo11:=pconsumo11+f.tsaldo1;
       pconsumo12:=pconsumo12+f.tsaldo2;
       pconsumo13:=pconsumo13+f.tsaldo3;
       pconsumo14:=pconsumo14+f.tsaldo4;
     

     else
       if f.pagosvencidos=2 then
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=2;
         r.DATO :=f.tsaldo1;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=3;
         r.DATO :=f.tsaldo2;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=1;
         r.DATO :=f.tsaldo3;
         return next r;
     
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=4;
         r.DATO :=f.tsaldo4;
         return next r;
    
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800502020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=5;
         r.DATO :=0;
         return next r;

         pconsumo21:=pconsumo21+f.tsaldo1;
         pconsumo22:=pconsumo22+f.tsaldo2;
         pconsumo23:=pconsumo23+f.tsaldo3;
         pconsumo24:=pconsumo24+f.tsaldo4;
       end if;
     end if;
   end if;
 else
 --Vivienda
 
 if f.finalidaddefault='003' then 
   ptiposaldo1:=ptiposaldo1+f.tsaldo1;
   ptiposaldo2:=ptiposaldo2+f.tsaldo2;
   ptiposaldo3:=ptiposaldo3+f.tsaldo3;
   ptiposaldo4:=ptiposaldo4+f.tsaldo4;

   if f.pagosvencidos=0 then
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=2;
     r.DATO :=f.tsaldo1;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=3;
     r.DATO :=f.tsaldo2;
     return next r;

     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=1;
     r.DATO :=f.tsaldo3;
     return next r;
     
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=4;
     r.DATO :=f.tsaldo4;
     return next r;
    
     r.CLAVE__ENTIDAD:= pclaveentidad;  
     r.CLAVE_NIVEL_INSTITUCION:=pnivel;
     r.CONCEPTO:='800103020000';
     r.SUBREPORTE :=411;
     r.TIPO_SALDO :=5;
     r.DATO :=0;
     return next r;

     pvivienda1:=pvivienda1+f.tsaldo1;
     pvivienda2:=pvivienda2+f.tsaldo2;
     pvivienda3:=pvivienda3+f.tsaldo3;
     pvivienda4:=pvivienda4+f.tsaldo4;

   else 
     if f.pagosvencidos=1 then

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=2;
       r.DATO :=f.tsaldo1;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=3;
       r.DATO :=f.tsaldo2;
       return next r;

       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=1;
       r.DATO :=f.tsaldo3;
       return next r;
     
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=4;
       r.DATO :=f.tsaldo4;
       return next r;
    
       r.CLAVE__ENTIDAD:= pclaveentidad;  
       r.CLAVE_NIVEL_INSTITUCION:=pnivel;
       r.CONCEPTO:='800203020000';
       r.SUBREPORTE :=411;
       r.TIPO_SALDO :=5;
       r.DATO :=0;
       return next r;

       pvivienda11:=pvivienda11+f.tsaldo1;
       pvivienda12:=pvivienda12+f.tsaldo2;
       pvivienda13:=pvivienda13+f.tsaldo3;
       pvivienda14:=pvivienda14+f.tsaldo4;
     

     else
       if f.pagosvencidos=2 then
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=2;
         r.DATO :=f.tsaldo1;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=3;
         r.DATO :=f.tsaldo2;
         return next r;

         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=1;
         r.DATO :=f.tsaldo3;
         return next r;
     
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=4;
         r.DATO :=f.tsaldo4;
         return next r;
    
         r.CLAVE__ENTIDAD:= pclaveentidad;  
         r.CLAVE_NIVEL_INSTITUCION:=pnivel;
         r.CONCEPTO:='800503020000';
         r.SUBREPORTE :=411;
         r.TIPO_SALDO :=5;
         r.DATO :=0;
         return next r;

         pvivienda21:=pvivienda21+f.tsaldo1;
         pvivienda22:=pvivienda22+f.tsaldo2;
         pvivienda23:=pvivienda23+f.tsaldo3;
         pvivienda24:=pvivienda24+f.tsaldo4;
       end if;
     end if;
   end if;
 end if;

 ---
 end if;
 end if;

end loop;

--Totales

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=ptiposaldo1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=ptiposaldo2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=ptiposaldo3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=ptiposaldo4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800000000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800100000000;Cartera de credito vigente sin pagos vencidos;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial1+pconsumo1+pvivienda1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial2+pconsumo2+pvivienda2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial3+pconsumo3+pvivienda3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial4+pconsumo4+pvivienda4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800100000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800101000000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800101010000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800101010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800102000000;Creditos de consumo;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pconsumo1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pconsumo2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pconsumo3;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pconsumo4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800102000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800103000000;Creditos a la vivienda;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pvivienda1;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pvivienda2;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pvivienda3;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pvivienda4;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800103000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800200000000;Cartera de credito vigente con pagos vencidos;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial11+pconsumo11+pvivienda11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial12+pconsumo12+pvivienda12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial13+pconsumo13+pvivienda13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial14+pconsumo14+pvivienda14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800200000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800201000000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800201010000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800201010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800202000000;Creditos al consumo;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pconsumo11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pconsumo12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pconsumo13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pconsumo14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800202000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800203000000;Creditos a la vivienda;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pvivienda11;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pvivienda12;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pvivienda13;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pvivienda14;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800203000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800500000000;Cartera de credito vencida;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial21+pconsumo21+pvivienda21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial22+pconsumo22+pvivienda22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial23+pconsumo23+pvivienda23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial24+pconsumo24+pvivienda24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800500000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800501000000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800501010000;Creditos comerciales;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pcomercial21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pcomercial22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pcomercial23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pcomercial24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800501010000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800502000000;Creditos al consumo;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pconsumo21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pconsumo22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pconsumo23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pconsumo24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800502000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--411;800503000000;Creditos a la vivienda;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=2;
r.DATO :=pvivienda21;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=3;
r.DATO :=pvivienda22;
return next r;
 
r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=1;
r.DATO :=pvivienda23;
 return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=4;
r.DATO :=pvivienda24;
return next r;

r.CLAVE__ENTIDAD:= pclaveentidad;
r.CLAVE_NIVEL_INSTITUCION:=pnivel;
r.CONCEPTO:='800503000000';
r.SUBREPORTE :=411;
r.TIPO_SALDO :=5;
r.DATO :=0;
return next r;

--- Todas los productos que no se utilizan en la entidad.

--411;800101000000;Creditos comerciales;
--i:=1;
--while i < 6
--loop
--  r.CLAVE__ENTIDAD:= pclaveentidad;
--  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
--  r.CONCEPTO:='800101000000';
--  r.SUBREPORTE :=411;
--  r.TIPO_SALDO :=i;
--  r.DATO :=0;
--  i:=i+1;
--  return next r;
--end loop;
--411;800101010000;Actividad empresarial o comercial;
--i:=1;
--while i < 6
--loop
--  r.CLAVE__ENTIDAD:= pclaveentidad;
--  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
--  r.CONCEPTO:='800101010000';
--  r.SUBREPORTE :=411;
--  r.TIPO_SALDO :=i;
--  r.DATO :=0;
--  i:=i+1;
--  return next r;
--end loop;


--411;800101010100;Operaciones quirografarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010100';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101010200;Operaciones prendarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010200';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101010300;Creditos puente;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010300';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101010400;Operaciones de factoraje;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010400';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101010500;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101010500';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800101020000;Prestamos de liquidez a otras Entidades de Ahorro y Credito Popular;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800101020000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800102010000;Tarjeta de credito;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800102010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800102030000;ABCD;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800102030000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800102040000;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800102040000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800102900000;Otros creditos de consumo;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800102900000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800103010000;Residencial;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800103010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201010000;Actividad empresarial o comercial;
--i:=1;
--while i < 6
--loop
--  r.CLAVE__ENTIDAD:= pclaveentidad;
--  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
--  r.CONCEPTO:='800201010000';
--  r.SUBREPORTE :=411;
--  r.TIPO_SALDO :=i;
--  r.DATO :=0;
--  i:=i+1;
--  return next r;
--end loop;



--411;800201010100;Operaciones quirografarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010100';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800201010200;Operaciones prendarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010200';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201010300;Creditos puente;

i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010300';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201010400;Operaciones de factoraje;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010400';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201010500;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201010500';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800201020000;Prestamos de liquidez a otras Entidades de Ahorro y Credito Popular;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800201020000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800202010000;Tarjeta de credito;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800202010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800202030000;ABCD;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800202030000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800202040000;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800202040000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800202900000;Otros creditos de consumo;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800202900000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800203010000;Media o residencial;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800203010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800501010000;Actividad empresarial o comercial;
--i:=1;
--while i < 6
--loop
--  r.CLAVE__ENTIDAD:= pclaveentidad;
--  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
--  r.CONCEPTO:='800501010000';
--  r.SUBREPORTE :=411;
--  r.TIPO_SALDO :=i;
--  r.DATO :=0;
--  i:=i+1;
--  return next r;
--end loop;

--411;800501010100;Operaciones quirografarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010100';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800501010200;Operaciones prendarias;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010200';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800501010300;Creditos puente;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010300';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800501010400;Operaciones de factoraje;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010400';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800501010500;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501010500';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800501020000;Prestamos de liquidez a otras Entidades de Ahorro y Credito Popular;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800501020000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

--411;800502010000;Tarjeta de credito;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800502010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800502030000;ABCD;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800502030000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800502040000;Operaciones de arrendamiento capitalizable;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800502040000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800502050000;Otros creditos de consumo;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800502050000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;
--411;800503020000;Residencial;
i:=1;
while i < 6
loop
  r.CLAVE__ENTIDAD:= pclaveentidad;
  r.CLAVE_NIVEL_INSTITUCION:=pnivel;
  r.CONCEPTO:='800503010000';
  r.SUBREPORTE :=411;
  r.TIPO_SALDO :=i;
  r.DATO :=0;
  i:=i+1;
  return next r;
end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    
