CREATE  OR REPLACE FUNCTION spfolionueva(integer, character,integer) RETURNS text
    AS $_$
declare
  preferenciacaja alias for $1;
  pseriecaja alias for $2;
  pconsaldos alias for $3;
        
  pformato text;
  ptexto text;
  ptexto1 text;

  r record;
  x record;

  plineasiniciales integer;
  pnombrecaja char(80);
  prfccaja char(20);
  pdescripcion char(29);
  pdireccioncaja char(100);
 sucursal char(4); 
 pcuentacaja char(24);
  pusuarioid char(20);
  preferenciaprestamo char(18);
  psaldoprestamo numeric;
  psocio integer;

  fmontoprestamo numeric;
  escheque integer;
  i integer;
  l integer;
  subtotal numeric;
  tipomovicaja int;	
  fcapital numeric;
  fnormal numeric;
  fmoratorio numeric;
  fiva numeric;
  ftotal numeric;
  fisr numeric;
  dfecha date;
  pencabezado integer;
  psucursal char(10);
  supago numeric;
  sucambio numeric;
  esefectivo text;
  entrada text;
  salida  text;
  denomina int;
  denominaretiro int;
begin
  tipomovicaja:=0;
  escheque :=0;
  pformato := '';
  salida := '';
  entrada := '';
  subtotal := 0;
  supago:=0;
  sucambio:=0;
  fcapital := 0;
  fnormal := 0;
  fmoratorio := 0;
  fiva := 0;
  pencabezado := 0;
  denomina:=0;
  denominaretiro=0;
 
  select lineasiniciales, nombrecaja, rfccaja, direccioncaja, sucid
    into plineasiniciales, pnombrecaja, prfccaja, pdireccioncaja, sucursal
    from empresa;


  plineasiniciales := coalesce(plineasiniciales,0);
  pnombrecaja := coalesce(pnombrecaja,' ');
  prfccaja := coalesce(prfccaja,' ');  
  pdireccioncaja := coalesce(pdireccioncaja,' ');

 select cuentacaja, usuarioid
   into pcuentacaja, pusuarioid
   from parametros
  where serie_user = pseriecaja;

 select distinct(m.socioid), p.fechapoliza
   into psocio, dfecha
   from movicaja m, polizas p
  where referenciacaja = preferenciacaja and
        seriecaja = pseriecaja and
        p.polizaid = m.polizaid;
	
 select (current_schemas(false))[2]
   into psucursal;



  for i in 1..plineasiniciales
    loop
      pformato := pformato||chr(13)||chr(10);
    end loop;  

  select
chr(13)||chr(10)
||chr(13)||chr(10)
||chr(13)||chr(10)
||chr(13)||chr(10)
||chr(13)||chr(10)
||chr(13)||chr(15)
        ||'FOLIO:    ' ||alineacero(ltrim(to_char(m.referenciacaja,'999999')))||lpad('CAJA: ',30,' ')||'  '||sucursal||chr(13)||chr(10)||
	'SOCIO:    '||s.clavesocioint||lpad('CAJERA: ',20,' ')||pusuarioid ||' '||to_char(p.fechapoliza,'dd/mm/yyyy')||'  '||to_char( now(), 'HH24:MI:SS')||chr(13)||chr(10)||
	'NOMBRE:   '||rtrim(su.nombre)||' '||rtrim(su.paterno)||' '||rtrim(su.materno)|| ' Tipo Socio:'|| s.tiposocioid ||chr(13)||chr(10)||chr(13)||
	lpad('DESCRIPCION DEL MOVIMIENTO',50,' ')||chr(13)||chr(10)||
'========================================================================'||chr(13)||chr(10)
   into ptexto1
   from movicaja m, polizas p, socio s,sujeto su,domicilio d
  where m.referenciacaja = preferenciacaja and
        m.seriecaja = pseriecaja and
        p.polizaid = m.polizaid and
        s.socioid = m.socioid and
        su.sujetoid = s.sujetoid and
	su.sujetoid = d.sujetoid;	
	
  pformato := pformato||ptexto1;

 l := 7;

