--set search_path to public,sucursal1;
select setval('grupo_grupoid_seq',max(grupoid)) from grupo;

select setval('activos_activoid_seq',max(activoid)) from activos;
select setval('amortizaciones_amortizacionid_seq',max(amortizacionid)) from amortizaciones;
select setval('polizas_polizaid_seq',max(polizaid)) from polizas;
select setval('movipolizas_movipolizaid_seq',max(movipolizaid)) from movipolizas;
select setval('ciudadesmex_ciudadmexid_seq',max(ciudadmexid)) from ciudadesmex;
select setval('estadosmex_estadomexid_seq',max(estadomexid)) from estadosmex;
select setval('depreciacion_depreciacionid_seq',max(depreciacionid)) from depreciacion;
select setval('domicilio_domicilioid_seq',max(domicilioid)) from domicilio;
select setval('saldos_saldoid_seq',max(saldoid)) from saldos;
select setval('inversion_inversionid_seq',max(inversionid)) from inversion;
select setval('bienes_bienid_seq',max(bienid)) from bienes;
select setval('calculo_calculoid_seq',max(calculoid)) from calculo;
select setval('movicaja_movicajaid_seq',max(movicajaid)) from movicaja;
select setval('movibanco_movibancoid_seq',max(movibancoid)) from movibanco;
select setval('socio_socioid_seq',max(socioid)) from socio;
select setval('sujeto_sujetoid_seq',max(sujetoid)) from sujeto;
select setval('beneficiario_beneficiarioid_seq',max(beneficiarioid)) from beneficiario;
select setval('empresa_empresaid_seq',max(empresaid)) from empresa;
select setval('parametros_parametroid_seq',max(parametroid)) from parametros;
select setval('permisosmodulos_permisomoduloid_seq',max(permisomoduloid)) from permisosmodulos;
select setval('prestamos_prestamoid_seq',max(prestamoid)) from prestamos;
select setval('avales_avalid_seq',max(avalid)) from avales;
select setval('reciprocidad_reciprocidadid_seq',max(reciprocidadid)) from reciprocidad;
select setval('tipoaviso_tipoavisoid_seq',max(tipoavisoid)) from tipoaviso;
select setval('aviso_avisoid_seq',max(avisoid)) from aviso;
select setval('precorte_precorteid_seq',max(precorteid)) from precorte;
select setval('tipoaviso_tipoavisoid_seq',max(tipoavisoid)) from tipoaviso;
select setval ('solicitudingreso_solicitudingresoid_seq',max(solicitudingresoid)) from solicitudingreso;
select setval ('solicitudprestamo_solicitudprestamoid_seq',max(solicitudprestamoid)) from solicitudprestamo;
