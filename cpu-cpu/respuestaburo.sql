drop table respuestaburo cascade;
CREATE TABLE respuestaburo
(
	respuestaid serial not null,
	consultaid integer references consultaburo(consultaid),
	cadena text,
	PRIMARY KEY (respuestaid),
	unique (consultaid)
);