--raise notice 'Encabezado %',l;

  pencabezado = 0;
  -- Movimientos

  for r in

  select m.tipomovimientoid, t.desctipomovimiento, (mp.debe-mp.haber) as cantidad, mp.descripcion, m.polizaid
    from movicaja m, polizas p, movipolizas mp, tipomovimiento t
   where m.referenciacaja = preferenciacaja and
         m.seriecaja = pseriecaja and
         m.tipomovimientoid <> '00' and
         m.tipomovimientoid <> 'IN' and
	 p.polizaid = m.polizaid and
         mp.polizaid = p.polizaid and
         mp.movipolizaid = m.movipolizaid and
         t.tipomovimientoid = m.tipomovimientoid

     loop
          if pencabezado = 0 then
	     if l >= 21 then
	        pformato := pformato||chr(13)||chr(10)||ptexto1;
	        l := 7;
	     else
--                pformato := pformato||chr(13)||chr(10);
	     end if;
	     l := l+1;
             pencabezado := 1;     	  	  
	    end if;

--           select descripcion into pdescripcion from movipolizas where polizaid=r.polizaid and cuentaid=pcuentacaja and ( haber = r.cantidad or debe = r.cantidad);
          pdescripcion := coalesce(r.descripcion,' ');

--          pdescripcion := coalesce(pdescripcion,' ');
          if substr(pdescripcion,1,14)='Poliza Aut. de' then
             pdescripcion:= ' ';
	  end if;
                
	  if r.cantidad<0 then
		r.cantidad=r.cantidad*(-1);
		end if;
	  if r.tipomovimientoid='CH' then
	        escheque=1;
	  end if;
          ptexto := 'TU MOVIMIENTO EN '||r.tipomovimientoid||': '||rpad(r.desctipomovimiento,25,' ')||chr(13)||chr(10)
	  ||rpad(pdescripcion,29,' ')||lpad(to_char(r.cantidad,'999,999,999.99'),37,' ')||chr(13)||chr(10);
          subtotal := subtotal+r.cantidad;
	  if l >= 21 then
	  --   pformato := pformato||chr(13)||chr(10)||ptexto1||chr(13)||chr(10)||ptexto;
	     l := 8;
	  else
             pformato := pformato||ptexto;
	  end if;
          l := l+1;	  

     end loop;

  pencabezado := 0;
  

-- Prestamos

  for r in

  select t.cuentaactivo,t.cuentaintnormal,t.cuentaintmora,t.cuentaiva,m.polizaid,p.referenciaprestamo,
         p.prestamoid,p.tipoprestamoid
    from movicaja m, prestamos p, tipoprestamo t
   where m.referenciacaja = preferenciacaja and
         m.seriecaja = pseriecaja and
         m.tipomovimientoid = '00' and
         p.prestamoid=m.prestamoid and
         t.tipoprestamoid=p.tipoprestamoid

     loop

          -- Buscar capital
          select sum(haber-debe)
            into fcapital
            from movipolizas
           where polizaid=r.polizaid and
                 cuentaid=r.cuentaactivo;

          -- Buscar interes normal
          select sum(haber-debe)
            into fnormal
            from movipolizas
           where polizaid=r.polizaid and
                 cuentaid=r.cuentaintnormal;

          -- Buscar interes moratorio
          select sum(haber-debe)
            into fmoratorio
            from movipolizas
           where polizaid=r.polizaid and
                 cuentaid=r.cuentaintmora;

          -- Buscar iva
          select sum(haber-debe)
            into fiva
            from movipolizas
           where polizaid=r.polizaid and
                 cuentaid=r.cuentaiva;
	--- buscar tipomovicaja
	    select efectivo
            into tipomovicaja
            from movicaja
          where polizaid=r.polizaid;
           if      tipomovicaja=1 or tipomovicaja=5 then
		  -- Buscar Cta Caja
		  select sum(debe-haber)
		    into ftotal
		    from movipolizas
		  where polizaid=r.polizaid and
                cuentaid=pcuentacaja;
	   else
		select sum(debe)
		    into ftotal
		    from movipolizas
		  where polizaid=r.polizaid and
                cuentaid=pcuentacaja;
	   end if;

          fcapital:=coalesce(fcapital,0);
          fnormal:=coalesce(fnormal,0);
          fmoratorio:=coalesce(fmoratorio,0);
          fiva:=coalesce(fiva,0);

          select montoprestamo into fmontoprestamo
            from prestamos where prestamoid=r.prestamoid;

          -- Buscar Saldo del prestamo
                SELECT fmontoprestamo-sum(haber) as saldo 
                  into psaldoprestamo
                  from movicaja m, polizas p,movipolizas mp
                 where m.prestamoid = r.prestamoid and
                       p.polizaid=m.polizaid and
                       p.fechapoliza < dfecha+1 and
                       mp.polizaid=m.polizaid and
                       mp.cuentaid = r.cuentaactivo;

	  psaldoprestamo:=coalesce(psaldoprestamo,fmontoprestamo);

          if pencabezado = 0 then
	     if l >= 21 then
	        pformato := pformato||chr(13)||chr(10)||ptexto1||chr(13)||chr(10)||
			 ' Tu pago al Prestamo con saldo '||fcapital+psaldoprestamo||' fue:'||chr(13)||chr(10)||
