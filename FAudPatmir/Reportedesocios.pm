package crediweb::Controller::Reportedesocios;

use strict;
use warnings;
use base 'Catalyst::Controller';

use PDF::API2;
use Math::Round;


sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched crediweb::Controller::Reportedesocios in Reportedesocios.');
}


sub make_altasbajassocios: Local {

    my ($self, $c) = @_;

    # Create an HTML::Widget to build the form
    my $w = $c->widget('reporteporgrupos_form')->method('post');
    
    # ***New: Use custom class to render each element in the form    
    $w->element_container_class('FormElementContainer');

    my $dbh = $c->connectdbh($c);    
   
    my $sql = qq|SELECT substr(cast(now() as text),1,10)|;
    
    my $sth = $dbh->prepare($sql) || die $self->WDB->errstr;
    $sth->execute || die $dbh->errstr;
    my ($vfecha) = $sth->fetchrow_array;
    $sth->finish;   

    $sql = qq|select grupo,grupo from grupo order by grupo|;
    
    $sth = $dbh->prepare($sql) || die $dbh->errstr;
    $sth->execute || die $dbh->errstr;
    
    my @grupoObj;
    
    while (my $tuple = $sth->fetch) {
        push(@grupoObj,$tuple->[0] =>$tuple->[1]);
    }
      
    $sth->finish;
    
    $sql = qq|select tiposocioid,descritiposocio from tiposocio order by tiposocioid|;
    
    $sth = $dbh->prepare($sql) || die $dbh->errstr;
    $sth->execute || die $dbh->errstr;
    
    my @tiposocioObj;
    
    while (my $tuple = $sth->fetch) {
        push(@tiposocioObj,$tuple->[0] =>$tuple->[1]);
    }
      
    $sth->finish;

    
    $dbh->disconnect;

    $w->element('Textfield', 'fecha1'  )->label('De la fecha:')->size(10)->value($vfecha);    

    $w->element('Textfield', 'fecha2'  )->label(' a la fecha:')->size(10)->value($vfecha);
    
    $w->element('Select',    'ltiposocio1')->label('Del tipo de socio:')
        ->options(@tiposocioObj)->multiple(1)->size(2);

    $w->element('Select',    'ltiposocio2')->label(' Al tipo de socio:')    
        ->options(@tiposocioObj)->multiple(1)->size(2);
    
    $w->element('Select',    'lgrupo1')->label('Del Grupo:')    
        ->options(@grupoObj)->multiple(1)->size(3);

    $w->element('Select',    'lgrupo2')->label(' Al Grupo:')    
        ->options(@grupoObj)->multiple(1)->size(3);

    $w->element('Select','tiporeporte')->label('Reporte de')
         ->options(0 => 'Altas de socios', 1 => 'Bajas de socios')->multiple(3)->size(2)->selected(0); 

    
    $w->element('Submit',    'submit' )->value('Aceptar');
        
    return $w;
}


sub altasbajassocios: Local {
    
  my ($self, $c) = @_;

  # Create the widget and set the action for the form
  my $w = $self->make_altasbajassocios($c);
  
  $w->action($c->uri_for('imprimirreportealtasbajassocios'));
  $c->stash->{titulo}={titulo => 'Reporte de altas y bajas de clientes o socios'};
  # Write form to stash variable for use in template
  $c->stash->{widget_result} = $w->result;
  
  # Set the template
  $c->stash->{template} = 'reportes/elegir.tt2';
         
}

