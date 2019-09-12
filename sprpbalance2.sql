CREATE OR REPLACE FUNCTION sprpbalance2(integer, integer, integer, integer) RETURNS SETOF rrpbalance
    AS $_$
declare

  pejercicio   alias for $1;
  pperiodo     alias for $2;
  pconsolidado alias for $3;
  pmiles       alias for $4;

  sconsolida char(1);
  r rrpbalance%rowtype;

  daytab numeric[2][12]:=array[[31,28,31,30,31,30,31,31,30,31,30,31],
                               [31,29,31,30,31,30,31,31,30,31,30,31]];
  mestab varchar[12]:=array['ENERO','FEBRERO','MARZO',
                            'ABRIL','MAYO','JUNIO',
                            'JULIO','AGOSTO','SEPTIEMBRE',
                            'OCTUBRE','NOVIEMBRE','DICIEMBRE'];
  cf numeric;

  sgerente varchar;
  scontador varchar;
  scontadorsucursal varchar;
  spresidenteadmon varchar;

begin

  --cf:=0;

  --if pconsolidado=1 then
    --r.rubro1:='CONSOLIDADO';
    --r.rubro2:='D-1 Balance General';
    --sconsolida:='S';
  --else
    --r.rubro1:='SUCURSAL';
    --r.rubro2:='D-1 Balance General';
    --sconsolida:='N';
  --end if;
  --r.t1 := NULL;
  --r.t2 := NULL;
  --r.t3 := NULL;
  --r.t4 := NULL;
  --return next r;

  --select nombrecaja into r.rubro1 from empresa where empresaid=1;
  --r.rubro2:=NULL;
  --r.t1 := NULL;
  --r.t2 := NULL;
  --r.t3 := NULL;
  --r.t4 := NULL;
  --return next r;

  --select niveloperaciones into r.rubro1 from empresa where empresaid=1;
  --r.rubro2:=NULL;
  --r.t1 := NULL;
  --r.t2 := NULL;
  --r.t3 := NULL;
  --r.t4 := NULL;
  --return next r;

  --select direccioncaja into r.rubro1 from empresa where empresaid=1;
  --r.rubro2:=NULL;
  --r.t1 := NULL;
  --r.t2 := NULL;
  --r.t3 := NULL;
  --r.t4 := NULL;
  --return next r;

  -- Pendiente validar aÃ±o bisiesto

  --if pconsolidado=1 then
   --r.rubro1:='BALANCE GENERAL CONSOLIDADO AL'||to_char(daytab[1][pperiodo],'99')||' DE '||mestab[pperiodo]||' DE'||to_char(pejercicio,'9999');
  --else
   --r.rubro1:='BALANCE GENERAL AL'||to_char(daytab[1][pperiodo],'99')||' DE '||mestab[pperiodo]||' DE'||to_char(pejercicio,'9999');
  --end if;
  --r.rubro2:=NULL;
  --r.t1 := NULL;
  --r.t2 := NULL;
 -- r.t3 := NULL;
 -- r.t4 := NULL;
 -- return next r;

  --r.rubro1:='EXPRESADO EN MONEDA DE PODER ADQUISITIVO HISTORICO';
 -- r.rubro1:=NULL;
 -- r.rubro2:=NULL;
 -- r.t1 := NULL;
 -- r.t2 := NULL;
  --r.t3 := NULL;
 -- r.t4 := NULL;
 -- return next r;

 -- if pmiles=1 then
 --   r.rubro1:='(CIFRAS EN MILES DE PESOS)';
 --   r.rubro2:=NULL;
 --   r.t1 := NULL;
 --   r.t2 := NULL;
--    r.t3 := NULL;
 --   r.t4 := NULL;
--    return next r;
--  else
 --   r.rubro1:='(CIFRAS EN PESOS)';
 --   r.rubro2:=NULL;
