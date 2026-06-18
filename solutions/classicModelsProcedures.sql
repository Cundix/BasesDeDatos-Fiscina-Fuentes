USE classicmodels;

DELIMITER //
CREATE PROCEDURE mayorPrecio(out cantidad INT)
BEGIN 
	SELECT count(*) into cantidad from products p
	WHERE p.buyprice > (SELECT AVG(p2.buyprice) FROM products p2);
	SELECT * from products p4
	WHERE p4.buyprice > (SELECT AVG(p3.buyprice) FROM products p3);
END//
DELIMITER ;


CALL mayorPrecio(@cantidad);
SELECT @cantidad;

#EJ2

DELIMITER //
CREATE PROCEDURE deleteId (IN id INT, OUT resultado INT)
BEGIN
    IF EXISTS (SELECT 1 FROM orders WHERE orderNumber = id) THEN 
        DELETE FROM orderdetails WHERE orderNumber = id;
		DELETE FROM orders WHERE orderNumber = id;
        SET resultado = 1;
    ELSE
        SET resultado = 0;
    END IF; 
END//
DELIMITER ;

CALL deleteId(10100, @res);

SELECT @res AS '¿Se borró?';


DROP PROCEDURE IF EXISTS deleteId;

#3
DELIMITER //
CREATE PROCEDURE borrarLineaProducto(IN p_linea VARCHAR(50), OUT mensaje VARCHAR(100))
BEGIN
    IF EXISTS (SELECT 1 FROM productlines WHERE productLine = p_linea) THEN
        SET mensaje = 'La línea de productos no pudo borrarse porque contiene productos asociados';
    ELSE
        DELETE FROM productlines WHERE productlines = p_linea;
        SET mensaje = 'La línea de productos fue borrada';
    END IF;
END //
DELIMITER ;

CALL borrarLineaProducto('Classic Cars', @mensaje)
SELECT @mensaje;

DROP PROCEDURE IF EXISTS borrarLineaProducto;



