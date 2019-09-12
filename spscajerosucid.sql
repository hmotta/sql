CREATE or replace FUNCTION spscajerosucid(character varying) RETURNS character
    AS $_$
declare
	pusuriaioid alias for $1;
	ssuc character (4);
begin
	 select suc into ssuc from cajerosuc where serie=pusuriaioid;
	 if ssuc='001-' then
		return 'Yolomecatl';
	 elsif ssuc='002-' then
		return 'Nochixtlan';
	 elsif ssuc='003-' then
		return 'Oaxaca';
	 elsif ssuc='005-' then
		return 'Huajuapan';
	 elsif ssuc='006-' then
		return 'Nicananduta';
	 elsif ssuc='007-' then
		return 'Coixtlahuaca';
	 elsif ssuc='008-' then
		return 'Tepelmeme';
	 elsif ssuc='010-' then
		return 'Tezoatlan';
	 elsif ssuc='011-' then
		return 'Cuicatlan';
	 end if;
	return '';
end
$_$
LANGUAGE plpgsql SECURITY DEFINER;