sub imprimirreportealtasbajassocios: Local {  
    
    my ($self, $c) = @_;    
    my $fecha1  = $c->request->params->{fecha1};
    my $fecha2  = $c->request->params->{fecha2};

    my $grupo1 = $c->request->params->{lgrupo1} || '0';
    my $grupo2 = $c->request->params->{lgrupo2} || 'ZZZ';
    
    my $tiposocio1 = $c->request->params->{ltiposocio1} || '0';
    my $tiposocio2 = $c->request->params->{ltiposocio2} || 'ZZZ';

    my $tiporeporte = $c->request->params->{tiporeporte} || 0;
    
    my $dbh = $c->connectdbh($c);
    
    my $sth;
    my $sql;
    
    my ($empresa,$sucid,$nombresucursal,$ciudadcaja,$fechahoy,$estadocaja);
    
    my $sqle = qq|select em.nombrecaja,em.sucid, em.nombresucursal,c.nombreciudadmex, substring(cast(now() as text),1,10), es.nombreestadomex from empresa em, ciudadesmex c, estadosmex es where em.empresaid=1 and em.ciudadmexid=c.ciudadmexid and c.estadomexid=es.estadomexid|;
    
    my $sthe  = $dbh->prepare($sqle) || die $dbh->errstr;
    $sthe ->execute  || die $dbh->errstr;
    
    ($empresa,$sucid,$nombresucursal,$ciudadcaja,$fechahoy,$estadocaja) = $sthe ->fetchrow_array;	
    $sthe->finish;
  
    system ("rm /home/crediweb/cvs/crediweb/root/upload/reportes/altasbajassocios.csv");
    
    my $file="/home/crediweb/cvs/crediweb/root/upload/reportes/altasbajassocios.csv";

    open (A,">>$file");

    print A qq|"Clave Socio","Grupo","Nombre","Domicilio","F. Ingreso","Fec. baja" \n|;
        
    my $pdf;
    my $f1;
    my $txt;
    my $page;
    my $t;
    my $x;
    my $y;
    my $o;
    my $ipp=1/72;
    
    $pdf=PDF::API2->new;

    $pdf->mediabox(8.5/$ipp,11/$ipp);
        
    $f1=$pdf->corefont('Arial',-encoding => 'latin1'); 

    my $tfinal;
    my $pag=1;  
    my $linea=0;
    my ($t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8);
    my $stipo_cta;

    my $lt=localtime();

    if ($tiporeporte==0) {
        
        $sql = "select s.clavesocioint,si.grupo,substring(su.nombre||' '||su.paterno||' '||su.materno,1,30) as nombresocio,substring((d.calle)||' '||(d.numero_ext),1,30) as domicilio,s.fechaalta,s.fechabaja from socio s, sujeto su, solicitudingreso si, domicilio d  where s.fechaalta >=  '$fecha1' and s.fechaalta <= '$fecha2' and s.tiposocioid >=  '$tiposocio1' and s.tiposocioid <= '$tiposocio2' and s.socioid=si.socioid and si.grupo >= '$grupo1' and si.grupo<='$grupo2' and su.sujetoid = s.sujetoid and d.sujetoid=s.sujetoid  order by si.grupo,s.fechaalta ";
    } else {
        
       $sql = "select s.clavesocioint,si.grupo,su.nombre||' '||su.paterno||' '||su.materno as nombresocio,(d.calle)||'  '||(d.numero_ext) as domicilio,s.fechaalta,s.fechabaja from socio s, sujeto su, solicitudingreso si, domicilio d  where s.fechabaja >=  '$fecha1' and s.fechabaja <= '$fecha2' and s.tiposocioid >=  '$tiposocio1' and s.tiposocioid <= '$tiposocio2' and s.socioid=si.socioid and si.grupo >= '$grupo1' and si.grupo<='$grupo2' and su.sujetoid = s.sujetoid and d.sujetoid=s.sujetoid  order by si.grupo,s.fechaalta ";  

    }
    
    $c->log->debug($sql);
    
    $sth  = $dbh->prepare($sql) || die $dbh->errstr;
    $sth ->execute  || die $dbh->errstr;

        
    my $vsocios =0;
    my $vgrupo='';
    
    while (($t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8) = $sth ->fetchrow_array){

	if ($linea <= 10){

	    # Encabezado
	    $page=$pdf->page;
	    $t=$page->text;
	    $t->font($f1,8);
    
            $t->translate(5,760);
	    $t->text($empresa);
    
            $t->translate(300,760);
	    $t->text("Suc.: ".$sucid);
    
	    $t->translate(5,750);
	    $t->text("Reporte de altas bajas de socios");
	    
	    $t->translate(5,740);
	    $t->text("Ordenado por: fecha ");
	
	    $t->translate(350,740);
	    $t->text("Fecha de Impresión: ".$lt);
	    
	    $t->translate(540,760);
	    $t->text("Pag.");
	    
	    $t->translate(565,760);
	    $t->text($pag);
	    $pag=$pag+1;
	    
	    $t->translate(5,720);
	    $t->text("Clave");
	    $t->translate(80,720);
	    $t->text("Grupo");
	    $t->translate(140,720);
	    $t->text("Nombre");
	    $t->translate(290,720);
	    $t->text("Domicilio"); 
	    $t->translate(475,720);
            $t->text("Fecha Alta");
            $t->translate(530,720);
	    $t->text("Fecha Baja");
	    
	    my $gfx = $page->gfx;
	    $gfx->strokecolor('black');
	    $gfx->move(5,715);
	    $gfx->line(575,715);
	    $gfx->close;
	    $gfx->stroke;
	    	    
	    $linea=700;	   

	}
        
	if ( $t1 ne $vgrupo ){

            $t->translate(5,$linea);
            $t->text("Total por grupo: $vsocios");
            $linea=$linea-10;
        }
                        
        $t->translate(5,$linea);
        $t->text("$t0");
        
        $t->translate(80,$linea);
        $t->text(substr($t1,0,12));
        
        $t->translate(140,$linea);
        $t->text("$t2");

        $t->translate(290,$linea);
        $t->text("$t3");

        $t->translate(475,$linea);
        $t->text("$t4");
        
        $t->translate(530,$linea);
        $t->text("$t5");
                
        
        print A qq|"$t0","$t1","$t2","$t3","$t4","$t5" \n|;
        
        $linea=$linea-10;
        $vgrupo=$t1;
        $vsocios=$vsocios+1;
        
    }

    $linea=$linea-10;

    $t->translate(5,$linea);
    $t->text("Total de socios: $vsocios");
    $linea=$linea-10;
    
    $sth->finish;
    
    close(A);
    
    $dbh->disconnect;   
    
    $pdf->saveas("/home/crediweb/cvs/crediweb/root/upload/reportes/altasbajassocios.pdf");
    $pdf->end;
    
    $c->response->redirect($c->uri_for('../upload/reportes/altasbajassocios.pdf'));
}