'     Capital       Int. Normal     Int. Moratorio     I.V.A.      Total'||chr(13)||chr(10);
	        l := 8;
	     else

                pformato := pformato||
                         ' Tu pago al Prestamo con saldo '||fcapital+psaldoprestamo||' fue:'||chr(13)||chr(10)||
'     Capital       Int. Normal     Int. Moratorio     I.V.A.      Total'||chr(13)||chr(10);
	     end if;
	     l := l+1;
             pencabezado := 1;     
          end if;

          ptexto := lpad(to_char(fcapital,'9,999,999.99'),13,' ')||' '||
                    to_char(fnormal,'9,999,999.99')||'  '||
                    to_char(fmoratorio,'9,999,999.99')||' '||
                    to_char(fiva,'9,999,999.99')||'  '||
		    to_char(ftotal,'9,999,999.99')||chr(13)||chr(10)||
                    ' Tu saldo actual en prestamo '||r.tipoprestamoid||'  '||r.referenciaprestamo||' es  '||
                    ltrim(to_char(psaldoprestamo,'9,999,999.99'))||chr(13)||chr(10);
          subtotal := subtotal + ftotal;

          
	  if l >= 21 then
	     pformato := pformato||chr(13)||chr(10)||ptexto1||chr(13)||chr(10)||ptexto;
	     l := 8;
	  else
             pformato := pformato||ptexto;
	  end if;

	  --raise notice ' voy aqui buscando prestamos % % % % %',fcapital,fnormal,fiva,fmoratorio,ftotal;          

	  l := l+2;		    

     end loop;

    -- raise notice 'Prestamos % %',l,pformato;


  pencabezado := 0;
