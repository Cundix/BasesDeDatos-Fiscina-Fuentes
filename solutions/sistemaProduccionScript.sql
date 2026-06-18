use me1;

-- Crear la base de datos (opcional)
CREATE DATABASE SistemaProduccion;
USE SistemaProduccion;


CREATE TABLE Producto (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100),
    categoria VARCHAR(50),
    requiere_revision TINYINT(1)
);
-- 2. Tabla: Empleado

CREATE TABLE Empleado (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    sector VARCHAR(50)
);

-- 3. Tabla: OrdenProduccion
CREATE TABLE OrdenProduccion (
    id_orden INT PRIMARY KEY,
    fecha DATE,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

-- 4. Tabla: DetalleOrden
-- Nota: Esta tabla usa una llave primaria compuesta (id_orden e id_producto)
CREATE TABLE DetalleOrden (
    id_orden INT,
    id_producto INT,
    cantidad INT,
    defectuosos INT,
    PRIMARY KEY (id_orden, id_producto),
    FOREIGN KEY (id_orden) REFERENCES OrdenProduccion(id_orden),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

-- 5. Tabla: ReporteProduccion
CREATE TABLE ReporteProduccion (
    id_empleado INT PRIMARY KEY,
    total_producido INT,
    total_defectuosos INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);