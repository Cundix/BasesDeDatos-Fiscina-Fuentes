CREATE USER analistaStock@localhost IDENTIFIED BY 'contraseñaSuperSegura!';
CREATE USER gestorDeProductos@localhost IDENTIFIED BY 'contraseñaSuperSegura!';
CREATE USER gestorReportes@localhost IDENTIFIED BY 'contraseñaSuperSegura!';
CREATE USER developer@localhost IDENTIFIED BY 'contraseñaSuperSegura!';
CREATE USER dba@localhost IDENTIFIED BY 'contraseñaSuperSegura!';

CREATE ROLE procedureManager;

SELECT * FROM mysql.`user` u;

GRANT SELECT ON stock.* TO procedureManager;
GRANT EXECUTE ON PROCEDURE stock.actualizarStock, reducirPrecio, actualizarPrecioPorProveedor TO procedureManager;

CREATE ROLE gestorDeOrdenes;
GRANT EXECUTE ON PROCEDURE borrarOrden, borrarLineaProductos, actualizarComentarios TO gestorDeOrdenes;
GRANT SELECT ON classicmodels.orderdetails TO gestorDeOrdenes; 
GRANT SELECT ON classicmodels.orders TO gestorDeOrdenes; 

CREATE ROLE reportesStockAndClassic; 
GRANT SELECT ON classicmodels.* TO reportesStockAndClassic; 
GRANT SELECT ON stock.* TO reportesStockAndClassic; 

CREATE ROLE dmlManager;
GRANT CREATE ON classicmodels.* TO dmlManager;
GRANT UPDATE ON classicmodels.* TO dmlManager;

CREATE ROLE admin;
GRANT ALL PRIVILEGES ON *.* TO admin;

GRANT admin TO dba@localhost;

SHOW GRANTS FOR dba@localhost;
SHOW GRANTS FOR admin;

GRANT dmlManager TO developer@localhost;

GRANT reportesStockAndClassic TO gestorReportes@localhost;

GRANT gestorDeOrdenes TO gestorDeProductos@localhost;

GRANT procedureManager TO analistaStock@localhost;

SELECT * FROM mysql.role_edges re;