-- Inversiones

    for x in
  select t.cuentapasivo,t.cuentaintinver,t.cuentaivainver,t.cuentariesgocred,m.polizaid
    from movicaja m, inversion v, tipoinversion t
   where m.referenciacaja = preferenciacaja and
         m.seriecaja = pseriecaja and
         m.tipomovimientoid = 'IN' and
         v.inversionid = m.inversionid and
         t.tipoinversionid = v.tipoinversionid

    loop

          -- Buscar capital
          select sum(haber-debe)
            into fcapital
            from movipolizas
           where polizaid=x.polizaid and
                 cuentaid=x.cuentapasivo;

          -- Buscar interes
          select sum(haber-debe)
            into fnormal
            from movipolizas
           where polizaid=x.polizaid and
                 cuentaid=x.cuentaintinver;

          -- Buscar iva
          select sum(haber-debe)
            into fiva
            from movipolizas
           where polizaid=x.polizaid and
                 cuentaid=x.cuentaivainver;

          -- Buscar ISR
          select sum(haber-debe)
            into fisr
            from movipolizas
           where polizaid=x.polizaid and
                 cuentaid=x.cuentariesgocred;

          -- Buscar Cta Caja
          select sum(debe-haber)
            into ftotal
            from movipolizas
           where polizaid=x.polizaid and
                 cuentaid=pcuentacaja;

          fcapital:=coalesce(fcapital,0);
          fnormal:=coalesce(fnormal,0);
          fiva:=coalesce(fiva,0);
          fisr:=coalesce(fisr,0);

          if pencabezado = 0 then
	     if l >= 21 then
	        pformato := pformato||chr(13)||chr(10)||ptexto1||chr(13)||chr(10)||
			 '           Concepto                           Movimiento'||chr(13)||chr(10);
	        l := 8;
	     else
		pformato := pformato||	 '           Concepto                  Movimiento'||chr(13)||chr(10);	     
	     end if;	  	  
             pencabezado := 1;
	     l := l+2;
          end if;
	  
          ptexto := lpad('Capital        :  ',25,' ')||to_char(fcapital,'999,999,999.99')||'     '||chr(13)||chr(10)||
                    lpad('Interes Normal :  ',25,' ')||to_char(fnormal,'999,999,999.99')||'     '||chr(13)||chr(10)||
                    lpad('I.V.A.         :  ',25,' ')||to_char(fiva,'999,999,999.99')||'     '||chr(13)||chr(10)||
                    lpad('I.S.R.         :  ',25,' ')||to_char(fisr,'999,999,999.99')||'     '||chr(13)||chr(10)||
		    lpad('T o t a l: ',24,' ')||' '||to_char(ftotal,'999,999,999.99')||chr(13)||chr(10)||chr(13)||chr(10);
          l := l+2;		    
          subtotal := subtotal + ftotal;
	  if l >= 21 then
	     --pformato := pformato||chr(13)||chr(10)||ptexto1||chr(13)||chr(10)||ptexto;
	     pformato := pformato||chr(13)||chr(10)||ptexto;
	     l := 8;
	  else
             pformato := pformato||ptexto;
	  end if;
	  l := l+2;		    
     end loop;     
   
   if pencabezado <> 0 then
	select denominacionid
	   into denomina
	   from sabana 
	  where referenciacaja = preferenciacaja and 
	       seriecaja = pseriecaja and
	entradasalida=0;
	       
            if denomina <=14 then
	         entrada = 'EFECTIVO';
	    end if;
	if denomina = 15 then
	         entrada = 'CHEQUE';
	    end if;
	if denomina = 16 then
	         entrada = 'TRANSFERENCIA INTERNA';
	    end if;
	if denomina = 18 then
	         entrada = 'TRANSFERENCIA BANCARIA';
	    end if;
	if denomina>0 then
	pformato := pformato||'  INVERSION'||chr(13)||chr(10)||
		  '  PAGO CON          '||entrada||chr(13)||chr(10)||chr(13)||chr(10)||
                  'Saldos en movimientos:'||chr(13)||chr(10);
	end if;
      
	select denominacionid
	   into denominaretiro
	   from sabana 
	  where referenciacaja = preferenciacaja and 
	       seriecaja = pseriecaja and
	entradasalida=1;
	if denominaretiro <=14 then
	         salida = 'EFECTIVO';
	    end if;
	if denominaretiro = 15 then
	         salida = 'CHEQUE';
	    end if;
	if denominaretiro = 16 then
	         salida = 'TRANSFERENCIA INTERNA';
	    end if;
	if denominaretiro = 18 then
	         salida = 'TRANSFERENCIA BANCARIA';
	    end if;
	if denominaretiro>0 then
	pformato := pformato||'  INVERSION'||chr(13)||chr(10)||
		  '  PAGO CON          '||salida||chr(13)||chr(10)||chr(13)||chr(10)||
                  'Saldos en movimientos:'||chr(13)||chr(10);
	end if;
      l := l+3;
      pencabezado:=5;
   end if;

-- Total
   if pencabezado <> 5 then
     ptexto := lpad('T O T A L:           ',47,' ')||'   '||to_char(subtotal,'$999,999,999.99')||chr(13)||chr(10);
     if l >= 21 then
       -- pformato := pformato||chr(13)||chr(10)||ptexto1||chr(13)||chr(10)||ptexto||
	pformato := pformato||chr(13)||chr(10)||ptexto||
                    'Saldos en movimientos:'||chr(13)||chr(10);
        l := 8;
     else
        pformato := pformato||ptexto||
                    'Saldos en movimientos:'||chr(13)||chr(10);
     end if;
     l := l+2;
   end if;

--  raise notice 'Total %',l;
  
-- Saldos
   if pconsaldos=1 then
		  for r in
		  select * from spssaldosmovf(psocio,dfecha) where saldo>0 
	   loop
			 ptexto := '          '||rpad(r.desctipomovimiento,30,' ')||'          '||
					   to_char(r.saldo,'$999,999,999.99')||chr(13)||chr(10);
			 if l >= 21 then
				 --pformato := pformato||chr(13)||chr(10)||ptexto1||chr(13)||chr(10)||ptexto;
				 pformato := pformato||chr(13)||chr(10)||ptexto;
				 l := 8;
			 else
				 pformato := pformato||ptexto;
			 end if;		   
		 l := l+1;
	   end loop;
   end if;
--  raise notice 'Saldos %',l;   


