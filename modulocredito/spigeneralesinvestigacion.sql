CREATE FUNCTION spigeneralesinvestigacion(integer,integer,text,text,integer,text,integer,integer,text,date,text,text,character varying,character varying,numeric,character varying,integer,text,character varying,character varying,text,character varying,integer) RETURNS integer
AS $_$
	declare
			 psolicitudprestamoid alias for $1;
			 psujetoid alias for $2;
			 pcalle alias for $3;
			 pcolonia alias for $4;
			 pnivelestudios alias for $5;
			 pnombreestudios alias for $6;
			 pedocivil alias for $7;
			 ptipodebienes alias for $8;
			 pnombreconyugue alias for $9;
			 pfechanacconyugue alias for $10;
			 pempresaconyugue alias for $11;
			 pdirempresaconyugue alias for $12;
			 ppuestoconyugue alias for $13;
			 pteltrabajoconyugue alias for $14;
			 pingresoconyugue alias for $15;
			 pantitrabconyugue alias for $16;
			 ptipovivienda alias for $17;
			 pnombrepropietario alias for $18;
			 pparentesco alias for $19;
			 pcaracter alias for $20;
			 pdocpresentado alias for $21;
			 pclavecatrastal alias for $22;
			 ptiemporesidencia alias for $23;
	begin
			 
			 
      insert into generalesinvestigacion (solicitudprestamoid,
			 sujetoid,
			 calle,
			 colonia,
			 nivelestudios,
			 nombreestudios,
			 edocivil,
			 tipodebienes,
			 nombreconyugue,
			 fechanacconyugue,
			 empresaconyugue,
			 dirempresaconyugue,
			 puestoconyugue,
			 teltrabajoconyugue,
			 ingresoconyugue,
			 antitrabconyugue,
			 tipovivienda,
			 nombrepropietario,
			 parentesco,
			 caracter,
			 docpresentado,
			 clavecatrastal,
			 tiemporesidencia
		)
        values(psolicitudprestamoid,
			 psujetoid,
			 pcalle,
			 pcolonia,
			 pnivelestudios,
			 pnombreestudios,
			 pedocivil,
			 ptipodebienes,
			 pnombreconyugue,
			 pfechanacconyugue,
			 pempresaconyugue,
			 pdirempresaconyugue,
			 ppuestoconyugue,
			 pteltrabajoconyugue,
			 pingresoconyugue,
			 pantitrabconyugue,
			 ptipovivienda,
			 pnombrepropietario,
			 pparentesco,
			 pcaracter,
			 pdocpresentado,
			 pclavecatrastal,
			 ptiemporesidencia
		);
     
     return currval('generalesinvestigacion_generalesid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;