--    r.t1 := NULL;
 --   r.t2 := NULL;
 --   r.t3 := NULL;
 --   r.t4 := NULL;
 --   return next r;
 -- end if;


    --r.rubro1:=NULL;
    --r.rubro2:=NULL;
    --r.t1 := NULL;
    --r.t2 := NULL;
    --r.t3 := NULL;
    --r.t4 := NULL;
     --r.t5 := NULL;
    --return next r;
    
     r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;



    r.rubro1:='CUENTAS DE ORDEN';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;

  r.rubro1:=NULL;
    r.rubro2:=NULL;
  r.t1 := NULL;
    r.t2 := NULL;
   r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
   return next r;
   
   
   
	cf:=saldocuenta('7101',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
    
    r.rubro1:='Avales otorgados';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
    cf:=saldocuenta('7102',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
    
    r.rubro1:='Activos y pasivos contingentes';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
    cf:=saldocuenta('7103',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;

    r.rubro1:='Compromisos crediticios';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
  
    cf:=0;
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;

    r.rubro1:='Bienes en mandato';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
    cf:=saldocuenta('7104',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
    
    r.rubro1:='Bienes en custodia o en administracion';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := 0.00;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
--cf:=saldocuenta('',pejercicio,pperiodo,sconsolida);
    --if pmiles=1 then
      --cf:=cf/1000.00;
    --end if;    
r.rubro1:='Colaterales recibidos por la entidad';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := 0.00;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
    r.rubro1:='Colaterales recibidos y vendidos por la entidad';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := 0.00;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;

	cf:=saldocuenta('7105',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;    
  r.rubro1:='Intereses devengados no cobrados derivados ';
    r.rubro2:=NULL;
    r.t1 := NULL;
   -- r.t2 := cf;
   r.t2:=NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
      r.rubro1:='de cartera de credito vencida';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
    
    
    
    
    
    cf:=saldocuenta('7106',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
        r.rubro1:='Otras cuentas de registro';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := cf*-1;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
   

    cf:=saldocuenta('710501 ',pejercicio,pperiodo,sconsolida);

    if pmiles=1 then
      cf:=cf/1000.00;
    end if;

  

    cf:=saldocuenta('7206 ',pejercicio,pperiodo,sconsolida);

    if pmiles=1 then
      cf:=cf/1000.00;
    end if;

    r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;


    r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;


    --r.rubro1:=NULL;
    --r.rubro2:=NULL;
    --r.t1 := NULL;
    --r.t2 := NULL;
    --r.t3 := NULL;
    --r.t4 := NULL;
     --r.t5 := NULL;
    --return next r;


 --   r.rubro1:='Director / Gerente General';
 --   r.rubro2:='Director de AdministraciÃ³n / Contador General';
 --   r.t1 := NULL;
  --  r.t2 := NULL;
 --   r.t3 := NULL;
 --   r.t4 := NULL;
 --   return next r;


 --   r.rubro1:=NULL;
 --   r.rubro2:=NULL;
 --   r.t1 := NULL;
 --   r.t2 := NULL;
 --   r.t3 := NULL;
 --   r.t4 := NULL;
 --   return next r;

 --   r.rubro1:=NULL;
 --   r.rubro2:=NULL;
--    r.t1 := NULL;
--   r.t2 := NULL;
 --   r.t3 := NULL;
  --  r.t4 := NULL;
  --  return next r;

--    r.rubro1:=NULL;
 --   r.rubro2:=NULL;
 --   r.t1 := NULL;
--    r.t2 := NULL;
--    r.t3 := NULL;
--    r.t4 := NULL;
 --   return next r;

  --  r.rubro1:='______________________________________';
 --   r.rubro2:='______________________________________';
 --   r.t1 := NULL;
  --  r.t2 := NULL;
  --  r.t3 := NULL;
 --   r.t4 := NULL;
 --   return next r;

--select gerente,contador,contadorsucursal,presidenteadmon
 -- into sgerente,scontador,scontadorsucursal,spresidenteadmon
 -- from empresa
-- where empresaid=1;


  --  r.rubro1:=sgerente;
 --   r.rubro2:=scontador;
--    r.t1 := NULL;
 --   r.t2 := NULL;
 --   r.t3 := NULL;
 --   r.t4 := NULL;
 --   return next r;

  --  r.rubro1:=NULL;
  --  r.rubro2:=NULL;
  --  r.t1 := NULL;
  ---  r.t2 := NULL;
  ---  r.t3 := NULL;
   -- r.t4 := NULL;
   -- return next r;


 --   r.rubro1:=NULL;
 --   r.rubro2:=NULL;
 --   r.t1 := NULL;
 --   r.t2 := NULL;
 --   r.t3 := NULL;
 --   r.t4 := NULL;
 --   return next r;

  --  r.rubro1:='Presidente del Consejo de Administracion jjjjjjjjjjjjjjjj';
  --  r.rubro2:=NULL;
 --   r.t1 := NULL;
 ----   r.t2 := NULL;
  --  r.t3 := NULL;
  --  r.t4 := NULL;
 --   return next r;

  --  r.rubro1:=NULL;
 --   r.rubro2:=NULL;
 --   r.t1 := NULL;
 --   r.t2 := NULL;
 --   r.t3 := NULL;
  --  r.t4 := NULL;
 --   return next r;


--    r.rubro1:=NULL;
 --   r.rubro2:=NULL;
 --  r.t1 := NULL;
 --   r.t2 := NULL;
  --  r.t3 := NULL;
  --  r.t4 := NULL;
 --   return next r;

  --  r.rubro1:=NULL;
  --  r.rubro2:=NULL;
  --  r.t1 := NULL;
  --  r.t2 := NULL;
  --  r.t3 := NULL;
  --  r.t4 := NULL;
  --  return next r;

  --  r.rubro1:='______________________________________';
  --  r.rubro2:=NULL;
  --  r.t1 := NULL;
  --  r.t2 := NULL;
  --  r.t3 := NULL;
  --  r.t4 := NULL;
  --  return next r;


   -- r.rubro1:=spresidenteadmon;
    --r.rubro2:=NULL;
   -- r.t1 := NULL;
   -- r.t2 := NULL;
   -- r.t3 := NULL;
   -- r.t4 := NULL;
  --  return next r;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.sprpbalance2(integer, integer, integer, integer) OWNER TO sistema;