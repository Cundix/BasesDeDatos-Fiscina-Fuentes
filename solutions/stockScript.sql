-- MySQL dump 10.13  Distrib 8.0.29, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: stock
-- ------------------------------------------------------
-- Server version	8.0.31-0ubuntu0.20.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categoria`
--

create database stock;
use stock;

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `idCategoria` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idCategoria`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `codCliente` varchar(20) NOT NULL,
  `razonSocial` varchar(45) DEFAULT NULL,
  `contacto` varchar(45) DEFAULT NULL,
  `direccion` varchar(45) DEFAULT NULL,
  `telefono` varchar(45) DEFAULT NULL,
  `codPost` varchar(10) DEFAULT NULL,
  `porcDescuento` decimal(10,2) DEFAULT NULL,
  `Provincia_idProvincia` int NOT NULL,
  `categoria` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`codCliente`),
  KEY `fk_Cliente_Provincia` (`Provincia_idProvincia`),
  CONSTRAINT `fk_Cliente_Provincia` FOREIGN KEY (`Provincia_idProvincia`) REFERENCES `provincia` (`idProvincia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clientes_audit`
--

DROP TABLE IF EXISTS `clientes_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes_audit` (
  `idAudit` int NOT NULL AUTO_INCREMENT,
  `operacion` char(6) DEFAULT NULL,
  `user` varchar(45) DEFAULT NULL,
  `last_date_modified` date DEFAULT NULL,
  `codCliente` varchar(20) DEFAULT NULL,
  `razonSocial` varchar(45) DEFAULT NULL,
  `contacto` varchar(45) DEFAULT NULL,
  `direccion` varchar(45) DEFAULT NULL,
  `telefono` varchar(45) DEFAULT NULL,
  `codPost` varchar(10) DEFAULT NULL,
  `porcDescuento` decimal(10,2) DEFAULT NULL,
  `Provincia_idProvincia` int DEFAULT NULL,
  PRIMARY KEY (`idAudit`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `estado`
--

DROP TABLE IF EXISTS `estado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estado` (
  `idEstado` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idEstado`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ingresostock`
--

DROP TABLE IF EXISTS `ingresostock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingresostock` (
  `idIngreso` int NOT NULL,
  `fecha` datetime DEFAULT NULL,
  `remitoNro` varchar(45) DEFAULT NULL,
  `Proveedor_idProveedor` int NOT NULL,
  PRIMARY KEY (`idIngreso`),
  KEY `fk_IngresoStock_Proveedor1_idx` (`Proveedor_idProveedor`),
  CONSTRAINT `fk_IngresoStock_Proveedor1` FOREIGN KEY (`Proveedor_idProveedor`) REFERENCES `proveedor` (`idProveedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ingresostock_producto`
--

DROP TABLE IF EXISTS `ingresostock_producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingresostock_producto` (
  `item` int NOT NULL,
  `cantidad` int DEFAULT NULL,
  `IngresoStock_idIngreso` int NOT NULL,
  `Producto_codProducto` int NOT NULL,
  PRIMARY KEY (`item`,`IngresoStock_idIngreso`),
  KEY `fk_IngresoStock_Producto_IngresoStock1_idx` (`IngresoStock_idIngreso`),
  KEY `fk_IngresoStock_Producto_Producto1_idx` (`Producto_codProducto`),
  CONSTRAINT `fk_IngresoStock_Producto_IngresoStock1` FOREIGN KEY (`IngresoStock_idIngreso`) REFERENCES `ingresostock` (`idIngreso`),
  CONSTRAINT `fk_IngresoStock_Producto_Producto1` FOREIGN KEY (`Producto_codProducto`) REFERENCES `producto` (`codProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pedido`
--

DROP TABLE IF EXISTS `pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido` (
  `idPedido` int NOT NULL,
  `fecha` datetime DEFAULT NULL,
  `Estado_idEstado` int NOT NULL,
  `Cliente_codCliente` varchar(20) NOT NULL,
  PRIMARY KEY (`idPedido`),
  KEY `fk_Pedido_Estado1_idx` (`Estado_idEstado`),
  KEY `fk_Pedido_Cliente1_idx` (`Cliente_codCliente`),
  CONSTRAINT `fk_Pedido_Cliente1` FOREIGN KEY (`Cliente_codCliente`) REFERENCES `cliente` (`codCliente`),
  CONSTRAINT `fk_Pedido_Estado1` FOREIGN KEY (`Estado_idEstado`) REFERENCES `estado` (`idEstado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pedido_producto`
--

DROP TABLE IF EXISTS `pedido_producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_producto` (
  `item` int NOT NULL AUTO_INCREMENT,
  `cantidad` int DEFAULT NULL,
  `precioUnitario` decimal(10,2) DEFAULT NULL,
  `Producto_codProducto` int NOT NULL,
  `Pedido_idPedido` int NOT NULL,
  PRIMARY KEY (`item`,`Pedido_idPedido`),
  KEY `fk_Pedido_Producto_Producto1_idx` (`Producto_codProducto`),
  KEY `fk_Pedido_Producto_Pedido1_idx` (`Pedido_idPedido`),
  CONSTRAINT `fk_Pedido_Producto_Pedido1` FOREIGN KEY (`Pedido_idPedido`) REFERENCES `pedido` (`idPedido`),
  CONSTRAINT `fk_Pedido_Producto_Producto1` FOREIGN KEY (`Producto_codProducto`) REFERENCES `producto` (`codProducto`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `codProducto` int NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(100) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `Categoria_idCategoria` int NOT NULL,
  `stock` int DEFAULT NULL,
  PRIMARY KEY (`codProducto`),
  KEY `fk_Producto_Categoria1_idx` (`Categoria_idCategoria`),
  CONSTRAINT `fk_Producto_Categoria1` FOREIGN KEY (`Categoria_idCategoria`) REFERENCES `categoria` (`idCategoria`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `producto_proveedor`
--

DROP TABLE IF EXISTS `producto_proveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto_proveedor` (
  `Proveedor_idProveedor` int NOT NULL,
  `Producto_codProducto` int NOT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `demoraEntrega` int DEFAULT NULL,
  PRIMARY KEY (`Proveedor_idProveedor`,`Producto_codProducto`),
  KEY `fk_Proveedor_has_Producto_Producto1_idx` (`Producto_codProducto`),
  KEY `fk_Proveedor_has_Producto_Proveedor1_idx` (`Proveedor_idProveedor`),
  CONSTRAINT `fk_Proveedor_has_Producto_Producto1` FOREIGN KEY (`Producto_codProducto`) REFERENCES `producto` (`codProducto`),
  CONSTRAINT `fk_Proveedor_has_Producto_Proveedor1` FOREIGN KEY (`Proveedor_idProveedor`) REFERENCES `proveedor` (`idProveedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `producto_ubicacion`
--

DROP TABLE IF EXISTS `producto_ubicacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto_ubicacion` (
  `idProducto_Ubicacion` int NOT NULL,
  `cantidad` int DEFAULT NULL,
  `estanteria` varchar(45) DEFAULT NULL,
  `Producto_codProducto` int NOT NULL,
  PRIMARY KEY (`idProducto_Ubicacion`),
  KEY `fk_Producto_Ubicacion_Producto1_idx` (`Producto_codProducto`),
  CONSTRAINT `fk_Producto_Ubicacion_Producto1` FOREIGN KEY (`Producto_codProducto`) REFERENCES `producto` (`codProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `proveedor`
--

DROP TABLE IF EXISTS `proveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedor` (
  `idProveedor` int NOT NULL,
  `razonSocial` varchar(45) DEFAULT NULL,
  `contacto` varchar(45) DEFAULT NULL,
  `direccion` varchar(45) DEFAULT NULL,
  `telefono` varchar(45) DEFAULT NULL,
  `codPost` varchar(10) DEFAULT NULL,
  `Provincia_idProvincia` int NOT NULL,
  PRIMARY KEY (`idProveedor`),
  KEY `fk_Proveedor_Provincia1_idx` (`Provincia_idProvincia`),
  CONSTRAINT `fk_Proveedor_Provincia1` FOREIGN KEY (`Provincia_idProvincia`) REFERENCES `provincia` (`idProvincia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provincia`
--

DROP TABLE IF EXISTS `provincia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provincia` (
  `idProvincia` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idProvincia`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-11-17 15:23:35
