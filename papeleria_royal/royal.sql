-- phpMyAdmin SQL Dump
-- version 4.6.4
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 07-04-2017 a las 18:04:15
-- Versión del servidor: 5.7.15-log
-- Versión de PHP: 5.6.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `royal`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `clienteID` bigint(20) NOT NULL,
  `nombre` varchar(150) DEFAULT NULL,
  `rfc` varchar(13) DEFAULT NULL,
  `DomicilioID` bigint(20) DEFAULT NULL,
  `codigo` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`clienteID`, `nombre`, `rfc`, `DomicilioID`, `codigo`) VALUES
(1, 'HUGO ARIEL MOTA MARTINEZ', 'MOMH820925GB3', 0, '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `concepto`
--

CREATE TABLE `concepto` (
  `conceptoID` bigint(20) NOT NULL,
  `cantidad` varchar(20) DEFAULT NULL,
  `unidad` varchar(20) DEFAULT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `valor` float DEFAULT NULL,
  `importe` float DEFAULT NULL,
  `FacturaID` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `domicilio`
--

CREATE TABLE `domicilio` (
  `domicilioID` bigint(20) NOT NULL,
  `calle` varchar(150) DEFAULT NULL,
  `noext` varchar(80) DEFAULT NULL,
  `noint` varchar(80) DEFAULT NULL,
  `colonia` varchar(150) DEFAULT NULL,
  `cp` varchar(5) DEFAULT NULL,
  `ciudad` varchar(150) DEFAULT NULL,
  `municipio` varchar(150) DEFAULT NULL,
  `EstadoID` bigint(20) DEFAULT NULL,
  `movil1` varchar(50) DEFAULT NULL,
  `movil2` varchar(50) DEFAULT NULL,
  `fijo1` varchar(50) DEFAULT NULL,
  `fijo2` varchar(50) DEFAULT NULL,
  `web` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `domicilio`
--

INSERT INTO `domicilio` (`domicilioID`, `calle`, `noext`, `noint`, `colonia`, `cp`, `ciudad`, `municipio`, `EstadoID`, `movil1`, `movil2`, `fijo1`, `fijo2`, `web`, `email`) VALUES
(2, '', '', '', '', '', '', '', 0, '', '', '', '', '', ''),
(3, 'CARRETERA PANAMERICANA KM 542.5', 'SN', '', 'SAN FRANCISCO', '', 'OAXACA', 'OAXACA DE JUAREZ', 20, '', '', '', '', '', ''),
(4, '1A PRIVADA DE NIÑOS HEROES', '114-A', '', 'SANTA MARIA', '68030', 'OAXACA', 'OAXACA DE JUAREZ', 20, '9512229247', '', '', '', '', 'arielmot@hotmail.com'),
(5, '', '', '', '', '', '', '', 0, '', '', '', '', '', ''),
(6, '', '', '', '', '', '', '', 0, '', '', '', '', '', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `empresaID` bigint(20) NOT NULL,
  `nombre` varchar(150) DEFAULT NULL,
  `rfc` varchar(13) DEFAULT NULL,
  `curp` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`empresaID`, `nombre`, `rfc`, `curp`) VALUES
(7, 'HUGO ARIEL MOTA MARTINEZ', 'MOMH82029258G', ''),
(8, 'GLENDA MAGALY GARCIA CALERO', 'MOMH82029258G', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado`
--

CREATE TABLE `estado` (
  `estadoID` bigint(20) NOT NULL,
  `Estado` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `estado`
--

INSERT INTO `estado` (`estadoID`, `Estado`) VALUES
(1, 'AGUASCALIENTES'),
(2, 'BAJA CALIFORNIA NORTE'),
(3, 'BAJA CALIFORNIA SUR'),
(4, 'CAMPECHE'),
(7, 'CHIAPAS'),
(8, 'CHIHUAHUA'),
(5, 'COAHUILA'),
(6, 'COLIMA'),
(9, 'DISTRITO FEDERAL'),
(10, 'DURANGO'),
(99, 'EXTRANJERO'),
(11, 'GUANAJUATO'),
(12, 'GUERRERO'),
(13, 'HIDALGO'),
(14, 'JALISCO'),
(15, 'MEXICO'),
(16, 'MICHOACAN'),
(17, 'MORELOS'),
(18, 'NAYARIT'),
(19, 'NUEVO LEON'),
(20, 'OAXACA'),
(21, 'PUEBLA'),
(22, 'QUERETARO'),
(23, 'QUINTANA ROO'),
(24, 'SAN LUIS POTOSI'),
(25, 'SINALOA'),
(26, 'SONORA'),
(27, 'TABASCO'),
(28, 'TAMAULIPAS'),
(29, 'TLAXCALA'),
(30, 'VERACRUZ'),
(31, 'YUCATAN'),
(32, 'ZACATECAS');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `facturaID` bigint(20) NOT NULL,
  `folio` varchar(50) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `ProveedorID` bigint(20) DEFAULT NULL,
  `impuestos` float DEFAULT NULL,
  `total` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marca`
--

CREATE TABLE `marca` (
  `marcaID` bigint(20) NOT NULL,
  `Marca` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `marca`
--

INSERT INTO `marca` (`marcaID`, `Marca`) VALUES
(6, 'LG\r\nLG'),
(1, 'MICROSOFT'),
(5, 'PIXXO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `precio`
--

CREATE TABLE `precio` (
  `precioID` bigint(20) NOT NULL,
  `precio` decimal(24,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `productoID` bigint(20) NOT NULL,
  `codigo` varchar(50) DEFAULT NULL,
  `descripcion` varchar(50) DEFAULT NULL,
  `IVA` float DEFAULT NULL,
  `precio_publico` float DEFAULT NULL,
  `precio_mediomayoreo` float DEFAULT NULL,
  `precio_mayoreo` float DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `alerta_en` int(11) DEFAULT NULL,
  `MarcaID` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`productoID`, `codigo`, `descripcion`, `IVA`, `precio_publico`, `precio_mediomayoreo`, `precio_mayoreo`, `fecha_registro`, `alerta_en`, `MarcaID`) VALUES
(1, '123456789', 'MOUSE INALAMBRICO NEGRO', 0.15, 150, 0, 0, '2017-03-15', 0, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `proveedorID` bigint(20) NOT NULL,
  `codigo` varchar(50) DEFAULT NULL,
  `razonsocial` varchar(250) DEFAULT NULL,
  `rfc` varchar(13) DEFAULT NULL,
  `DomicilioID` bigint(20) DEFAULT NULL,
  `IVA` float DEFAULT NULL,
  `utilidad` float DEFAULT NULL,
  `flete` float DEFAULT NULL,
  `descuento1` float DEFAULT NULL,
  `descuento2` float DEFAULT NULL,
  `descuento3` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`proveedorID`, `codigo`, `razonsocial`, `rfc`, `DomicilioID`, `IVA`, `utilidad`, `flete`, `descuento1`, `descuento2`, `descuento3`) VALUES
(1, 'DOMINOS', 'ADMINISTRADORA DE PERSONAL PAKTINEMI, S.A. DE C.V.', 'APP1212045V1', 5, 0, 0, 0, 0, 0, 0),
(2, 'OXIFUEL', 'AXIONA SOLUCIONES ESTRATEGICAS S DE RL', 'ASE140711TXA', 6, 0, 0, 0, 0, 0, 0),
(3, 'PEAJE', 'FONDO NACIONAL DE INFRAESTRUCTURA', 'FNI970829JR9', 0, 0, 0, 0, 0, 0, 0),
(5, 'GAS', 'POLIEMIXTEC S.A. DE C.V.', 'POL730302TK8 ', 0, 0, 0, 0, 0, 0, 0),
(6, 'ALBERIQUE', 'GASOLINERA ALBERIQUE SA DE CV', 'GAL120812IHA', 0, 0, 0, 0, 0, 0, 0),
(14, '', '', '', 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sucursal`
--

CREATE TABLE `sucursal` (
  `sucursalID` bigint(20) NOT NULL,
  `codigo` varchar(50) DEFAULT NULL,
  `nombre` varchar(150) DEFAULT NULL,
  `DomicilioID` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`clienteID`),
  ADD UNIQUE KEY `rfc` (`rfc`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `WDIDX14902077880` (`DomicilioID`);

--
-- Indices de la tabla `concepto`
--
ALTER TABLE `concepto`
  ADD PRIMARY KEY (`conceptoID`),
  ADD KEY `WDIDX14899641885` (`FacturaID`);

--
-- Indices de la tabla `domicilio`
--
ALTER TABLE `domicilio`
  ADD PRIMARY KEY (`domicilioID`),
  ADD KEY `WDIDX14897980040` (`EstadoID`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`empresaID`);

--
-- Indices de la tabla `estado`
--
ALTER TABLE `estado`
  ADD PRIMARY KEY (`estadoID`),
  ADD UNIQUE KEY `Estado` (`Estado`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`facturaID`),
  ADD KEY `WDIDX14899641884` (`ProveedorID`);

--
-- Indices de la tabla `marca`
--
ALTER TABLE `marca`
  ADD PRIMARY KEY (`marcaID`),
  ADD UNIQUE KEY `Marca` (`Marca`);

--
-- Indices de la tabla `precio`
--
ALTER TABLE `precio`
  ADD PRIMARY KEY (`precioID`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`productoID`),
  ADD KEY `WDIDX14902088210` (`MarcaID`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`proveedorID`),
  ADD UNIQUE KEY `rfc` (`rfc`),
  ADD KEY `WDIDX14898046620` (`DomicilioID`);

--
-- Indices de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD PRIMARY KEY (`sucursalID`),
  ADD KEY `WDIDX14898126940` (`DomicilioID`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `clienteID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `concepto`
--
ALTER TABLE `concepto`
  MODIFY `conceptoID` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `domicilio`
--
ALTER TABLE `domicilio`
  MODIFY `domicilioID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `empresaID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT de la tabla `estado`
--
ALTER TABLE `estado`
  MODIFY `estadoID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;
--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `facturaID` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `marca`
--
ALTER TABLE `marca`
  MODIFY `marcaID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `precio`
--
ALTER TABLE `precio`
  MODIFY `precioID` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `productoID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `proveedorID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `sucursalID` bigint(20) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
