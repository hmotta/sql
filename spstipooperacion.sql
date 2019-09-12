CREATE OR REPLACE FUNCTION spstipooperacion(varchar)
  RETURNS SETOF rtipooperacion AS $BODY$
declare
   ptipoope alias for $1;
r rtipooperacion%rowtype;
top  character varying(2);
 

begin
	IF ptipoope='B@' then
			r.tipooperacion:=4;
			return next r;
	elseif ptipoope='B#' then
			r.tipooperacion:=5;
			return next r;
	elseif ptipoope='L@' then
		r.tipooperacion:=6;
		return next r;
	else
		for r in
			select tipomovimientoid  from tipomovimiento where tipomovimientoid=ptipoope
	      
	 loop 
		IF r.tipooperacion='AO'or r.tipooperacion='AA' or r.tipooperacion='AI'or r.tipooperacion='AP'or r.tipooperacion='TA'or r.tipooperacion='PR'or 			r.tipooperacion='AH'or r.tipooperacion='AF'or r.tipooperacion='AM'or r.tipooperacion='CC'or r.tipooperacion='TC'or r.tipooperacion='MV'or 			r.tipooperacion='IU'or r.tipooperacion='TU'or r.tipooperacion='P3'or r.tipooperacion='CM'or r.tipooperacion='CF'or r.tipooperacion='MC'or 			r.tipooperacion='SK'or r.tipooperacion='TE'or r.tipooperacion='OP'or r.tipooperacion='EX'or r.tipooperacion='PY'or r.tipooperacion='CH'or 			r.tipooperacion='RS' then
                  	 r.tipooperacion:=0;
		END IF;
		IF r.tipooperacion='IN' then
                  	 r.tipooperacion:=1;
		END IF;
		IF r.tipooperacion='00' then
			r.tipooperacion:=2;
		END IF;
		IF r.tipooperacion='0A' then
			r.tipooperacion:=3;
		END IF;
		return next r;
		end loop;
	END IF;
	 
return;
end

		
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;