sub make_estadocuentasocios: Local {

    my ($self, $c) = @_;

    # Create an HTML::Widget to build the form
    my $w = $c->widget('reporteporgrupos_form')->method('post');
    
    # ***New: Use custom class to render each element in the form    
    $w->element_container_class('FormElementContainer');

    my $dbh = $c->connectdbh($c,'EDOCTA001');    
   
    my $sql = qq|SELECT substr(cast (now() as text),1,10),sucid from empresa|;
    
    my $sth = $dbh->prepare($sql) || die $self->WDB->errstr;
    $sth->execute || die $dbh->errstr;
    my ($vfecha,$sucid) = $sth->fetchrow_array;
    $sth->finish;   
    
    my @grupoObj;

    push(@grupoObj,'AHORRO'=> "AHORRO"); 
    push(@grupoObj,'INVERSION'=> "INVERSION");


    my $clavesocioint1=$sucid;

    
    $dbh->disconnect;

    $w->element('Textfield', 'fecha1'  )->label('De la fecha:')->size(10)->value($vfecha);    

    $w->element('Textfield', 'fecha2'  )->label(' a la fecha:')->size(10)->value($vfecha);
    

    $w->element('Textfield', 'clavesocioint1'  )->label('Del Socio:')->size(10)->value($clavesocioint1);    
    
    
    $w->element('Select',    'lmovimiento')->label('Tipo de movimiento:')    
        ->options(@grupoObj)->multiple(1)->size(2);

    $w->element('Submit',    'submit' )->value('Aceptar');
        
    return $w;       
}



