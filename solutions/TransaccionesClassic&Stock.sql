
USE classicmodels;

DELIMITER //

CREATE PROCEDURE realizar_compra_segura(
IN p_customerNumber INT,
IN p_productCode VARCHAR(15),
IN p_quantity INT,
IN p_requiredDate DATE
)
	BEGIN
	DECLARE v_stock INT;
	DECLARE v_nextOrderNumber INT;
	DECLARE v_priceEach DECIMAL(10,2);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	    ROLLBACK;
	    SELECT 'Error interno en la transacción. Compra cancelada.' AS Mensaje;
	END;
	
	START TRANSACTION;
	
	SELECT quantityInStock, buyPrice INTO v_stock, v_priceEach 
	FROM products 
	WHERE productCode = p_productCode;
	
	IF v_stock IS NULL OR v_stock < p_quantity THEN
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error, stock insuficiente';
	ELSE
	    SELECT MAX(orderNumber) + 1 INTO v_nextOrderNumber FROM orders;
	
	    INSERT INTO orders (orderNumber, orderDate, requiredDate, status, customerNumber)
	    VALUES (v_nextOrderNumber, CURDATE(), p_requiredDate, 'In Process', p_customerNumber);
	
	    INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
	    VALUES (v_nextOrderNumber, p_productCode, p_quantity, v_priceEach, 1);
	
	    UPDATE products 
	    SET quantityInStock = quantityInStock - p_quantity
	    WHERE productCode = p_productCode;
	
	    COMMIT;
	    SELECT 'Compra realizada con éxito' AS Mensaje;
	END IF;
END //

CREATE PROCEDURE registrar_pago_y_aumento(
IN p_customerNumber INT,
IN p_checkNumber VARCHAR(50),
IN p_amount DECIMAL(10,2)
)
	BEGIN
	DECLARE v_pago_aprobado BOOLEAN;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	    ROLLBACK;
	    SELECT 'Error en el proceso de pago.' AS Mensaje;
	END;
	
	START TRANSACTION;
	
	SET v_pago_aprobado = simular_pago_tarjeta(p_checkNumber);
	
	IF NOT v_pago_aprobado THEN
	    ROLLBACK;
	    SELECT 'Pago rechazado por la tarjeta.' AS Mensaje;
	ELSE
	    INSERT INTO payments (customerNumber, checkNumber, paymentDate, amount)
	    VALUES (p_customerNumber, p_checkNumber, CURDATE(), p_amount);
	
	    IF p_amount > 800000.00 THEN
	        UPDATE customers 
	        SET creditLimit = 1500000.00
	        WHERE customerNumber = p_customerNumber;
	    END IF;
	
	    COMMIT;
	    SELECT 'Pago registrado y crédito actualizado si correspondía.' AS Mensaje;
	END IF;
END //

CREATE PROCEDURE cancelar_pedido_devolver_stock(
IN p_orderNumber INT
)
	BEGIN
	DECLARE v_status VARCHAR(15);
	DECLARE v_prodCode VARCHAR(15);
	DECLARE v_cant INT;
	DECLARE fin INT DEFAULT 0;
	
	DECLARE cur_detalles CURSOR FOR 
	    SELECT productCode, quantityOrdered FROM orderdetails WHERE orderNumber = p_orderNumber;
	    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	    ROLLBACK;
	    SELECT 'Error al intentar cancelar el pedido.' AS Mensaje;
	END;
	
	START TRANSACTION;
	
	SELECT status INTO v_status FROM orders WHERE orderNumber = p_orderNumber;
	
	IF v_status = 'Shipped' THEN
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se puede cancelar un pedido que ya fue enviado';
	ELSE
	    UPDATE orders SET status = 'Cancelled' WHERE orderNumber = p_orderNumber;
	
	    OPEN cur_detalles;
	    bucle: LOOP
	        FETCH cur_detalles INTO v_prodCode, v_cant;
	        IF fin = 1 THEN
	            LEAVE bucle;
	        END IF;
	        
	        UPDATE products 
	        SET quantityInStock = quantityInStock + v_cant
	        WHERE productCode = v_prodCode;
	    END LOOP;
	    CLOSE cur_detalles;
	
	    COMMIT;
	    SELECT 'Pedido cancelado con éxito y stock devuelto.' AS Mensaje;
	END IF;
END //

