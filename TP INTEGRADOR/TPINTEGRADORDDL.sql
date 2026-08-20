USE TP_INTEGRADOR;

CREATE TABLE categorias_usuario (
    id_categoria_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    id_categoria_usuario INT DEFAULT 1,
    reputacion DECIMAL(5,2) DEFAULT 100.00 CHECK (reputacion BETWEEN 0 AND 100),
    total_ventas INT DEFAULT 0,
    monto_facturado DECIMAL(12,2) DEFAULT 0.00,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria_usuario) REFERENCES categorias_usuario(id_categoria_usuario) ON DELETE SET NULL
);

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    id_usuario INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);

CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    cant_publicaciones INT DEFAULT 0,
    id_usuario_creador INT,
    FOREIGN KEY (id_usuario_creador) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
);

CREATE TABLE niveles_publicacion (
    id_nivel INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE publicaciones (
    id_publicacion INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_categoria INT NOT NULL,
    id_usuario INT NOT NULL,
    id_nivel INT NOT NULL,
    precio DECIMAL(12,2) NOT NULL,
    tipo ENUM('VENTA', 'SUBASTA') NOT NULL,
    estado ENUM('ACTIVA', 'FINALIZADA', 'CANCELADA') DEFAULT 'ACTIVA',
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_nivel) REFERENCES niveles_publicacion(id_nivel)
);

CREATE TABLE medios_pago (
    id_medio_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE envios (
    id_envio INT AUTO_INCREMENT PRIMARY KEY,
    empresa VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE publicaciones_ventas (
    id_publicacion INT PRIMARY KEY,
    id_comprador INT NULL,
    fecha_compra DATETIME NULL,
    FOREIGN KEY (id_publicacion) REFERENCES publicaciones(id_publicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_comprador) REFERENCES usuarios(id_usuario)
);

CREATE TABLE publicaciones_medios_pago (
    id_publicacion INT NOT NULL,
    id_medio_pago INT NOT NULL,
    PRIMARY KEY (id_publicacion, id_medio_pago),
    FOREIGN KEY (id_publicacion) REFERENCES publicaciones_ventas(id_publicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_medio_pago) REFERENCES medios_pago(id_medio_pago)
);

CREATE TABLE publicaciones_envios (
    id_publicacion INT NOT NULL,
    id_envio INT NOT NULL,
    PRIMARY KEY (id_publicacion, id_envio),
    FOREIGN KEY (id_publicacion) REFERENCES publicaciones_ventas(id_publicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_envio) REFERENCES envios(id_envio)
);

CREATE TABLE publicaciones_subastas (
    id_publicacion INT PRIMARY KEY,
    monto_ofertado_actual DECIMAL(12,2) NOT NULL,
    fecha_fin_subasta DATETIME NOT NULL,
    FOREIGN KEY (id_publicacion) REFERENCES publicaciones(id_publicacion) ON DELETE CASCADE
);

CREATE TABLE pujas_subasta (
    id_puja INT AUTO_INCREMENT PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_usuario_postor INT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha_puja DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_publicacion) REFERENCES publicaciones_subastas(id_publicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario_postor) REFERENCES usuarios(id_usuario)
);

CREATE TABLE preguntas (
    id_pregunta INT AUTO_INCREMENT PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_usuario INT NOT NULL,
    contenido TEXT NOT NULL,
    id_pregunta_padre INT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_publicacion) REFERENCES publicaciones(id_publicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_pregunta_padre) REFERENCES preguntas(id_pregunta) ON DELETE CASCADE
);

ALTER TABLE publicaciones 
MODIFY COLUMN estado ENUM('ACTIVA', 'FINALIZADA') DEFAULT 'ACTIVA';


INSERT INTO categorias_usuario (nombre) VALUES ('Normal'), ('Platinum'), ('Gold');
INSERT INTO niveles_publicacion (nombre) VALUES ('Bronce'), ('Plata'), ('Oro'), ('Platino');
INSERT INTO medios_pago (nombre) VALUES ('Tarjeta de Crédito'), ('Tarjeta de Débito'), ('Pago Fácil'), ('Rapipago');
INSERT INTO envios (empresa) VALUES ('OCA'), ('Correo Argentino');