alter table tipoderiesgo add nivelderiesgo numeric;
alter table tipoderiesgo alter nivelderiesgo type numeric;
alter table tipoderiesgo add nivelderiesgomax numeric;

update tipoderiesgo set nivelderiesgo=8.5,nivelderiesgomax=10 where tipoderiesgoid=1;
update tipoderiesgo set nivelderiesgo=5.5,nivelderiesgomax=8.4 where tipoderiesgoid=2;
update tipoderiesgo set nivelderiesgo=0,nivelderiesgomax=5.4 where tipoderiesgoid=3;

--16-06-2011, Se actualiza matriz de riesgo de impulso.

CREATE or replace FUNCTION matrizriesgo(integer, character) RETURNS integer
    AS $_$
declare

  preferenciacaja alias for $1;
  pseriecaja alias for $2;

  friesgo1 numeric;
  friesgo2 numeric;
  friesgo3 numeric;
  friesgo4 numeric;
  friesgo5 numeric;
  friesgo6 numeric;
  friesgo7 numeric;
  friesgo8 numeric;    
  friesgo9 numeric;
  friesgo10 numeric;
  friesgo11 numeric;
  friesgo12 numeric;
  friesgo13 numeric;
  friesgo14 numeric;
  friesgo15 numeric;
  friesgo16 numeric;
  friesgo17 numeric;
  friesgo18 numeric;
  friesgo19 numeric;
  friesgo20 numeric;
  
  inivelriesgo numeric;

--  pmontoinusual numeric;
--  pdeposito numeric;
--  pinusual numeric;
  isocioid integer;
--  isujetoid integer;
--  dfecha date;
  stipomovimientoid char(2);
  
   -- Variables de conoce a tu cliente
--  fingresos numeric;  
  itipoderiesgoid integer;
--  stieneantecedentes character(1);

 ttextoprev text;
 r record;
-- matrisriesgo diferente
 matrizvariante integer;
  
begin
  ttextoprev:='';
  matrizvariante:=0;

  select mc.socioid,mc.tipomovimientoid into isocioid,stipomovimientoid from movicaja mc where referenciacaja =preferenciacaja and seriecaja=pseriecaja;

  select * into friesgo1,friesgo2,friesgo3,friesgo4,friesgo5,friesgo6,friesgo7,friesgo8,friesgo9,friesgo10,friesgo11,friesgo12,friesgo13,friesgo14,friesgo15,friesgo16,friesgo17,friesgo18,friesgo19,friesgo20 from generamatrizriesgo(isocioid,1,preferenciacaja,pseriecaja);
    
  inivelriesgo:=round((friesgo1+friesgo2+friesgo3+friesgo4+friesgo5+friesgo6+friesgo7+friesgo8+friesgo9+friesgo10+friesgo11+friesgo12+friesgo13+friesgo14+friesgo15+friesgo16+friesgo17+friesgo18+friesgo19+friesgo20)/20,1);

  select tipoderiesgoid into itipoderiesgoid from tipoderiesgo where inivelriesgo between nivelderiesgo and nivelderiesgomax;

  for r in select * from matrizclientes where id=(select max(id) from matrizclientes where socioid=isocioid)
  loop 
     if (friesgo1>r.friesgo1) then 
        ttextoprev:=ttextoprev||' Movimiento Fuera De La Matriz De Riesgo.';
	matrizvariante:=1;
     end if;
     if (friesgo9>r.friesgo9) then 
        ttextoprev:=ttextoprev||' El Monto De Las Operaciones Superan A Los Contenidos En La Matriz.';
	matrizvariante:=1;
     end if;
     if (friesgo11>r.friesgo11) then 
        ttextoprev:=ttextoprev||' Mas Operaciones De Las Especificadas En La Matriz.';
	matrizvariante:=1;
     end if;
  end loop;
  
  --Llenar la tabla de perfiltransaccional
  if matrizvariante=1 then
  insert into  perfiltransaccional(fechahora,socioid,referencia,serie,valorderiego,tipoderiesgoid,tipomovimientoid,observaciones) values (now(),isocioid,preferenciacaja,pseriecaja,inivelriesgo,itipoderiesgoid,stipomovimientoid,trim(ttextoprev)); 
  end if;
  
return itipoderiesgoid;

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

    
