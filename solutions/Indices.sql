DELIMITER $$

DROP PROCEDURE IF EXISTS InsertarPedidosMasivos$$

CREATE PROCEDURE InsertarPedidosMasivos()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_pedidos INT DEFAULT 20000;
    DECLARE v_customerNumber INT;
    DECLARE v_orderDate DATE;
    DECLARE v_requiredDate DATE;
    DECLARE v_shippedDate DATE;
    DECLARE v_status VARCHAR(15);
    DECLARE v_comments TEXT;
    DECLARE v_nextOrderNumber INT;

    -- Desactivar índices y autocommit para acelerar la inserción masiva
    SET AUTOCOMMIT = 0;
    
    -- Obtener el número de pedido inicial para evitar duplicados en la llave primaria
    SELECT IFNULL(MAX(orderNumber), 10000) INTO v_nextOrderNumber FROM orders;

    -- Bucle para generar los 20,000 pedidos
    WHILE i <= max_pedidos DO
        SET v_nextOrderNumber = v_nextOrderNumber + 1;

        -- 1. Seleccionar un cliente aleatorio que ya exista en la base de datos
        SELECT customerNumber INTO v_customerNumber 
        FROM customers 
        ORDER BY RAND() 
        LIMIT 1;

        -- 2. Generar una fecha de pedido aleatoria (entre 2023 y 2026)
        SET v_orderDate = DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 1200) DAY);
        
        -- La fecha requerida suele ser entre 3 y 7 días después del pedido
        SET v_requiredDate = DATE_ADD(v_orderDate, INTERVAL FLOOR(RAND() * 5) + 3 DAY);

        -- 3. Asignar un estado aleatorio usando valores reales de classicmodels
        CASE FLOOR(RAND() * 6)
            WHEN 0 THEN 
                SET v_status = 'Shipped';
                SET v_shippedDate = DATE_ADD(v_orderDate, INTERVAL FLOOR(RAND() * 3) + 1 DAY);
                SET v_comments = NULL;
            WHEN 1 THEN 
                SET v_status = 'Shipped';
                SET v_shippedDate = DATE_ADD(v_orderDate, INTERVAL FLOOR(RAND() * 3) + 1 DAY);
                SET v_comments = 'Customer requested express delivery.';
            WHEN 2 THEN 
                SET v_status = 'Pending';
                SET v_shippedDate = NULL;
                SET v_comments = 'Waiting for payment confirmation.';
            WHEN 3 THEN 
                SET v_status = 'In Process';
                SET v_shippedDate = NULL;
                SET v_comments = NULL;
            WHEN 4 THEN 
                SET v_status = 'Resolved';
                SET v_shippedDate = DATE_ADD(v_orderDate, INTERVAL FLOOR(RAND() * 4) + 1 DAY);
                SET v_comments = 'Dispute resolved successfully.';
            ELSE 
                SET v_status = 'Cancelled';
                SET v_shippedDate = NULL;
                SET v_comments = 'Customer cancelled before shipping.';
        END CASE;

        -- 4. Insertar el pedido en la tabla
        INSERT INTO orders (orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber)
        VALUES (v_nextOrderNumber, v_orderDate, v_requiredDate, v_shippedDate, v_status, v_comments, v_customerNumber);

        -- Hacer un commit parcial cada 5,000 registros para no saturar la memoria transaccional
        IF MOD(i, 5000) = 0 THEN
            COMMIT;
        END IF;

        SET i = i + 1;
    END WHILE;

    -- Confirmar los registros restantes
    COMMIT;
    SET AUTOCOMMIT = 1;
    
    SELECT '¡Proceso completado con éxito! Se insertaron 20,000 pedidos.' AS Resultado;
END$$

DELIMITER ; 


CALL InsertarPedidosMasivos();

explain analyze select * from orders o where o.orderNumber = 19999 and status = 'DELIVERED';

Explain analyze select * from orders o where o.orderDate between 2026-04-23 and 2020-04-23;

CREATE INDEX nombre_del_indice
ON orders (orderDate);

CREATE INDEX statusAndCN
ON orders (status, customerNumber);







