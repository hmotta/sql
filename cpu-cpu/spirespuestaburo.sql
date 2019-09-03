CREATE or replace FUNCTION spirespuestaburo(integer,text) RETURNS integer
AS $_$
declare
	pconsultaid alias for $1;
	pcadena alias for $2;
begin
	insert into respuestaburo (consultaid,cadena) values (pconsultaid,pcadena);
	return currval('respuestaburo_respuestaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;