--
-- PostgreSQL database dump
--

-- Dumped from database version 8.2.7
-- Dumped by pg_dump version 9.5.4


--
-- Name: nivelderiesgo; Type: TABLE; Schema: public; Owner: sistema
--
drop table nivelderiesgo;

CREATE TABLE nivelderiesgo (
    nivelderiesgoid integer NOT NULL,
    socioid integer NOT NULL,
    promedio integer,
    descripcion text,
    riesgomanual text
);


ALTER TABLE nivelderiesgo OWNER TO sistema;

--
-- Name: nivelderiesgo_nivelderiesgoid_seq; Type: SEQUENCE; Schema: public; Owner: sistema
--

CREATE SEQUENCE nivelderiesgo_nivelderiesgoid_seq
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE nivelderiesgo_nivelderiesgoid_seq OWNER TO sistema;

--
-- Name: nivelderiesgo_nivelderiesgoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sistema
--

ALTER SEQUENCE nivelderiesgo_nivelderiesgoid_seq OWNED BY nivelderiesgo.nivelderiesgoid;


--
-- Name: nivelderiesgoid; Type: DEFAULT; Schema: public; Owner: sistema
--

ALTER TABLE ONLY nivelderiesgo ALTER COLUMN nivelderiesgoid SET DEFAULT nextval('nivelderiesgo_nivelderiesgoid_seq'::regclass);


--
-- Data for Name: nivelderiesgo; Type: TABLE DATA; Schema: public; Owner: sistema
--



--
-- Name: nivelderiesgo_nivelderiesgoid_seq; Type: SEQUENCE SET; Schema: public; Owner: sistema
--

SELECT pg_catalog.setval('nivelderiesgo_nivelderiesgoid_seq', 2, true);


--
-- Name: nivelderiesgo_pkey; Type: CONSTRAINT; Schema: public; Owner: sistema
--

ALTER TABLE ONLY nivelderiesgo
    ADD CONSTRAINT nivelderiesgo_pkey PRIMARY KEY (nivelderiesgoid);


--
-- Name: nivelderiesgo_socioid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sistema
--

ALTER TABLE ONLY nivelderiesgo
    ADD CONSTRAINT nivelderiesgo_socioid_fkey FOREIGN KEY (socioid) REFERENCES socio(socioid);


--
-- PostgreSQL database dump complete
--

