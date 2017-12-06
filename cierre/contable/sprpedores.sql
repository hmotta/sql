CREATE FUNCTION sprpedores(integer, integer, integer, integer) RETURNS SETOF rrpedores
    AS $_$
declare

  pejercicio   alias for $1;
  pperiodo     alias for $2;
  pconsolidado alias for $3;
  pmiles       alias for $4;

  sconsolida char(1);
  r rrpedores%rowtype;

  daytab numeric[2][12]:=array[[31,28,31,30,31,30,31,31,30,31,30,31],
                               [31,29,31,30,31,30,31,31,30,31,30,31]];
  mestab varchar[12]:=array['ENERO','FEBRERO','MARZO',
                            'ABRIL','MAYO','JUNIO',
                            'JULIO','AGOSTO','SEPTIEMBRE',
                            'OCTUBRE','NOVIEMBRE','DICIEMBRE'];

	fresultado numeric;
	fresultadoa numeric;
	fingresos numeric;
	fingresosa numeric;
	fgastosxintm numeric;
	fgastosxinta numeric;
	fmargfinanm numeric;
	fmargfinana numeric;
	rxposmonnetom numeric;
	rxposmonnetoa numeric;
	estprevriscredm numeric;
	estprevriscreda numeric;
	comytarfcobm numeric;
	comytarfcoba numeric;
	comytarfpagm numeric;
	comytarfpaga numeric;
	rxintemedm numeric;
	rxintemeda numeric;
	otringegroprm numeric;
	otringegropra numeric;
	gtosadminm numeric;
	gtosadmina numeric;
	gtosadminm2 numeric;
	gtosadmina2 numeric;
	reoperacionm numeric;
	reoperaciona numeric;
	parresulm numeric;
	parresula numeric;
	resulantopem numeric;
	resulantopea numeric;
	oprdiscontm numeric;
	oprdisconta numeric;
	resultadonetom numeric;
	resultadonetoa numeric;
	cf numeric;
	cfa numeric;
	cf2 numeric;
	cfa2 numeric;
	cf3 numeric;
	cfa3 numeric;
	cfm numeric;
	t1 numeric;
	t2 numeric;
	sgerente varchar;
	scontador varchar;
	scontadorsucursal varchar;
	spresidenteadmon varchar;

