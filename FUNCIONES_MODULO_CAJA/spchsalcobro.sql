CREATE  or replace FUNCTION spchsalcobro(integer,character,integer,numeric,character) RETURNS text
    AS $_$
declare
  psocioid alias for $1;
  pbanco alias for $2;
  pnumerocheque alias for $3;
  pmonto alias for $4;
  pseriecajero alias for $5;
  
        
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
  pfecha date;
  fmontoprestamo numeric;

  i integer;
  l integer;
  subtotal numeric;
begin
  pformato := '';
  select lineasiniciales, nombrecaja, rfccaja, direccioncaja, sucid
    into plineasiniciales, pnombrecaja, prfccaja, pdireccioncaja, sucursal
    from empresa;
  select usuarioid,current_date
    into pusuarioid,pfecha
    from parametros where serie_user=pseriecajero;
	  plineasiniciales := coalesce(plineasiniciales,0);
	  pnombrecaja := coalesce(pnombrecaja,' ');
	  prfccaja := coalesce(prfccaja,' ');  
	  pdireccioncaja := coalesce(pdireccioncaja,' ');
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
        ||lpad('CAJA: ',30,' ')||'  '||sucursal||chr(13)||chr(10)||
	'SOCIO:    '||s.clavesocioint||lpad('CAJERA: ',20,' ')||pusuarioid ||' '||pfecha||'  '||to_char( now(), 'HH24:MI:SS')||chr(13)||chr(10)||
	'NOMBRE:   '||rtrim(su.nombre)||' '||rtrim(su.paterno)||' '||rtrim(su.materno)|| ' Tipo Socio:'|| s.tiposocioid ||chr(13)||chr(10)||chr(13)||
	lpad('DESCRIPCION DEL MOVIMIENTO',50,' ')||chr(13)||chr(10)||
	'========================================================================'||chr(13)||chr(10)
   	into ptexto1
   	from  socio s,sujeto su
  	where s.socioid = psocioid and
        su.sujetoid = s.sujetoid;	
	
  	pformato := pformato||ptexto1;
	pformato := pformato||chr(13)||chr(10)||lpad('DEPOSITAR AL AHORRO OPORTUNO POR CHEQUE SALVO BUEN COBRO',65,' ')||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||
	lpad('CHEQUE',10,' ')||lpad('IMPORTE',50,' ')||chr(13)||chr(10)||chr(13)||chr(10)||
        lpad(' ',3,' ')  ||' '||pbanco||' '||pnumerocheque||chr(13)||chr(10)||
	lpad('$ ',55,' ')||pmonto||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10); 

 	pformato := pformato||chr(13)||chr(10)||' LOS DOCUMENTOS  DEPOSITADOS  SON  ACEPTADOS SALVO BUEN COBRO'||chr(13)||chr(10)||
                         ' ESTE COMPROBANTE SERA VALIDO CON EL SELLO Y FIRMA DEL CAJERO'||chr(13)||chr(10)||
		         lpad('Sucursal: ',20,' ')||rtrim(sucursal)||' '||pusuarioid||chr(13)||chr(10);    	  

	pformato := pformato||chr(13)||chr(10)||chr(13)||chr(10);

return pformato;
end;
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



