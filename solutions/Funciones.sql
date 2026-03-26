USE classicmodels;

CREATE VIEW notPaymentClient as SELECT c.customerNumber
FROM customers c
RIGHT JOIN payments p ON p.customerNumber = c.customerNumber;

SELECT c.contactFirstName as nombre, c.contactLastName as apellido, c.phone as nrotelefono, c.addressLine1 as direccion
FROM customers c
JOIN orders o ON o.customerNumber = c.customerName
JOIN orderdetails o2 ON o2.orderNumber = o.orderNumber
WHERE o.orderDate < (NOW() - INTERVAL 2 YEAR) and 30000 <= (
															SELECT SUM(o3.priceEach) FROM orderdetails o3 		
															WHERE o2.orderNumber = o3.orderNumber
															Group by o3.orderNumber 
															)
;

##########  FUNCIONES  ##########

DELIMITER // 
CREATE FUNCTION ordenesPorFecha(fechaInicio date, fechaFin date, estado text) RETURNS INT DETERMINISTIC
BEGIN
	DECLARE cantOrdenes INT DEFAULT 0;
	SELECT COUNT(*) into cantOrdenes FROM orders o
	WHERE o.status = estado AND o.orderDate BETWEEN fechaInicio and fechaFin;
	RETURN cantOrdenes;
	END//
DELIMITER ;


SELECT ordenesPorFecha('2000-03-19', '2040-01-01', 'cancelled');


#2

DELIMITER // 
CREATE FUNCTION ordenesPorShipping(fechaInicio date, fechaFin date) RETURNS INT DETERMINISTIC
BEGIN
	DECLARE cantOrdenes INT DEFAULT 0;
	SELECT COUNT(*) into cantOrdenes FROM orders o
	WHERE o.shippedDate BETWEEN fechaInicio and fechaFin;
	RETURN cantOrdenes;
	END//
DELIMITER ;


SELECT ordenesPorShipping('2000-03-19', '2040-01-01');

DELIMITER //
CREATE FUNCTION clientPorCity(numeroCliente INT) RETURNS TEXT DETERMINISTIC
BEGIN 
	DECLARE cityCustomer TEXT DEFAULT "";
	SELECT c.city into cityCustomer FROM customers c
	WHERE c.customerNumber = numeroCliente;
	RETURN cityCustomer;
END //
DELIMITER ;

SELECT clientPorCity(1);
#7

DELIMITER // 
CREATE FUNCTION beneficioPorProducto(numeroDeProducto varchar(15), numeroDeOrden INT) RETURNS FLOAT DETERMINISTIC
BEGIN 
	DECLARE precioNormal FLOAT;
	DECLARE precioVenta FLOAT;
	DECLARE beneficio FLOAT;
	SELECT p.buyPrice, o.priceEach INTO precioNormal, precioVenta FROM products p
	JOIN orderdetails o ON p.productCode = o.productCode 
	WHERE o.productCode = numeroDeProducto and o.orderNumber = numeroDeOrden;
	SET  beneficio = (precioVenta - precioNormal); 
	RETURN beneficio;
END//
DELIMITER ;


drop function beneficioPorProducto;

SELECT beneficioPorProducto('S10_1678', 10107);

SELECT * FROM orderdetails o 
WHERE o.productCode = 'S10_1678';
#8
DELIMITER //;
CREATE FUNCTION checkCanceled (numeroOrden INT) RETURNS INT DETERMINISTIC
BEGIN
	DECLARE state INT DEFAULT 0;
	IF((SELECT o.status FROM orders o
	   WHERE numeroOrden = o.orderNumber) == '%Canceled%')
	   then state = -1
	   else state = 0
	end if;
	RETURN state;
END //
DELIMITER ;




