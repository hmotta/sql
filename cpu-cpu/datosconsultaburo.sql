drop table datosconsultaburo cascade;
CREATE TABLE datosconsultaburo
(
	ip character varying (15),
	usuarioid character varying (20),
	password character varying (20),
	PRIMARY KEY (usuarioid)
);

insert into datosconsultaburo values('201.122.198.9','MC55391032','WY9ldPKN');