-- FORMA DE PAGO
   if pencabezado <> 5 then
         select sum(valor)
	   into supago
	   from sabana
	  where referenciacaja = preferenciacaja and 
	        seriecaja = pseriecaja and
		entradasalida=0;
	
		
	supago := coalesce(supago,0);
	
	 
	 select denominacionid
	   into denomina
	   from sabana 
	  where referenciacaja = preferenciacaja and 
	       seriecaja = pseriecaja and
	entradasalida=0;
	       
            if denomina <=14 then
	         entrada = 'EFECTIVO';
	    end if;
	if denomina = 15 then
	         entrada = 'CHEQUE';
	    end if;
	if denomina = 16 then
	         entrada = 'TRANSFERENCIA INTERNA';
	    end if;
	if denomina = 18 then
	         entrada = 'TRANFER BANCARIA DEP EN EFECTIVO';
	    end if;
	if denomina = 19 then
	         entrada = 'TRANSFER BANCARIA DEP EN CHEQUE';
	    end if;
	if denomina = 20 then
	         entrada = 'TRANSFER BANCARIA DEP EN TRANSFER';
	    end if;
       
        -- if 	denomina> 14 then

	  -- 	ptexto := chr(13)||chr(10)||'   RECIBIDO '||to_char(supago,'$999,999.99')||
        --                  chr(13)||chr(10)||'   PAGO CON          '||salida||chr(13)||chr(10);
	--else
		if supago=0 then
			subtotal=0;
		end if;
		if 	denomina> 0 then
			IF sucambio>0 then	
			      if escheque>0 then
				      ptexto := chr(13)||chr(10)||'   RECIBIDO '||to_char(subtotal,'$999,999.99')||
				      chr(13)||chr(10)||'   SU PAGO       '||to_char(supago,'$999,999.99')||
				      chr(13)||chr(10)||'   PAGO CON          '||entrada||
				      chr(13)||chr(10)||'   SU CAMBIO     '||to_char(sucambio,'$999,999.99')||
				      chr(13)||chr(10)||'   RETIRO CON          '||salida||chr(13)||chr(10)||chr(13)||chr(10);
			      else
				      ptexto := chr(13)||chr(10)||'   RECIBIDO '||to_char(supago,'$999,999.99')||
				      chr(13)||chr(10)||'   SU PAGO       '||to_char(subtotal,'$999,999.99')||
				      chr(13)||chr(10)||'   PAGO CON          '||entrada||
				      chr(13)||chr(10)||'   SU CAMBIO     '||to_char(sucambio,'$999,999.99')||
				      chr(13)||chr(10)||'   RETIRO CON          '||salida||chr(13)||chr(10)||chr(13)||chr(10);
			      end if;
			else
			      ptexto := chr(13)||chr(10)||'   RECIBIDO '||to_char(supago,'$999,999.99')||
		              chr(13)||chr(10)||'   SU PAGO       '||to_char(subtotal,'$999,999.99')||
			      chr(13)||chr(10)||'   PAGO CON          '||entrada||chr(13)||chr(10)||chr(13)||chr(10);
			end if;
		end if;
	--end if;

	select sum(valor)
	   into sucambio
	   from sabana
	  where referenciacaja = preferenciacaja and 
	        seriecaja = pseriecaja and
		entradasalida=1;
	sucambio := coalesce(sucambio,0);
	select denominacionid
	   into denominaretiro
	   from sabana 
	  where referenciacaja = preferenciacaja and 
	       seriecaja = pseriecaja and
	entradasalida=1;
	if denominaretiro <=14 then
	         salida = 'EFECTIVO';
	    end if;
	if denominaretiro = 15 then
	         salida = 'CHEQUE';
	    end if;
	if denominaretiro = 16 then
	         salida = 'TRANSFERENCIA INTERNA';
	    end if;
	if denominaretiro = 18 then
	         salida = 'TRANSFERENCIA BANCARIA';
	    end if;
       
       --  if 	denominaretiro> 14 then

	   --	ptexto := chr(13)||chr(10)||'   RECIBIDO '||to_char(supago,'$999,999.99')||
             --             chr(13)||chr(10)||'   RETIRO CON          '||salida||chr(13)||chr(10);
	--else
		if supago=0 then
			subtotal=0;
		end if;
		if denominaretiro> 0 then
		      if subtotal>0 then
			      if escheque>0 then
				      ptexto := chr(13)||chr(10)||'   RECIBIDO '||to_char(subtotal,'$999,999.99')||
				      chr(13)||chr(10)||'   SU PAGO       '||to_char(supago,'$999,999.99')||
				      chr(13)||chr(10)||'   PAGO CON          '||entrada||
				      chr(13)||chr(10)||'   SU CAMBIO     '||to_char(sucambio,'$999,999.99')||
				      chr(13)||chr(10)||'   RETIRO CON          '||salida||chr(13)||chr(10)||chr(13)||chr(10);
			      else
				      ptexto := chr(13)||chr(10)||'   RECIBIDO '||to_char(supago,'$999,999.99')||
				      chr(13)||chr(10)||'   SU PAGO       '||to_char(subtotal,'$999,999.99')||
				      chr(13)||chr(10)||'   PAGO CON          '||entrada||
				      chr(13)||chr(10)||'   SU CAMBIO     '||to_char(sucambio,'$999,999.99')||
				      chr(13)||chr(10)||'   RETIRO CON          '||salida||chr(13)||chr(10)||chr(13)||chr(10);
	
			      end if;
		      else 
			      ptexto :=chr(13)||chr(10)||'   SU CAMBIO     '||to_char(sucambio,'$999,999.99')||
		              chr(13)||chr(10)||'   RETIRO CON          '||salida||chr(13)||chr(10)||chr(13)||chr(10);
		      end if;
		end if;
	--end if;

         if l >= 21 then
             --pformato := pformato||chr(13)||chr(10)||ptexto1||chr(13)||chr(10)||ptexto;
	     pformato := pformato||chr(13)||chr(10)||ptexto;	
             l := 8;
         else
             pformato := pformato||ptexto;
         end if;		   
	 l := l+1;      	       
    end if;


