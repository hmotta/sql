CREATE FUNCTION devengainversion(date) RETURNS integer
    AS $_$
declare
  pfecha1 alias for $1;

  r record;

  sserie_user char(2);

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;


  --pultimodevengamiento date;
begin

  sserie_user := 'ZA';

  delete from movipolizas where polizaid in
   (select polizaid from polizas where fechapoliza=pfecha1 and tipo='U');
  delete from polizas where fechapoliza=pfecha1 and tipo='U';

--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha1) as int),cast(date_part('month',pfecha1) as int),'U',sserie_user,'D');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,sserie_user,'U',pnumero_poliza,cast(date_part('year',pfecha1) as int),cast(date_part('month',pfecha1) as int),' ',pfecha1,'D',' ',' ','Devenga Intereses Inversiones',pfecha1);


  -- Realizarlo
  for r in 
    select tipoinversionid,cuentapasivo,cuentaintinvernocob,sum(interesdevengado) as interes
      from (
      select i.inversionid,s.clavesocioint, t.cuentapasivo, t.cuentaintinvernocob, t.tipoinversionid,
       MAX(case when mp.cuentaid=t.cuentaintinver
               then (case when p.fechapoliza<pfecha1
                          then p.fechapoliza
                          else i.fechainversion end)
               else i.fechainversion end) as fechainicial,
       ( pfecha1 -
       COALESCE(MAX(case when mp.cuentaid=t.cuentaintinver
               then (case when p.fechapoliza<pfecha1
                          then p.fechapoliza
                          else i.fechainversion end)
               else i.fechainversion end),i.fechainversion))*i.tasainteresnormalinversion/100/365*i.Depositoinversion
               as InteresDevengado              
  from inversion i, movicaja m, polizas p, movipolizas mp, tipoinversion t, socio s
 where i.fechainversion<pfecha1 and
       m.inversionid = i.inversionid and
       p.polizaid = m.polizaid and
       p.fechapoliza <= pfecha1 and
       t.tipoinversionid = i.tipoinversionid and
       mp.polizaid = p.polizaid and
       s.socioid = i.socioid
group by i.inversionid,s.clavesocioint,i.fechainversion,i.tasainteresnormalinversion,i.depositoinversion,
         t.tipoinversionid, t.cuentapasivo,t.cuentaintinvernocob
having SUM((case when mp.cuentaid=t.cuentapasivo
                 then mp.haber-mp.debe
                 else 0 end))>0 
           ) as t
    group by tipoinversionid,cuentapasivo,cuentaintinvernocob

  loop  
    select *
      into pmovipolizaid
      from spimovipoliza(ppolizaid,r.cuentaintinvernocob,' ','C',r.interes,0,' ',' ','Int. Devengado No Pagado '||r.tipoinversionid);
    select *
      into pmovipolizaid
      from spimovipoliza(ppolizaid,r.cuentapasivo,' ','A',0,r.interes,' ',' ','Int. Devengado No Pagado '||r.tipoinversionid);

  end loop;

return 1;
end
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION public.devengainversion(date) OWNER TO sistema;

--
-- Name: devengainversion(date, date); Type: FUNCTION; Schema: public; Owner: sistema
--
--Es la funcion que se usa actualmente 2015/05/31
CREATE or replace FUNCTION devengainversion(date, date) RETURNS integer
    AS $_$
declare
  pfecha1 alias for $1;
  pfecha2 alias for $2;

  r record;
  r1 record;

  sserie_user char(2);

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;
  pperiodoactual int4;
  pperiodoanterior int4;

  finteresanterior numeric;
  finteresacumulado numeric;
  fpagadodev numeric;

  gdiasanualesinversion int4;
  diniciadevengamiento date;
  ssucid character(4);

begin

  select diasanualesinversion,iniciadevengainversion,sucid
    into gdiasanualesinversion,diniciadevengamiento,ssucid
    from empresa
   where empresaid=1;   

-- Por el momento nadamas tomo el 1er caso donde no hay devengamientos anteriores
-- pendiente terminar programción
-- Se modifico para el devengamiento del mes anterior y actual 28/09/2005

  sserie_user := 'ZA';
  pperiodoactual := cast(date_part('month',pfecha1) as int);
  pperiodoanterior := cast(date_part('month',pfecha2) as int);


  delete from movipolizas where polizaid in
   (select polizaid from polizas where fechapoliza=pfecha1 and tipo='U');
  delete from polizas where fechapoliza=pfecha1 and tipo='U';

