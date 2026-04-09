use repaso_ev_1;

DELIMITER //
CREATE FUNCTION pagoCompletoo(idCompra INT) RETURNS BOOLEAN DETERMINISTIC
BEGIN
	IF((SELECT SUM(p.monto) FROM pago p
		WHERE p.compra_id = idCompra) >= (SELECT precio FROM compra c WHERE c.id = idCompra)) THEN RETURN TRUE;
	ELSE RETURN FALSE;
	END IF;
END //
DELIMITER ;


SELECT (pagoCompletoo(101));

DELIMITER //
CREATE FUNCTION comisionEmpleado(dni_empleado INT) RETURNS INT DETERMINISTIC
BEGIN
	DECLARE sumaVendida INT; 
	DECLARE comisionEmpleado INT;
	DECLARE fechaIngresoEmpleado DATE;
	SELECT fechaIngreso INTO fechaIngresoEmpleado FROM empleado e WHERE e.dni = dni_empleado;
	SELECT SUM(c.precio) INTO sumaVendida FROM compra c WHERE c.empleado_dni = dni_empleado;
	
	IF (TIMESTAMPDIFF(YEAR, fechaIngresoEmpleado, CURRENT_DATE()) < 5) THEN RETURN 5; 
	
	ELSEIF(TIMESTAMPDIFF(YEAR, fechaIngresoEmpleado, CURRENT_DATE()) < 10) THEN RETURN 7; 
	ELSE RETURN 10;
	END IF;

END
DELIMITER ;

DROP FUNCTION comisionEmpleado;

SELECT (comisionEmpleado(32111222));

DELIMITER //
CREATE FUNCTION modelosVendidos(modelo_auto INT, mes INT) RETURNS INT DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(*) FROM compra c 
	JOIN auto a ON a.patente = c.auto_patente
	WHERE MONTH(c.fecha) = mes AND a.modelo_id = modelo_auto);  
END
DELIMITER ;

DROP FUNCTION modelosVendidos;

SELECT (modelosVendidos(2, 6))
