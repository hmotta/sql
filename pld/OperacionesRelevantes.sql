select op.operacionlavadoid, op.fecha_de_la_operacion, op.numero_de_cuenta, op.apellido_paterno||' '||op.apellido_materno||' '||op.nombre, op.monto, 
(case 
when (op.tipo_de_reporte='2' and op.estatus=0) then 'Posiblemente Inusual' 
when (op.tipo_de_reporte='2' and op.estatus=1) then 'Inusual' 
when (op.tipo_de_reporte='3' and op.estatus=0) then 'Posiblemente Preocupante' 
when (op.tipo_de_reporte='3' and op.estatus=1) then 'Preocupante' 
end), op.descripcion_operacion, (select coalesce(max(salariomensual),0) from conoceatucliente where socioid=mc.socioid) from operacionlavado op , movicaja mc where fechainicial >='2013-04-01' and fechafinal<= '2013-04-12' and (tipo_de_reporte in ('2','3'))and mc.movicajaid=op.movicajaid order by operacionlavadoid;