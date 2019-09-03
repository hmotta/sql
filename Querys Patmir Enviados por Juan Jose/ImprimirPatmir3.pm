package crediweb::Controller::ImprimirPatmir3;

use strict;
use warnings;
use base 'Catalyst::Controller';

use PDF::API2;
use Math::Round;


sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched crediweb::Controller::ImprimirPatmir3 in ImprimirPatmir3.');
}

sub make_sociosclientes: Local {

    my ($self, $c) = @_;

    # Create an HTML::Widget to build the form
    my $w = $c->widget('sociosclientes_form')->method('post');
    
    # ***New: Use custom class to render each element in the form    
    $w->element_container_class('FormElementContainer');

    my $dbh = $c->connectdbh($c);    
   
    my $sql = qq|SELECT substr(cast(now() as text),1,10)|;
    
    my $sth = $dbh->prepare($sql) || die $self->WDB->errstr;
    $sth->execute || die $dbh->errstr;
    my ($vfecha) = $sth->fetchrow_array;
   
    $sth->finish;   

    $dbh->disconnect;
    
    my $vfecha0 = $vfecha;

    $w->element('Textfield', 'fecha0'  )->label('De la fecha:')->size(10)->value($vfecha0);
    
    $w->element('Textfield', 'fecha1'  )->label('A la fecha:')->size(10)->value($vfecha);    

    $w->element('Select','consolidado')->label('Consolidado')
         ->options('N' => 'No', 'S' => 'Si')->multiple(3)->size(2)->selected('N');
    
    $w->element('Select','reporte')->label('Tipo de reporte:')
         ->options(1 => 'Reporte Socios-Cliente', 2 => 'Reporte de Creditos', 3 => 'Reporte de Captacion', 4 => 'Reporte Remesas', 5 => 'Reporte Microseguros', 6 => 'Reporte Tecnologia')->multiple(3)->size(6)->selected(1);
    
    $w->element('Submit',    'submit' )->value('Aceptar');
        
    return $w;
       
}


sub sociosclientes: Local {
    
  my ($self, $c) = @_;

  # Create the widget and set the action for the form
  my $w = $self->make_sociosclientes($c);
  
  $w->action($c->uri_for('imprimirsociosclientes'));
  $c->stash->{titulo}={titulo => 'PATMIR III DGRV'};
  # Write form to stash variable for use in template
  $c->stash->{widget_result} = $w->result;
  
  # Set the template
  $c->stash->{template} = 'reportes/elegir.tt2';
         
}

sub imprimirsociosclientes: Local {  
    
    my ($self, $c) = @_;
    my $fecha0  = $c->request->params->{fecha0};
    my $fecha1  = $c->request->params->{fecha1};
    my $consolidado = $c->request->params->{consolidado}||'N';
    my $reporte = $c->request->params->{reporte}||1;
    
    my $dbh = $c->connectdbh($c);
    
    my $sth;
    my $sql;
            
    system ("rm /home/crediweb/cvs/crediweb/root/upload/reportes/patmir3socios_clientes.csv");    
    my $file="/home/crediweb/cvs/crediweb/root/upload/reportes/patmir3socios_clientes.csv";
           
    my ($t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8,$t9,$t10,$t11,$t12,$t13,$t14,$t15,$t16,$t17,$t18,$t19,$t20,$t21,$t22,$t23,$t24,$t25,$t26,$t27,$t28,$t29,$t30,$t31,$t32,$t33,$t34);

    if ($reporte == 1)
    {
        if ($consolidado eq "N") {        
            $sql = "select * from patmir3sc('$fecha0','$fecha1') ";
        } else {        
            $sql = "select * from patmir3scc('$fecha0','$fecha1') ";  
        }    
    }
    else
    {
        if ($reporte == 2) 
        {        
            if ($consolidado eq "N") {        
                $sql = "select * from patmir3cre('$fecha0','$fecha1') ";
            } else {        
                $sql = "select * from patmir3crec('$fecha0','$fecha1') ";  
            }
        }
        else
        {
            if ($reporte == 3)
            {        
                if ($consolidado eq "N") {        
                    $sql = "select * from patmir3capta('$fecha0','$fecha1') ";
                } else {        
                    $sql = "select * from patmir3captac('$fecha0','$fecha1') ";  
                }
            }
            else
            {
                if ($reporte == 4)
                {        
                    if ($consolidado eq "N") {        
                        $sql = "select * from patmir3rem('$fecha0','$fecha1') ";
                    } else {        
                        $sql = "select * from patmir3remc('$fecha0','$fecha1') ";  
                }
                }
                else
                {
                    if ($reporte == 5)
                    {        
                        if ($consolidado eq "N") {        
                            $sql = "select * from patmir3mic('$fecha0','$fecha1') ";
                        } else {        
                            $sql = "select * from patmir3micc('$fecha0','$fecha1') ";  
                        }
                    }
                    else
                    {
                        if ($consolidado eq "N") {        
                            $sql = "select * from patmir3tec('$fecha0','$fecha1') ";
                        } else {        
                            $sql = "select * from patmir3tecc('$fecha0','$fecha1') ";  
                        }

                    }
                }
            }
        }
    }
        
    
    $c->log->debug($sql);    
    $sth  = $dbh->prepare($sql) || die $dbh->errstr;
    $sth ->execute  || die $dbh->errstr;
    
    open (A,">>$file");
    
    my @columnas = @{$sth->{NAME}};
    
    my $elem_actual;
    foreach $elem_actual (@columnas) {
        print A qq|"$elem_actual",|;
    }
            
    print A qq|\n|;        
    while (($t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8,$t9,$t10,$t11,$t12,$t13,$t14,$t15,$t16,$t17,$t18,$t19,$t20,$t21,$t22,$t23,$t24,$t25,$t26,$t27,$t28,$t29,$t30,$t31,$t32,$t33,$t34) = $sth ->fetchrow_array){                
         print A qq|"$t0","$t1","$t2","$t3","$t4","$t5","$t6","$t7","$t8","$t9","$t10","$t11","$t12","$t13","$t14","$t15","$t16","$t17","$t18","$t19","$t20","$t21","$t22","$t23","$t24","'$t25","$t26","$t27","$t28","$t29","$t30","$t31","$t32","$t33","$t34"  \n|;        
    }
    $sth->finish;
    
    close(A);
    
    $dbh->disconnect;   
    
    $c->response->redirect($c->uri_for('../upload/reportes/patmir3socios_clientes.csv'));
}