begin
  fresultado:=0;
  if pconsolidado=1 then
    --r.rubro1:='CONSOLIDADO                           D-2 Estado de Resultados';
    sconsolida:='S';
  else
    --r.rubro1:='SUCURSAL                              D-2 Estado de Resultados';
    sconsolida:='N';
  end if;
  return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	--select nombrecaja||'  '||sucid into r.rubro1 from empresa where empresaid=1;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	--select niveloperaciones into r.rubro1 from empresa where empresaid=1;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	--select direccioncaja into r.rubro1 from empresa where empresaid=1;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

  -- Pendiente validar año bisiesto
  if pconsolidado=1 then
   --r.rubro1:='ESTADO DE RESULTADOS CONSOLIDADO DEL 01 DE ENERO AL'||to_char(daytab[1][pperiodo],'99')||' DE '||mestab[pperiodo]||' DE'||to_char(pejercicio,'9999');
  else
   --r.rubro1:='ESTADO DE RESULTADOS DE SUCURSAL DEL 01 DE ENERO AL'||to_char(daytab[1][pperiodo],'99')||' DE '||mestab[pperiodo]||' DE'||to_char(pejercicio,'9999');
  end if;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	--r.rubro1:='EXPRESADO EN MONEDA DE PODER ADQUISITIVO HISTORICO';
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

  if pmiles=1 then
	--r.rubro1:='(CIFRAS EN MILES DE PESOS)';
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
 		else
		--r.rubro1:='(CIFRAS EN PESOS)';
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	end if;


	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;


	--r.rubro1:='MENSUAL';
	r.rubro1:='MENSUAL';
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	 r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	 r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	 r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;
	
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	fingresos:=saldomensual('5101               ',pejercicio,pperiodo,sconsolida)*-1;
		if (pmiles=1) then
			fingresos:=fingresos/1000.00;
		end if;
	
	fingresosa:=saldocuenta('5101               ',pejercicio,pperiodo,sconsolida)*-1;
		if (pmiles=1) then
			fingresosa:=fingresosa/1000.00;
		end if;

			
	r.rubro1:='Ingresos por intereses';
	r.t1 := NULL;
	r.t2 := fingresos;
	r.t3 := NULL;
	r.t4 := fingresosa;
	return next r;
	
	
	fgastosxintm:=saldomensual('5102               ',pejercicio,pperiodo,sconsolida);
		if (pmiles=1) then
			fgastosxintm:=fgastosxintm/1000.00;
		end if;
			--fgastosxintm:=fgastosxintm;
	fgastosxinta:=saldocuenta ('5102               ',pejercicio,pperiodo,sconsolida);
		if (pmiles=1) then
			fgastosxinta:=fgastosxinta/1000.00;
		end if;
			--fgastosxinta:=fgastosxinta;
			
	r.rubro1:='Gastos por intereses';
	r.t1 := NULL;
	r.t2 := fgastosxintm;
	r.t3 := NULL;
	r.t4 := fgastosxinta;
	return next r;
	
	rxposmonnetom:=saldomensual('5103               ',pejercicio,pperiodo,sconsolida);
		if (pmiles=1) then
			rxposmonnetom:=rxposmonnetom/1000.00;
		end if;
			--cfm:=cfm;
	rxposmonnetoa:=saldocuenta ('5103               ',pejercicio,pperiodo,sconsolida);
		if (pmiles=1) then
			rxposmonnetoa:=rxposmonnetoa/1000.00;
		end if;
			
	r.rubro1:='Resultado por posicion monetaria neto (margen financiero)';
	r.t1 := NULL;
	r.t2 := rxposmonnetom;
	r.t3 := NULL;
	r.t4 := rxposmonnetoa;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := -0.001;
	r.t3 := NULL;
	r.t4 := -0.001;
	return next r;

	fmargfinanm:= (fingresos - fgastosxintm) - (rxposmonnetom);
	fmargfinana:= (fingresosa - fgastosxinta) - (rxposmonnetoa);
	
	r.rubro1:='MARGEN FINANCIERO';
	r.t1 := NULL;
	r.t2 := fmargfinanm;
	r.t3 := NULL;
	r.t4 := fmargfinana;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	estprevriscredm:=saldomensual('5104               ',pejercicio,pperiodo,sconsolida);
	estprevriscreda:=saldocuenta ('5104               ',pejercicio,pperiodo,sconsolida);

	if (pmiles=1) then
		estprevriscredm:=estprevriscredm/1000.00;
		estprevriscreda:=estprevriscreda/1000.00;
	end if;

	r.rubro1:='Estimacion preventiva para riesgos crediticios';
	r.t1 := NULL;
	r.t2 := estprevriscredm;
	r.t3 := NULL;
	r.t4 := estprevriscreda;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := -0.001;
	r.t3 := NULL;
	r.t4 := -0.001;
	return next r;

	r.rubro1:='MARGEN FINANCIERO AJUSTADO POR RIESGOS CREDITICIOS';
	r.t1 := NULL;
	r.t2 := fmargfinanm-estprevriscredm;
	r.t3 := NULL;
	r.t4 := fmargfinana-estprevriscreda;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	comytarfcoba:=-1*saldocuenta ('6101               ',pejercicio,pperiodo,sconsolida);
	comytarfcobm:=-1*saldomensual('6101               ',pejercicio,pperiodo,sconsolida);

	if (pmiles=1) then
		comytarfcoba:=comytarfcoba/1000.00;
		comytarfcobm:=comytarfcobm/1000.00;
	end if;

	r.rubro1:='Comisiones y tarifas cobradas';
	r.t1 := comytarfcobm;
	r.t2 := NULL;
	r.t3 := comytarfcoba;
	r.t4 := NULL;
	return next r;

	fresultadoa:=fresultadoa+comytarfcoba;
	fresultado:=fresultado+comytarfcobm;
	comytarfpaga:=saldocuenta ('6102               ',pejercicio,pperiodo,sconsolida);
	comytarfpagm:=saldomensual('6102               ',pejercicio,pperiodo,sconsolida);

	if (pmiles=1) then
		comytarfpaga:=comytarfpaga/1000.00;
		comytarfpagm:=comytarfpagm/1000.00;
	end if;

	r.rubro1:='Comisiones y tarifas pagadas';
	r.t1 := comytarfpagm;
	r.t2 := NULL;
	r.t3 := comytarfpaga;
	r.t4 := NULL;
	return next r;

	rxintemedm:=saldomensual('6103               ',pejercicio,pperiodo,sconsolida)*-1;
		if (pmiles=1) then
			rxintemedm:=rxintemedm/1000.00;
		end if;
	rxintemeda:=saldocuenta('6103               ',pejercicio,pperiodo,sconsolida)*-1;
		if (pmiles=1) then
			rxintemeda:=rxintemeda/1000.00;
		end if;
	 
	r.rubro1:='Resultado por intermediacion';
	r.t1 := rxintemedm;
	r.t2 := NULL;
	r.t3 := rxintemeda;
	r.t4 := NULL;
	return next r;

	otringegroprm:=saldomensual('63               ',pejercicio,pperiodo,sconsolida)*-1;
		if (pmiles=1) then
			otringegroprm:=otringegroprm/1000.00;
		end if;
	otringegropra:=saldocuenta ('63               ',pejercicio,pperiodo,sconsolida)*-1;
		if (pmiles=1) then
			otringegropra:=otringegropra/1000.00;
		end if;
	 
	r.rubro1:='Otros ingresos (egresos) de la operacion';
	r.t1 := otringegroprm;
	r.t2 := NULL;
	r.t3 := otringegropra;
	r.t4 := NULL;
	return next r;
	
	gtosadminm:=saldomensual('62               ',pejercicio,pperiodo,sconsolida);
		if (pmiles=1) then
			gtosadminm:=gtosadminm/1000.00;
		end if;
	gtosadmina:=saldocuenta('62               ',pejercicio,pperiodo,sconsolida);
		if (pmiles=1) then
			gtosadmina:=gtosadmina/1000.00;
		end if;
	 
	 gtosadminm2:= comytarfcobm-comytarfpagm-rxintemedm+otringegroprm-gtosadminm;
	 gtosadmina2:= comytarfcoba-comytarfpaga-rxintemeda+otringegropra-gtosadmina;
	 
	r.rubro1:='Gastos de administracion y promocion';
	r.t1 := gtosadminm;
	r.t2 := gtosadminm2;
	r.t3 := gtosadmina;
	r.t4 := gtosadmina2;
	return next r;
	
	fresultadoa:=fresultadoa+cfa;
	fresultado:=fresultado+cf;

	r.rubro1:=NULL;
	r.t1 := -0.001;
	r.t2 := -0.001;
	r.t3 := -0.001;
	r.t4 := -0.001;
	return next r;

	reoperacionm:=(fmargfinanm-estprevriscredm)+gtosadminm2;
	reoperaciona:=(fmargfinana-estprevriscreda)+gtosadmina2;
	
	r.rubro1:='RESULTADO DE LA OPERACION';
	r.t1 := NULL;
	r.t2 := reoperacionm;
	r.t3 := NULL;
	r.t4 := reoperaciona;
	return next r;
	
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	parresula:=-1*(saldocuenta ('65               ',pejercicio,pperiodo,sconsolida));
	parresulm:=-1*(saldomensual('65               ',pejercicio,pperiodo,sconsolida));

	if (pmiles=1) then
		parresula:=parresula/1000.00;
		parresulm:=parresulm/1000.00;
	end if;

	r.rubro1:='Participacion en el resultado de subsidiarias no consolidadas y asociadas';
	r.t1 := NULL;
	r.t2 := parresulm;
	r.t3 := NULL;
	r.t4 := parresula;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 :=-0.001;
	r.t3 := NULL;
	r.t4 := -0.001;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 :=NULL;
	r.t3 := NULL;
	r.t4 :=NULL;
	return next r;


	resulantopem:=reoperacionm+parresulm;
	resulantopea:=reoperaciona+parresula;

	r.rubro1:='RESULTADO ANTES DE OPERACIONES DISCONTINUADAS';
	r.t1 := NULL;
	r.t2 := resulantopem;
	r.t3 := NULL;
	r.t4 := resulantopea;
	return next r;
	
	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;


	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	oprdiscontm:=-1*(saldocuenta ('66               ',pejercicio,pperiodo,sconsolida));
	oprdisconta:=-1*(saldomensual('66               ',pejercicio,pperiodo,sconsolida));

	if (pmiles=1) then
		oprdisconta:=oprdisconta/1000.00;
		oprdiscontm:=oprdiscontm/1000.00;
	end if;

	r.rubro1:='Operaciones discontinuas';
	r.t1 := NULL;
	r.t2 := oprdiscontm;
	r.t3 := NULL;
	r.t4 := oprdisconta;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := -0.001;
	r.t3 := NULL;
	r.t4 := -0.001;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

		resultadonetom:=resulantopem-oprdiscontm;
		resultadonetoa:=resulantopea-oprdisconta;

	r.rubro1:='RESULTADO NETO';
	r.t1 := NULL;
	r.t2 := resultadonetom;
	r.t3 := NULL;
	r.t4 := resultadonetoa;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 :=-0.002;
	r.t3 := NULL;
	r.t4 :=-0.002;
	return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;


	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;

	select gerente,contador,contadorsucursal,presidenteadmon
	into sgerente,scontador,scontadorsucursal,spresidenteadmon
	from empresa
	where empresaid=1;

	--r.rubro1:='GG:'||sgerente||':'||spresidenteadmon;
	--r.t1 := NULL;
	--r.t2 := NULL;
	--r.t3 := NULL;
	--r.t4 := NULL;
	--return next r;

	r.rubro1:=NULL;
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := NULL;
	return next r;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.sprpedores(integer, integer, integer, integer) OWNER TO sistema;
