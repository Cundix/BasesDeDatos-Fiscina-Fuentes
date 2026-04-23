use classicmodels;

/*Ej9*/
delimiter //
create procedure getCiudadesOffices(out ciudades varchar(4000))
begin
    declare done boolean default false;
    declare ciudad varchar(50);
    declare lista varchar(4000) default '';

    declare curs cursor for select city from offices;
    declare continue handler for not found set done = true;

    open curs;

    loop_ciudades: loop
        fetch curs into ciudad;
        if done then
            leave loop_ciudades;
        end if;

        if lista = '' then
            set lista = ciudad;
        else
            set lista = concat(lista, ', ', ciudad);
        end if;
    end loop;

    close curs;
    set ciudades = lista;
end //
delimiter ;



/*Ej10*/

delimiter //
create procedure insertCancelledOrders(out cantidad int)
begin
    declare done boolean default false;
    declare v_orderNumber, v_customerNumber int;
    declare v_orderDate, v_requiredDate, v_shippedDate date;
    declare v_status varchar(15);
    declare v_comments text;
    
    declare cur cursor for 
        select orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber 
        from orders where status = 'Cancelled';
    declare continue handler for not found set done = true;

    set cantidad = 0;
    open cur;

    read_loop: loop
        fetch cur into v_orderNumber, v_orderDate, v_requiredDate, v_shippedDate, v_status, v_comments, v_customerNumber;
        if done then leave read_loop; end if;

        insert into CancelledOrders values (v_orderNumber, v_orderDate, v_requiredDate, v_shippedDate, v_status, v_comments, v_customerNumber);
        set cantidad = cantidad + 1;
    end loop;

    close cur;
end //
delimiter ;

/*Ej11*/


delimiter //
create procedure alterCommentOrder(in p_customerNumber int)
begin
    declare hayFilas boolean default true;
    declare v_orderNumber int;
    declare v_total decimal(10,2);

    declare cur cursor for 
        select orderNumber from orders 
        where customerNumber = p_customerNumber 
        and (comments is null or trim(comments) = '');
    declare continue handler for not found set hayFilas = false;

    open cur;
    loop_orders: loop
        fetch cur into v_orderNumber;
        if not hayFilas then leave loop_orders; end if;

        select coalesce(sum(quantityOrdered * priceEach), 0) into v_total 
        from orderdetails where orderNumber = v_orderNumber;

        update orders 
        set comments = concat('El total de la orden es ', v_total) 
        where orderNumber = v_orderNumber;
    end loop;
    close cur;
end //
delimiter ;

/*Ej13*/

alter table employees add column comision decimal(10,2) default 0;

delimiter //
create procedure actualizarComision()
begin
    declare hayFilas boolean default true;
    declare v_employeeNumber int;
    declare v_ventas decimal(12,2);
    declare v_comision decimal(10,2);

    declare cur cursor for
        select e.employeeNumber, 
               coalesce(sum(od.quantityOrdered * od.priceEach), 0) as totalVentas
        from employees e
        left join customers c on e.employeeNumber = c.salesRepEmployeeNumber
        left join orders o on c.customerNumber = o.customerNumber and o.status <> 'Cancelled'
        left join orderdetails od on o.orderNumber = od.orderNumber
        group by e.employeeNumber;
    declare continue handler for not found set hayFilas = false;

    open cur;
    loop_emp: loop
        fetch cur into v_employeeNumber, v_ventas;
        if not hayFilas then leave loop_emp; end if;

        if v_ventas > 100000 then
            set v_comision = v_ventas * 0.05;
        elseif v_ventas >= 50000 then
            set v_comision = v_ventas * 0.03;
        else
            set v_comision = 0;
        end if;

        update employees e
        set comision = v_comision 
        where e.employeeNumber = v_employeeNumber;
    end loop;
    close cur;
end //
delimiter ;

/*Ej14*/
CREATE PROCEDURE asignarEmpleados()
BEGIN
	DECLARE hayFilas BOOLEAN DEFAULT TRUE
	
	DECLARE cur CURSOR FOR
		SELECT salesRepEmploeeNumber FROM customers 
	DECLARE CONTINUE handler FOR NOT FOUND SET hayfilas = FALSE;
	
	OPEN cur
	mainLoop:LOOP
		FETCH cur INTO v_employeeNumber, v_ventas;
        IF NOT hayFilas THEN LEAVE mainLoop; END IF;
	END LOOP
