alter table solicitudprestamo rename sueldo to reciprocidad;
alter table solicitudprestamo rename sueldoconyuge to partesocial;
alter table solicitudprestamo rename otrosingresos to ahorrogarantia;
alter table solicitudprestamo rename fecharesultado to vigencia;
alter table solicitudprestamo rename domicilioid to finalidadid;
alter table solicitudprestamo drop constraint domicilioempresa;
alter table domicilio alter column sujetoid drop not null;
alter table solicitudprestamo rename totaldeudas to calculonormalid;
alter table solicitudprestamo alter column calculonormalid type integer;
alter table solicitudprestamo add column etapa integer;
alter table solicitudprestamo add column periododegracia integer;
alter table solicitudprestamo add column pagainteresgracia integer;

--
alter table solicitudprestamo drop column otrosabonos;
alter table solicitudprestamo drop column totalegresos;
alter table solicitudprestamo drop column entregado;
alter table solicitudprestamo drop column presidente;
alter table solicitudprestamo drop column vicepresidente;
alter table solicitudprestamo drop column oficialcredito;
alter table solicitudprestamo drop column analistacredito;
alter table solicitudprestamo drop column secretario;
alter table solicitudprestamo drop column contratogrupo;
alter table solicitudprestamo drop column folioprocampo;
alter table solicitudprestamo drop column nohectareas;
alter table solicitudprestamo drop column credxhec;
alter table solicitudprestamo drop column comxhec;
alter table solicitudprestamo drop column comxch;
alter table solicitudprestamo drop column interes;
alter table solicitudprestamo drop column montoentregado;
alter table solicitudprestamo drop column comasesor;
alter table solicitudprestamo drop column montoprocampo;
alter table solicitudprestamo drop column diadecorte;
alter table solicitudprestamo drop column porcentajepagominimo;
alter table solicitudprestamo drop column diadepago;
alter table solicitudprestamo drop column gastoscobranza;
alter table solicitudprestamo drop column limitedecredito;
alter table solicitudprestamo drop column lastusuarioid;
alter table solicitudprestamo drop column empresatrabaja;
alter table solicitudprestamo drop column jefedirecto;
alter table solicitudprestamo drop column verificado;
alter table solicitudprestamo drop column obsinvestigacion;
alter table solicitudprestamo drop column observaciones;
alter table solicitudprestamo drop column obsingresos;
alter table solicitudprestamo drop column tiempoendomicilio;
alter table solicitudprestamo drop column tiempoentrabajo;
alter table solicitudprestamo drop column dependienteseconomicos;
alter table solicitudprestamo drop column calificacionburo;
alter table solicitudprestamo drop column actano;
alter table solicitudprestamo drop column fechacomite;
alter table solicitudprestamo drop column resolucionid;
alter table solicitudprestamo drop column valorpropiedades;
alter table solicitudprestamo drop column gastosordinarios;
alter table solicitudprestamo drop column otrosgastos;


alter table solicitudprestamo add column consultaburoid integer references consultaburo(consultaid);