--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha1) as int),cast(date_part('month',pfecha1) as int),'U',sserie_user,'D');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,sserie_user,'U',pnumero_poliza,cast(date_part('year',pfecha1) as int),cast(date_part('month',pfecha1) as int),' ',pfecha1,'D',' ',' ','Devenga Intereses Inversiones',pfecha1);

  -- Realizarlo

  -- Periodo Actual

   for r in 
   --Se modifico ya que no tomaba correctamente el devengamiento cuando terminaba una inversion y no habia mas del mismo tipo 2015/05/31
    select sd.fechadegeneracion,sd.cuentapasivo,sd.cuentapasivovencida,sd.cuentaintinvernocob,sum(sd.interes) as interes, sum(sd.interesacumulado) as interesacumulado from 
(select ct.fechadegeneracion,t.cuentapasivo,t.cuentapasivovencida,t.cuentaintinvernocob,sum(ct.intdevmensual) as interes, sum(ct.intdevacumulado) as interesacumulado from inversion i, tipoinversion t, captaciontotal ct where ct.fechadegeneracion=pfecha1 and ct.sucursal=ssucid and ct.inversionid = i.inversionid and t.tipoinversionid = i.tipoinversionid group by ct.fechadegeneracion,t.cuentapasivo,t.cuentapasivovencida,t.cuentaintinvernocob  union select pfecha1,t.cuentapasivo,t.cuentapasivovencida,t.cuentaintinvernocob,0 as interes, 0 as interesacumulado from inversion i, tipoinversion t, captaciontotal ct where ct.fechadegeneracion=pfecha2 and ct.sucursal=ssucid and ct.inversionid = i.inversionid and t.tipoinversionid = i.tipoinversionid group by  ct.fechadegeneracion,t.cuentapasivo,t.cuentapasivovencida,t.cuentaintinvernocob) sd group by sd.fechadegeneracion,sd.cuentapasivo,sd.cuentapasivovencida,sd.cuentaintinvernocob

   loop

     -- Periodo anterior
     finteresanterior:=0;
          
     if pfecha2 > diniciadevengamiento then

        select sum(ct.intdevmensual) as interes, sum(ct.intdevacumulado) as interesacumulado into finteresanterior,finteresacumulado
        from inversion i, tipoinversion t, captaciontotal ct
        where ct.fechadegeneracion=pfecha2 and
          ct.sucursal=ssucid and 
          ct.inversionid = i.inversionid and       
          t.tipoinversionid = i.tipoinversionid
          and t.cuentapasivo = r.cuentapasivo
          group by ct.fechadegeneracion,t.cuentapasivo,t.cuentapasivovencida,t.cuentaintinvernocob;

        finteresanterior:=coalesce(finteresanterior,0);
        finteresacumulado:=coalesce(finteresacumulado,0);

        raise notice 'Procesando caso 1 tipoinversionid %  %  %',finteresacumulado,r.interes,r.interesacumulado;
		--interes acumulado del periodo anterior + el interes generado del periodo actual - interes acumulado del periodo actual
        fpagadodev:= finteresacumulado+r.interes-r.interesacumulado;
        
        select *
        into pmovipolizaid
        from spimovipoliza(ppolizaid,r.cuentaintinvernocob,' ','A',0,fpagadodev,' ',' ','Int. Devengado Pag 1 ');

        select *
        into pmovipolizaid
        from spimovipoliza(ppolizaid,r.cuentapasivovencida,' ','C',fpagadodev,0,' ',' ','Int. Devengado Pag 1 ');


        raise notice 'Procesando caso 3 tipoinversionid  %  %',finteresanterior,r.interes;

        select *
        into pmovipolizaid
        from spimovipoliza(ppolizaid,r.cuentaintinvernocob,' ','C',r.interes,0,' ',' ','Int. Devengado No Pag 3 ');

        select *
        into pmovipolizaid
        from spimovipoliza(ppolizaid,r.cuentapasivovencida,' ','A',0,r.interes,' ',' ','Int. Devengado No Pag 3 ');


     else

       if pfecha2 = diniciadevengamiento then

               raise notice 'Procesando caso 2 tipoinversionid  %  %',finteresanterior,r.interes;

               select *
               into pmovipolizaid
               from spimovipoliza(ppolizaid,r.cuentaintinvernocob,' ','C',r.interesacumulado,0,' ',' ','Int. Dev No Pagado Inicial ');

               select *
               into pmovipolizaid
               from spimovipoliza(ppolizaid,r.cuentapasivovencida,' ','A',0,r.interesacumulado,' ',' ','Int. Dev No Pagado Inicial ');

     

       end if;

     end if;

   end loop;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.devengainversion(date, date) OWNER TO sistema;