END

-- PROCEDURE DE LAS 10.000 FILAS
DROP TABLE IF EXISTS reporte_ventas;
CREATE TABLE reporte_ventas (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    orderNumber INT,
    orderDate DATE,
    customerName VARCHAR(50),
    productName VARCHAR(70),
    quantityOrdered INT,
    priceEach DECIMAL(10,2),
    total_linea DECIMAL(10,2),
    status VARCHAR(15)
);

DELIMITER //
CREATE PROCEDURE GenerarReporteConCursor()
BEGIN
    DECLARE v_orderNumber INT;
    DECLARE v_orderDate DATE;
    DECLARE v_customerName VARCHAR(50);
    DECLARE v_productName VARCHAR(70);
    DECLARE v_quantityOrdered INT;
    DECLARE v_priceEach DECIMAL(10,2);
    DECLARE v_status VARCHAR(15);
    DECLARE fin_cursor INT DEFAULT 0;

    DECLARE cursor_ventas CURSOR FOR 
        SELECT o.orderNumber, o.orderDate, c.customerName, p.productName, od.quantityOrdered, od.priceEach, o.status
        FROM orders o
        JOIN orderdetails od ON o.orderNumber = od.orderNumber
        JOIN products p ON od.productCode = p.productCode
        JOIN customers c ON o.customerNumber = c.customerNumber;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin_cursor = 1;

    OPEN cursor_ventas;
    bucle_lectura: LOOP
        FETCH cursor_ventas INTO v_orderNumber, v_orderDate, v_customerName, v_productName, v_quantityOrdered, v_priceEach, v_status;
        IF fin_cursor = 1 THEN LEAVE bucle_lectura; END IF;

        INSERT INTO reporte_ventas (orderNumber, orderDate, customerName, productName, quantityOrdered, priceEach, total_linea, status)
        VALUES (v_orderNumber, v_orderDate, v_customerName, v_productName, v_quantityOrdered, v_priceEach, (v_quantityOrdered * v_priceEach), v_status);
    END LOOP;
    CLOSE cursor_ventas;
END //
DELIMITER ;

CALL GenerarReporteConCursor();


SELECT COUNT(*) FROM reporte_ventas rv 

DELIMITER //
-- METER 10K DE FILAS
CREATE PROCEDURE GenerarOrdenesMasivas()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_cliente INT;
    DECLARE v_max_order INT;

    SELECT customerNumber INTO v_cliente FROM customers LIMIT 1;
    SELECT MAX(orderNumber) INTO v_max_order FROM orders;
    SET FOREIGN_KEY_CHECKS = 0;

    WHILE i <= 1000000 DO
        INSERT INTO orders (
            orderNumber, 
            orderDate, 
            requiredDate, 
            shippedDate, 
            status, 
            comments, 
            customerNumber
        ) 
        VALUES (
            v_max_order + i,             
            CURDATE(),                    
            DATE_ADD(CURDATE(), INTERVAL 7 DAY), 
            DATE_ADD(CURDATE(), INTERVAL 2 DAY), 
            'Shipped', 
            CONCAT('Orden masiva de prueba #', i), 
            v_cliente                     
        );
        
        SET i = i + 1;
    END WHILE;

    SET FOREIGN_KEY_CHECKS = 1;
    SELECT '10,000 órdenes insertadas en la tabla orders' AS Resultado;
END //

DELIMITER ;

CALL GenerarOrdenesMasivas();


DROP PROCEDURE IF EXISTS GenerarReporteConCursor;
DROP PROCEDURE IF EXISTS GenerarOrdenesMasivas;

INSERT INTO try_insert_masivo SELECT * FROM orders o;

CREATE TABLE try_insert_masivo (
    orderNumber INT PRIMARY KEY,
    orderDate DATE NOT NULL,
    requiredDate DATE NOT NULL,
    shippedDate DATE,
    status VARCHAR(50) NOT NULL,
    comments TEXT,
    customerNumber INT NOT NULL
);