CREATE PROCEDURE reemplazar_vendedor(
IN p_oldEmployeeNumber INT,
IN p_newEmployeeNumber INT
)
	BEGIN
	DECLARE v_oldOffice VARCHAR(10);
	DECLARE v_newOffice VARCHAR(10);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	    ROLLBACK;
	    SELECT 'Error al transferir la cartera de clientes.' AS Mensaje;
	END;
	
	START TRANSACTION;
	
	SELECT officeCode INTO v_oldOffice FROM employees WHERE employeeNumber = p_oldEmployeeNumber;
	SELECT officeCode INTO v_newOffice FROM employees WHERE employeeNumber = p_newEmployeeNumber;
	
	IF v_newOffice IS NULL OR v_oldOffice <> v_newOffice THEN
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Vendedor no apto para esta zona';
	ELSE
	    UPDATE customers 
	    SET salesRepEmployeeNumber = p_newEmployeeNumber
	    WHERE salesRepEmployeeNumber = p_oldEmployeeNumber;
	
	    COMMIT;
	    SELECT 'Reemplazo de vendedor realizado con éxito.' AS Mensaje;
	END IF;
END //

DELIMITER ;

USE stock;

DELIMITER //

CREATE PROCEDURE retirar_stock_estanteria(
IN p_id_producto INT,
IN p_estanteria VARCHAR(50),
IN p_cantidad INT
)
	BEGIN
	DECLARE v_stock_general INT;
	DECLARE v_stock_estanteria INT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	    ROLLBACK;
	    SELECT 'Error durante el retiro de mercadería.' AS Mensaje;
	END;
	
	START TRANSACTION;
	
	SELECT stock_general INTO v_stock_general FROM producto WHERE id = p_id_producto;
	SELECT cantidad INTO v_stock_estanteria FROM estanteria_producto 
	WHERE id_producto = p_id_producto AND estanteria = p_estanteria;
	
	IF v_stock_general < p_cantidad OR v_stock_estanteria < p_cantidad THEN
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Operación rechazada, stock insuficiente para retirar';
	ELSE
	    UPDATE estanteria_producto 
	    SET cantidad = cantidad - p_cantidad
	    WHERE id_producto = p_id_producto AND estanteria = p_estanteria;
	
	    UPDATE producto 
	    SET stock_general = stock_general - p_cantidad
	    WHERE id = p_id_producto;
	
	    COMMIT;
	    SELECT 'Retiro ejecutado con éxito.' AS Mensaje;
	END IF;
END //

CREATE PROCEDURE aplicar_aumento_categoria(
IN p_id_categoria INT,
IN p_porcentajeAumento DECIMAL(5,2)
)
	BEGIN
	DECLARE v_existe_cat INT;
	DECLARE v_cant_productos INT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	    ROLLBACK;
	    SELECT 'Error al aplicar el aumento masivo.' AS Mensaje;
	END;
	
	START TRANSACTION;
	
	SELECT COUNT(*) INTO v_existe_cat FROM categoria WHERE id = p_id_categoria;
	
	IF v_existe_cat = 0 THEN
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: categoría inexistente';
	ELSE
	    SELECT COUNT(*) INTO v_cant_productos FROM producto WHERE id_categoria = p_id_categoria;
	    
	    IF v_cant_productos = 0 THEN
	        SELECT 'La categoría existe pero no posee productos para aumentar.' AS Mensaje;
	        ROLLBACK;
	    ELSE
	        UPDATE producto 
	        SET precio = precio * (1 + (p_porcentajeAumento / 100))
	        WHERE id_categoria = p_id_categoria;
	
	        COMMIT;
	        SELECT 'Aumento aplicado correctamente a los productos.' AS Mensaje;
	    END IF;
	END IF;
END //

CREATE PROCEDURE registrar_ingreso_camion(
IN p_id_proveedor INT,
IN p_codigo_producto INT,
IN p_provincia_ingreso VARCHAR(50),
IN p_cantidad INT
)
BEGIN
DECLARE v_provincia_proveedor VARCHAR(50);
DECLARE v_id_ingreso INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
    SELECT 'Error al procesar el ingreso de mercadería.' AS Mensaje;
END;

START TRANSACTION;

SELECT provincia INTO v_provincia_proveedor FROM proveedor WHERE id = p_id_proveedor;

IF v_provincia_proveedor IS NULL OR v_provincia_proveedor <> p_provincia_ingreso THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ingreso rechazado: el proveedor no está habilitado para operar en esta provincia';
ELSE
    INSERT INTO ingresostock (id_proveedor, fecha_ingreso, provincia)
    VALUES (p_id_proveedor, CURDATE(), p_provincia_ingreso);

    SET v_id_ingreso = LAST_INSERT_ID();

    INSERT INTO ingresostock_producto (id_ingreso, id_producto, cantidad)
    VALUES (v_id_ingreso, p_codigo_producto, p_cantidad);

    UPDATE producto 
    SET stock_general = stock_general + p_cantidad
    WHERE id = p_codigo_producto;

    COMMIT;
    SELECT 'Ingreso de mercadería registrado con total éxito.' AS Mensaje;
END IF;
END //

DELIMITER ;