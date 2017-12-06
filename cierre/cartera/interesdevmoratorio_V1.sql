CREATE OR REPLACE FUNCTION interesdevmoratorio(integer, date, numeric, integer, character) RETURNS numeric
    AS $_$
declare
  pprestamoid alias for $1;
  pfechacorte alias for $2;
  fsaldoinsoluto alias for $3;
  pdiastraspasovencida alias for $4;
  pmenorvencido alias for $5;

  fpagado numeric;
  fmoratorio numeric;
  fmormenor numeric;
  fmormayor numeric;
  ftasamoratorio numeric;
  r amortizaciones%rowtype;
  diasdespuesdevencido int4;
  diasvencidosletra int4;
  diasvencidosmenor int4;
  diasvencidosmayor int4;
  dfechaprimeradeudo date;
  sclaveestadocredito char(3);
begin

  --raise notice 'Procesando PrestamoID=%',pprestamoid;

  fmoratorio := 0;
  fmormenor := 0;
  fmormayor := 0;

  select p.montoprestamo-fsaldoinsoluto,p.tasa_moratoria,
         p.claveestadocredito
    into fpagado,ftasamoratorio,sclaveestadocredito
    from prestamos p, tipoprestamo t
   where p.prestamoid = pprestamoid and
         t.tipoprestamoid = p.tipoprestamoid;


  -- Calcular solo para los prestamos activos
  
  if sclaveestadocredito='001' then
  --se busca la fecha mas antigua de letras incumplidas
	select min(fechadepago) into dfechaprimeradeudo from amortizaciones
     where prestamoid=pprestamoid and fechadepago<pfechacorte and importeamortizacion<>abonopagado;
	 --se sacan los dias mayor a vencidos de la letra mas antigua es decir 1 dia si tiene 90, 2 si tiene 91,etc... con base a 89 dias --diasdespuesdevencido ya no cambia su valor
	 diasvencidosletra:=pfechacorte-dfechaprimeradeudo;
	 if diasvencidosletra>pdiastraspasovencida then
		diasdespuesdevencido:=diasvencidosletra-pdiastraspasovencida;
	else
		diasdespuesdevencido:=0;
	end if;
  -- Recorrer amortizaciones para ver cuales son las no cubiertas
  -- ya vencidas
  for r in
    select * from amortizaciones
     where prestamoid=pprestamoid and fechadepago<pfechacorte
    order by fechadepago
  loop
    if fpagado<r.importeamortizacion then
      if r.fechadepago<pfechacorte then
        -- Calcular moratorio
			diasvencidosletra:= pfechacorte-r.fechadepago;
			--se calculan los diasvencidosmenor si la letra mayor tiene 120 la deja en 89 y el resto en el que le corresponda
			if (diasvencidosletra-diasdespuesdevencido)>0 then
				diasvencidosmenor:= diasvencidosletra-diasdespuesdevencido;
			else
				diasvencidosmenor:= 0;
			end if;
			
			--los dias vencidos mayor son los dias despues de vencida la letra y se van adicionando las letras que vayan cayendo
			diasvencidosmayor:= diasvencidosletra - diasvencidosmenor;
			
          if pmenorvencido='S'  then
            fmormenor := fmormenor+(r.importeamortizacion-fpagado)*diasvencidosmenor*ftasamoratorio/100/360;  
		  else
            fmormayor := fmormayor+(r.importeamortizacion-fpagado)*diasvencidosmayor*ftasamoratorio/100/360;
          end if;
		  fpagado:=0;
      end if;
    else
      fpagado := fpagado - r.importeamortizacion;
    end if;
    
  end loop;

  if pmenorvencido='S' then
    fmoratorio:=trunc(coalesce(fmormenor,0),6);
  else
    fmoratorio:=trunc(coalesce(fmormayor,0),6);
  end if;

  end if;

return fmoratorio;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;