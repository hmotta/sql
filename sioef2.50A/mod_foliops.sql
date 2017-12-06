alter table foliops alter column movicajaid drop not null;
alter table foliops drop constraint foliops_tipomovimientoid_key;
alter table foliops drop COLUMN ejercicio;
alter table foliops drop COLUMN periodo;
alter table foliops add column fechaemision date;
alter table foliops add column fechacancela date;
--alter table foliops drop COLUMN fechaemision;
--alter table foliops add  COLUMN ejercicio integer;
--alter table foliops add  COLUMN periodo integer;