sub make_creditos: Local {

    my ($self, $c) = @_;

    # Create an HTML::Widget to build the form
    my $w = $c->widget('creditos_form')->method('post');
    
    # ***New: Use custom class to render each element in the form    
    $w->element_container_class('FormElementContainer');

    my $dbh = $c->connectdbh($c);    
   
    my $sql = qq|SELECT substr(cast(now() as text),1,10)|;
    
    my $sth = $dbh->prepare($sql) || die $self->WDB->errstr;
    $sth->execute || die $dbh->errstr;
    my ($vfecha) = $sth->fetchrow_array;
    $sth->finish;   

    
    $dbh->disconnect;

    $w->element('Textfield', 'fecha1'  )->label('A la fecha de cierre anterior:')->size(10)->value($vfecha);    

    $w->element('Select','consolidado')->label('Consolidado')
         ->options('N' => 'No', 'S' => 'Si')->multiple(3)->size(2)->selected('N');
    
    $w->element('Submit',    'submit' )->value('Aceptar');
        
    return $w;
       
}


sub creditos: Local {
    
  my ($self, $c) = @_;

  # Create the widget and set the action for the form
  my $w = $self->make_creditos($c);
  
  $w->action($c->uri_for('imprimircreditos'));
  $c->stash->{titulo}={titulo => 'PATMIR III Hoja Creditos'};
  # Write form to stash variable for use in template
  $c->stash->{widget_result} = $w->result;
  
  # Set the template
  $c->stash->{template} = 'reportes/elegir.tt2';
         
}

sub imprimircreditos: Local {  
    
    my ($self, $c) = @_;    
    my $fecha1  = $c->request->params->{fecha1};
    my $consolidado = $c->request->params->{consolidado}||'N';

    my @datosFecha = split( '-', $fecha1 );
    my $fecha2 = "$datosFecha[0]-$datosFecha[1]-01";
    
    my $dbh = $c->connectdbh($c);
    
    my $sth;
    my $sql;
            
    system ("rm /home/crediweb/cvs/crediweb/root/upload/reportes/patmir3socios_clientes.csv");    
    my $file="/home/crediweb/cvs/crediweb/root/upload/reportes/patmir3socios_clientes.csv";
           
    my ($t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8,$t9,$t10,$t11,$t12,$t13,$t14,$t15,$t16,$t17,$t18,$t19,$t20,$t21,$t22,$t23,$t24,$t25,$t26,$t27,$t28,$t29,$t30,$t31,$t32,$t33,$t34);
        
    if ($consolidado eq "N") {        
        $sql = "select * from patmir3cre('$fecha1') ";
    } else {        
        $sql = "select * from patmir3crec('$fecha1') ";  
    }    
    $c->log->debug($sql);    
    $sth  = $dbh->prepare($sql) || die $dbh->errstr;
    $sth ->execute  || die $dbh->errstr;
    
    open (A,">>$file");
    
    my @columnas = @{$sth->{NAME}};
    
    my $elem_actual;
    foreach $elem_actual (@columnas) {
        print A qq|"$elem_actual",|;
    }
            
    print A qq|\n|;        
    while (($t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8,$t9,$t10,$t11,$t12,$t13,$t14,$t15,$t16,$t17,$t18,$t19,$t20,$t21,$t22,$t23,$t24,$t25,$t26,$t27,$t28,$t29,$t30,$t31,$t32,$t33,$t34) = $sth ->fetchrow_array){                
         print A qq|"$t0","$t1","$t2","$t3","$t4","$t5","$t6","$t7","$t8","$t9","$t10","$t11","$t12","$t13","$t14","$t15","$t16","$t17","$t18","$t19","$t20","$t21","$t22","$t23","$t24","'$t25","$t26","$t27","$t28","$t29","$t30","$t31","$t32","$t33","$t34"  \n|;        
    }
    $sth->finish;
    
    close(A);
    
    $dbh->disconnect;   
    
    $c->response->redirect($c->uri_for('../upload/reportes/patmir3socios_clientes.csv'));
}



1;
