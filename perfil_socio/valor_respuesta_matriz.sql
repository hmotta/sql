drop type tvalorrespuestamat cascade;
create type tvalorrespuestamat as (
	riesgo numeric,
	respuesta text
);

CREATE or replace FUNCTION valor_respuesta_matriz(integer,integer,integer[]) RETURNS tvalorrespuestamat
AS $_$
declare
	ppreguntaid alias for $1;
	pvalor alias for $2;
	arrvalores alias for $3;
	r tvalorrespuestamat%rowtype;
	xvalor numeric;
	xvalor_total numeric;
	ncontador int4;
	scadena text;
	nlongitud int4;
	stam_array character varying (10); 
BEGIN
	
	IF arrvalores IS not NULL THEN
		ncontador:=0;
		xvalor_total:=0;
		--nlongitud = array_length(arrvalores,1); Postgresql 9.2
		--Postgresql 8.2
		stam_array:=array_dims(arrvalores);
		if length(stam_array)=6 then
			nlongitud := substr(stam_array,4,2); --Postgresql 8.2
		else
			nlongitud := substr(stam_array,4,1); --Postgresql 8.2
		end if;
		for i IN 1..nlongitud loop
			if arrvalores[i]=1 then
			
				if ppreguntaid=11 then
					select nombreestadomex into scadena from estadosmex where estadomexid=i;
					if i in (29,31) then
						select valor into xvalor from nivelderiesgo where nivelderiesgo=3;
					elsif i in (1,3,4,7,13,18,20,21,22,23,24,27) then
						select valor into xvalor from nivelderiesgo where nivelderiesgo=2;
					else
						select valor into xvalor from nivelderiesgo where nivelderiesgo=1;
					end if;
				else
					select nr.valor,rp.descripcion_respuesta into xvalor,scadena from cat_respuestas_matriz rp inner join nivelderiesgo nr on (rp.nivelriesgoid=nr.nivelderiesgo) where rp.preguntaid=ppreguntaid and  i between rp.valor_respuesta_minimo and rp.valor_respuesta_maximo;
				end if;
				
				if r.respuesta is null then
					r.respuesta :=scadena;
				else
					r.respuesta :=r.respuesta ||' / '||scadena;
				end if;
				xvalor_total:=xvalor_total+xvalor;
				ncontador:=ncontador+1;
			end if;
		end loop;
		if ncontador>0 then
			r.riesgo = xvalor_total/ncontador;
		else
			r.riesgo = 0;
		end if;
	ELSE
		select nr.valor,rp.descripcion_respuesta into r.riesgo,r.respuesta from cat_respuestas_matriz rp inner join nivelderiesgo nr on (rp.nivelriesgoid=nr.nivelderiesgo) where rp.preguntaid=ppreguntaid and  pvalor between rp.valor_respuesta_minimo and rp.valor_respuesta_maximo;
	END IF;
	
	r.riesgo = coalesce(r.riesgo,0);
	r.respuesta = coalesce(r.respuesta,'');
	
	RETURN r;
END
$_$
	LANGUAGE 'plpgsql' VOLATILE;