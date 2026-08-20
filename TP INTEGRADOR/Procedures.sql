DELIMITER //

-- ------------------------------------------------------------------------------
-- 1. PROCEDIMIENTO: Actualizar la reputación de un usuario
-- ------------------------------------------------------------------------------
-- Se llamaría cada vez que un comprador o vendedor es calificado.
-- Ajusta el valor de la reputación (0 a 100) promediando la nueva calificación.
CREATE PROCEDURE sp_actualizar_reputacion(
    IN p_id_usuario INT,
    IN p_nueva_calificacion INT
)
BEGIN
    DECLARE v_reputacion_actual DECIMAL(5,2);
    
    -- Validar que la calificación esté entre 0 y 100
    IF p_nueva_calificacion < 0 OR p_nueva_calificacion > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La calificación debe estar entre 0 y 100.';
    END IF;

    -- Obtener la reputación actual del usuario
    SELECT reputacion INTO v_reputacion_actual
    FROM usuarios 
    WHERE id_usuario = p_id_usuario;

    -- Si es nula (primera vez), se asigna la calificación directa. 
    -- Si no, se hace un promedio simple (para el TP es suficiente, en la vida real 
    -- se promedia contra la cantidad histórica de calificaciones).
    IF v_reputacion_actual IS NULL THEN
        UPDATE usuarios 
        SET reputacion = p_nueva_calificacion 
        WHERE id_usuario = p_id_usuario;
    ELSE
        UPDATE usuarios 
        SET reputacion = (v_reputacion_actual + p_nueva_calificacion) / 2 
        WHERE id_usuario = p_id_usuario;
    END IF;
END //


-- ------------------------------------------------------------------------------
-- 2. PROCEDIMIENTO: Crear una nueva publicación (Venta Directa)
-- ------------------------------------------------------------------------------
-- Facilita el proceso de insertar en la tabla principal
CREATE PROCEDURE sp_crear_publicacion_venta(IN p_id_producto INT, IN p_id_categoria INT, IN p_id_usuario INT, IN p_id_nivel INT, IN p_precio DECIMAL(12,2))
BEGIN
    -- Insertar en la tabla publicaciones con estado inicial 'Activa'
    INSERT INTO publicaciones (id_producto, id_categoria, id_usuario, id_nivel, precio, tipo, estado, fecha_creacion ) 
VALUES (p_id_producto, p_id_categoria, p_id_usuario, p_id_nivel, p_precio, 'Venta directa', 'Activa', NOW());
END; //

DELIMITER ;