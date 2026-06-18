SET GLOBAL event_scheduler = ON;

-- 1
CREATE EVENT ev_actualizar_pedidos_demorados
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
  UPDATE orders
  SET status = 'Delayed'
  WHERE requiredDate < CURDATE() 
    AND status = 'In Process';

-- 2
CREATE EVENT ev_limpiar_pagos_antiguos
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
  DELETE FROM payments
  WHERE paymentDate < DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 3
CREATE EVENT ev_premio_clientes_frecuentes
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 YEAR
DO
  UPDATE customers
  SET creditLimit = creditLimit * 1.10
  WHERE customerNumber IN (
      SELECT customerNumber
      FROM orders
      WHERE orderDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
      GROUP BY customerNumber
      HAVING COUNT(orderNumber) > 10
  );

-- 4
DELIMITER $$

CREATE PROCEDURE sp_asignar_empleados_huérfanos()
BEGIN
    DECLARE fin INT DEFAULT FALSE;
    DECLARE v_customerNumber INT;
    DECLARE v_emp_id INT;
    
    DECLARE cur_clientes CURSOR FOR 
        SELECT customerNumber FROM customers WHERE salesRepEmployeeNumber IS NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = TRUE;
    
    OPEN cur_clientes;
    
    bucle_clientes: LOOP
        FETCH cur_clientes INTO v_customerNumber;
        IF fin THEN
            LEAVE bucle_clientes;
        END IF;
        
        SELECT employeeNumber INTO v_emp_id
        FROM employees e
        LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
        WHERE e.jobTitle LIKE '%Sales Rep%'
        GROUP BY e.employeeNumber
        ORDER BY COUNT(c.customerNumber) ASC
        LIMIT 1;
        
        IF v_emp_id IS NOT NULL THEN
            UPDATE customers 
            SET salesRepEmployeeNumber = v_emp_id 
            WHERE customerNumber = v_customerNumber;
        END IF;
        
    END LOOP;
    
    CLOSE cur_clientes;
END$$

DELIMITER ;

CREATE EVENT ev_asignar_vendedores_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CONCAT(CURDATE() + INTERVAL 1 DAY, ' 07:00:00'))
DO
  CALL sp_asignar_empleados_huérfanos();

-- 5
CREATE TABLE IF NOT EXISTS daily_sales_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_date DATE NOT NULL,
    total_sales DECIMAL(10,2) NOT NULL
);

CREATE EVENT ev_reporte_ventas_diario
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CONCAT(CURDATE(), ' 23:59:00'))
ENDS CURRENT_TIMESTAMP + INTERVAL 3 MONTH
DO
  INSERT INTO daily_sales_reports (report_date, total_sales)
  SELECT 
      CURDATE(), 
      IFNULL(SUM(od.quantityOrdered * od.priceEach), 0)
  FROM orders o
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  WHERE DATE(o.orderDate) = CURDATE();

-- 6
CREATE EVENT ev_reducir_precio_stock_estancado
ON SCHEDULE EVERY 6 MONTH
STARTS CURRENT_TIMESTAMP
DO
  UPDATE products
  SET buyPrice = buyPrice * 0.95,
      MSRP = MSRP * 0.95
  WHERE productCode NOT IN (
      SELECT DISTINCT od.productCode
      FROM orders o
      JOIN orderdetails od ON o.orderNumber = od.orderNumber
      WHERE o.orderDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
  );