-- Usuario y Sucursal
   if l = 17 then
     pformato := pformato||chr(13)||chr(10)||
                 ' LOS DOCUMENTOS  DEPOSITADOS  SON  ACEPTADOS SALVO BUEN COBRO'||chr(13)||chr(10)||
                 ' ESTE COMPROBANTE SERA VALIDO CON EL SELLO Y FIRMA DEL CAJERO'||chr(13)||chr(10)||
		 '      '||rtrim(psucursal)||' - '||pusuarioid||chr(13)||chr(10);
     l := l+4;
   else
     if l < 19 then
       for f in l..17
       loop
          pformato := pformato||chr(13)||chr(10);
	  l:= l+1;
       end loop;
       pformato := pformato||' LOS DOCUMENTOS  DEPOSITADOS  SON  ACEPTADOS SALVO BUEN COBRO'||chr(13)||chr(10)||
                   ' ESTE COMPROBANTE SERA VALIDO CON EL SELLO Y FIRMA DEL CAJERO'||chr(13)||chr(10)||
		   '      '||rtrim(psucursal)||' - '||pusuarioid||chr(13)||chr(10);    
       l := l+3;
     else
        if l = 19 then
          pformato := pformato||' LOS DOCUMENTOS  DEPOSITADOS  SON  ACEPTADOS SALVO BUEN COBRO'||chr(13)||chr(10)||
                   ' ESTE COMPROBANTE SERA VALIDO CON EL SELLO Y FIRMA DEL CAJERO'||chr(13)||chr(10);
	  l := l+2;
        else
	  if l = 20 then
             pformato := pformato||'     '||rtrim(psucursal)||' - '||rtrim(pusuarioid)||
	                 lpad('_________________________',130-length('     '||rtrim(psucursal)||' - '||rtrim(pusuarioid)))||chr(13)||chr(10);
	     l := l+1;         
	  else
            -- pformato := pformato||ptexto1||' LOS DOCUMENTOS  DEPOSITADOS  SON  ACEPTADOS SALVO BUEN COBRO'||chr(13)||chr(10)||
 		pformato := pformato||chr(13)||chr(10)||' LOS DOCUMENTOS  DEPOSITADOS  SON  ACEPTADOS SALVO BUEN COBRO'||chr(13)||chr(10)||
                         ' ESTE COMPROBANTE SERA VALIDO CON EL SELLO Y FIRMA DEL CAJERO'||chr(13)||chr(10)||
		         '      '||rtrim(psucursal)||' - '||pusuarioid||chr(13)||chr(10);    	  
	  end if;
        end if;
     end if;
   end if;     

--  raise notice 'Final %',l;

   pformato := pformato||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10);

return pformato;
end;
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