sub estadocuentasocios: Local {
    
  my ($self, $c) = @_;

  # Create the widget and set the action for the form
  my $w = $self->make_estadocuentasocios($c);
  
  $w->action($c->uri_for('imprimirestadocuentasocios'));
  $c->stash->{titulo}={titulo => 'Estado de cuenta de socios'};
  # Write form to stash variable for use in template
  $c->stash->{widget_result} = $w->result;
  
  # Set the template
  $c->stash->{template} = 'reportes/elegir.tt2';
         
}

sub imprimirestadocuentasocios: Local { 
 
    my ($self, $c) = @_;    

    my $vfechai  = $c->request->params->{fecha1};
    my $vfechaf  = $c->request->params->{fecha2};
    my $vmovid = $c->request->params->{lmovimiento} || 'AHORRO';
    my $vclavesocioint1 = $c->request->params->{clavesocioint1} || '0';
    
    my $dbh = $c->connectdbh($c,'EDOCTA001');

    #Declaramos las variables y asi para que puedan cachar el valor.
    my $sql = qq|select nombrecaja,sucid,rtrim(direccioncaja),
                 fechaletra('$vfechai'),
                 fechaletra('$vfechaf'),
                 ciudadcaja from empresa where empresaid=1|;
    
    my $sth  = $dbh->prepare($sql) || die $dbh->errstr;
    $sth ->execute  || die $dbh->errstr;
    my ($empresa,$sucid,$direccioncaja,$vfechain,$vfechafin,$ciudadcaja) = $sth -> fetchrow_array;
    $sth->finish;
       
    my $pdf;
    my $f1;
    my $bold;
    my $italic;
    my $page;
    my $gfx;
    my $t;
    my $ipp=1/72;
    
    $pdf=PDF::API2->new;
    $pdf->mediabox(8.5/$ipp,11/$ipp);
            
    $f1=$pdf->corefont('Arial',-encoding => 'latin1'); 
    $bold=$pdf->corefont('Helvetica-Bold',-encoding => 'latin1');
    $italic=$pdf->corefont('Times-BoldItalic',-encoding => 'latin1');
    
    $page = $pdf->page;
    $gfx  = $page->gfx;
    $t    = $page->text;

    $t->font($italic,14);
    $t->translate(0.4/$ipp, 10.5/$ipp); $t->text("Estado de Cuenta Captación");
    
    $sql = "SELECT su.nombre||' '||su.paterno||' '||su.materno as nombresocio,su.razonsocial,
                   su.rfc, d.calle||' '||d.numero_ext as direccion, col.nombrecolonia,
                   c.nombreciudadmex as municipio, d.codpostal, e.nombreestadomex
            FROM socio s, sujeto su, domicilio d, ciudadesmex c,estadosmex e,colonia col
            WHERE s.sujetoid = su.sujetoid and 
                  su.sujetoid = d.sujetoid and 
                  d.ciudadmexid = c.ciudadmexid and
                  c.estadomexid = e.estadomexid and
                  d.coloniaid = col.coloniaid  and 
                  s.clavesocioint='$vclavesocioint1' 
            group by nombresocio,razonsocial,rfc,direccion,nombrecolonia,municipio,codpostal,nombreestadomex;";
    $sth  = $dbh->prepare($sql) || die $dbh->errstr;
    $sth ->execute  || die $dbh->errstr;
    my ($nombresocio,$razonsocial,$rfc,$direccionsocio,$colonia,$municipio,$codpostal,$estado) = $sth -> fetchrow_array;
    $sth->finish;

    my $img=$pdf->image('/home/crediweb/cvs/crediweb/root/upload/yolo.jpg');
    $gfx->image($img,470,725,105,40);
    $t->font($bold,7);
    $t->translate(0.4/$ipp, 10.30/$ipp); $t->text("$nombresocio");
    $t->translate(0.4/$ipp, 10.15/$ipp); $t->text("RFC: $rfc");
    $t->translate(0.4/$ipp, 10.00/$ipp); $t->text("$direccionsocio");
    $t->translate(0.4/$ipp, 9.85/$ipp); $t->text("$colonia");
    $t->translate(0.4/$ipp, 9.70/$ipp); $t->text("$municipio, $estado C.P. $codpostal");
    $t->translate(0.4/$ipp, 9.55/$ipp); $t->text("Socio: $vclavesocioint1");
    $t->translate(0.4/$ipp, 9.40/$ipp); $t->text("PERIODO: $vfechain AL $vfechafin");
    $gfx->rect(0.4/$ipp,9.35/$ipp,7.6/$ipp,0/$ipp);    

    $t->font($f1,6);
    $t->translate(8.0/$ipp, 10.0/$ipp); $t->text_right("$direccioncaja");
    $t->translate(8.0/$ipp, 9.9/$ipp); $t->text_right("$ciudadcaja");    

    my $linea = 9.2;
    $t->font($bold,8);
    $t->translate(0.4/$ipp, $linea/$ipp); $t->text("Fecha");
    $t->translate(1.2/$ipp, $linea/$ipp); $t->text("Movimiento");
    $t->translate(3.4/$ipp, $linea/$ipp); $t->text_right("Saldo Inicial");
    $t->translate(4.8/$ipp, $linea/$ipp); $t->text_right("Depositos");
    $t->translate(6.2/$ipp, $linea/$ipp); $t->text_right("Retiros");
    if($vmovid eq 'INVERSION') {
	$t->translate(7.2/$ipp, $linea/$ipp); $t->text_right("Interes");
    }
    $t->translate(8.0/$ipp, $linea/$ipp); $t->text_right("Saldo Final");
    $linea -= .05;
    $gfx->rect(0.4/$ipp,$linea/$ipp,7.6/$ipp,0/$ipp);
    $linea -= .2;
    $gfx->stroke;
    my ($tipomovimientoid,$serie,$referencia,$numero_poliza,$fecha, $saldoinicial,
	$depositos, $retiros, $interes, $saldofinal,$desctipomov);
    
    my $npagina=1;

    #Tipos de ahorro que se manejan en fincafe.
    my @tiposDeAhorro = ('PA','PB','AA','AM','AC','CU','AR','PE','AS');

    #Tipos de inversion que se manejan en fincafe.
    my @tiposDeInversion = ( 'IN' );

    my @tiposDeMovimiento;

    #Se requiere un estado de cuenta de AHORROS.
    @tiposDeMovimiento = @tiposDeAhorro if ($vmovid eq 'AHORRO');
    

    #Se requiere un estado de cuenta de INVERSIONES.
    @tiposDeMovimiento = @tiposDeInversion if ($vmovid eq 'INVERSION');
    
    #Por cada tipo de movimiento,
    foreach my $tpm ( @tiposDeMovimiento ) {   

	#se consultan los movimientos realizados en el rango de fechas
	#proporcionadas.
	$sql = "select * from ( select * from spsrptxtipomovimiento(
               '$vclavesocioint1','$vfechai','$vfechaf','$tpm')) a,
               ( select desctipomovimiento from tipomovimiento
                where tipomovimientoid='$tpm') b;";
        $sth  = $dbh->prepare($sql) || die $dbh->errstr;
        $sth ->execute  || die $dbh->errstr;
	    
	my $tienemovimiento = 0;	    
	$t->font($f1,7);

	#Se separan los valores tupla x tupla.
	while ( ($tipomovimientoid,$serie,$referencia,$numero_poliza,$fecha,
                 $saldoinicial,$depositos, $retiros, $interes, $saldofinal,
                 $desctipomov) = $sth -> fetchrow_array ) {	

	    #almenos hay un movimiento 
	    $tienemovimiento = 1;

	    #Si el movimiento no fue cancelado,
	    if( $saldoinicial != $saldofinal ) {

		#Se imprimen los valores obtenidos de la base.
		$t->translate(0.4/$ipp, $linea/$ipp); $t->text(fecha2formatolocal( $c, $fecha ));
		$t->translate(1.2/$ipp, $linea/$ipp); $t->text($desctipomov);
		$t->translate(3.4/$ipp, $linea/$ipp); $t->text_right($c->fmoneda($saldoinicial));
		$t->translate(4.8/$ipp, $linea/$ipp); $t->text_right($c->fmoneda($depositos));
		$t->translate(6.2/$ipp, $linea/$ipp); $t->text_right($c->fmoneda($retiros));
		if($vmovid eq 'INVERSION') {
		    $t->translate(7.2/$ipp, $linea/$ipp); $t->text_right($c->fmoneda($interes));
		}
		$t->translate(8.0/$ipp, $linea/$ipp); $t->text_right($c->fmoneda($saldofinal));	
		$linea -= .2;

		#Realiza el cambio de página
		if($linea < .6) {
			
		    $t->font($f1,6);
		    $t->translate(8.0/$ipp, .3/$ipp); $t->text_right("Pag. $npagina");
		
		    $page = $pdf->page;
		    $gfx  = $page->gfx;
		    $t    = $page->text;

		    $t->font($f1,7);
		    $linea = 10.5;
		    $t->font($bold,8);		
		    $gfx->rect(0.4/$ipp,10.60/$ipp,7.6/$ipp,0/$ipp);
		    $linea -= .05;
		    $t->translate(0.4/$ipp, $linea/$ipp);$t->text("Fecha");
		    $t->translate(1.2/$ipp, $linea/$ipp);$t->text("Movimiento");
		    $t->translate(3.4/$ipp, $linea/$ipp);$t->text_right("Saldo Inicial");
		    $t->translate(4.8/$ipp, $linea/$ipp);$t->text_right("Depositos");
		    $t->translate(6.2/$ipp, $linea/$ipp);$t->text_right("Retiros");
		    if($vmovid eq 'INVERSION') {
			$t->translate(7.2/$ipp, $linea/$ipp); $t->text_right("Interes");
		    }
		    $t->translate(8.0/$ipp, $linea/$ipp);$t->text_right("Saldo Final");
		    $linea -= .05;
		    $gfx->rect(0.4/$ipp,$linea/$ipp,7.6/$ipp,0/$ipp);
		    $linea -= .2;
		    $gfx->stroke;

		    $t->font($f1,7);
		    $npagina+=1;
		}
	    }
	}
	$sth->finish;
	    
	#Imprime una linea divisora entre tipos de ahorro(solo si existieron movimientos)
	if($tienemovimiento==1){
	   $gfx->rect(0.4/$ipp,$linea/$ipp,7.6/$ipp,0/$ipp);
	   $gfx->stroke;		
	   $linea -= .2;
        }
    }
	
    
    $t->font($f1,6);
    $t->translate(8.0/$ipp, .3/$ipp); $t->text_right("Pag. $npagina");
    $sth->finish;
    $dbh->disconnect;   
    
    $pdf->saveas("/home/crediweb/cvs/crediweb/root/upload/reportes/estadocuentasocios.pdf");
    $pdf->end;
    
    $c->response->redirect($c->uri_for('../upload/reportes/estadocuentasocios.pdf'));    
}

#Convierte una fecha de la forma "2009-01-31" a la forma "31/01/2009".
sub fecha2formatolocal: Local{  
    #Obtiene la fecha pasada como parámetro.
    my ($c, $fechaFormatoIngles ) = @_;

    #Separa los componentes de la fecha (año,mes,dia).
    my @datosFecha = split( '-', $fechaFormatoIngles ); 
    
    #Realiza la transformación de formato.
    my $fechaFormatoLocal = "$datosFecha[2]/$datosFecha[1]/$datosFecha[0]";

    #Regresa la fecha en el formato local
    return $fechaFormatoLocal;
}

1;


