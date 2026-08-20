USE TP_INTEGRADOR

-- SET GLOBAL event_scheduler = ON;

DELIMITER //

-- ------------------------------------------------------------------------------
-- 1. TRIGGER: Validar reglas de Preguntas y Respuestas
-- ------------------------------------------------------------------------------
CREATE TRIGGER trg_before_insert_pregunta
BEFORE INSERT ON preguntas
FOR EACH ROW
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_id_vendedor INT;

    -- Obtener el estado de la publicación y quién es el vendedor
    SELECT estado, id_usuario INTO v_estado, v_id_vendedor
    FROM publicaciones WHERE id_publicacion = NEW.id_publicacion;

    -- Regla: Solo en publicaciones activas
    IF v_estado != 'Activa' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La publicación finalizó. Las preguntas y respuestas están inhabilitadas.';
    END IF;

    -- Regla: Si es una respuesta (id_pregunta_padre no es nulo), validar vendedor
    IF NEW.id_pregunta_padre IS NOT NULL THEN
        IF NEW.id_usuario != v_id_vendedor THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Solo el usuario vendedor puede responder las preguntas.';
        END IF;
    END IF;
END//


-- ------------------------------------------------------------------------------
-- 2. TRIGGER: Finalizar venta directa y actualizar categorías de usuario
-- ------------------------------------------------------------------------------
CREATE TRIGGER trg_after_insert_venta
AFTER INSERT ON publicaciones_ventas
FOR EACH ROW
BEGIN
    DECLARE v_id_vendedor INT;
    DECLARE v_precio DECIMAL(12,2);
    DECLARE v_total_ventas INT;
    DECLARE v_monto_facturado DECIMAL(12,2);
    DECLARE v_nuevo_id_categoria INT;

    -- Obtener el vendedor y el precio de la publicación
    SELECT id_usuario, precio INTO v_id_vendedor, v_precio
    FROM publicaciones WHERE id_publicacion = NEW.id_publicacion;

    -- Marcar la publicación como finalizada
    UPDATE publicaciones 
    SET estado = 'Finalizada' 
    WHERE id_publicacion = NEW.id_publicacion;

    -- Actualizar estadísticas del vendedor (se asume que se inicializan en 0 al crear)
    UPDATE usuarios
    SET total_ventas = COALESCE(total_ventas, 0) + 1,
        monto_facturado = COALESCE(monto_facturado, 0) + v_precio
    WHERE id_usuario = v_id_vendedor;

    -- Recalcular la categoría del usuario según reglas de negocio
    SELECT total_ventas, monto_facturado INTO v_total_ventas, v_monto_facturado
    FROM usuarios WHERE id_usuario = v_id_vendedor;

    IF v_total_ventas >= 11 OR v_monto_facturado >= 1000000 THEN
        SELECT id_categoria_usuario INTO v_nuevo_id_categoria FROM categorias_usuario WHERE nombre = 'Gold';
    ELSEIF (v_total_ventas BETWEEN 6 AND 10) OR v_monto_facturado >= 100000 THEN
        SELECT id_categoria_usuario INTO v_nuevo_id_categoria FROM categorias_usuario WHERE nombre = 'Platinum';
    ELSEIF v_total_ventas BETWEEN 1 AND 5 THEN
        SELECT id_categoria_usuario INTO v_nuevo_id_categoria FROM categorias_usuario WHERE nombre = 'Normal';
    END IF;

    -- Actualizar si aplica una nueva categoría
    IF v_nuevo_id_categoria IS NOT NULL THEN
        UPDATE usuarios SET id_categoria_usuario = v_nuevo_id_categoria WHERE id_usuario = v_id_vendedor;
    END IF;
END//


-- ------------------------------------------------------------------------------
-- 3. TRIGGER: Evitar eliminación de productos con publicaciones activas
-- ------------------------------------------------------------------------------
CREATE TRIGGER trg_before_delete_producto
BEFORE DELETE ON productos
FOR EACH ROW
BEGIN
    DECLARE v_cant_activas INT;
    
    SELECT COUNT(*) INTO v_cant_activas 
    FROM publicaciones 
    WHERE id_producto = OLD.id_producto AND estado = 'Activa';
    
    IF v_cant_activas > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Primero debe finalizar la publicación para poder eliminar el producto.';
    END IF;
END//


-- ------------------------------------------------------------------------------
-- 4. TRIGGER: Evitar eliminación de categorías con publicaciones activas
-- ------------------------------------------------------------------------------
CREATE TRIGGER trg_before_delete_categoria
BEFORE DELETE ON categorias
FOR EACH ROW
BEGIN
    DECLARE v_cant_activas INT;
    
    SELECT COUNT(*) INTO v_cant_activas 
    FROM publicaciones 
    WHERE id_categoria = OLD.id_categoria AND estado = 'Activa';
    
    IF v_cant_activas > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: No se puede eliminar una categoría con publicaciones activas asociadas.';
    END IF;
END//


-- ------------------------------------------------------------------------------
-- 5. TRIGGER: Lógica de Pujas en Subastas
-- ------------------------------------------------------------------------------
CREATE TRIGGER trg_after_insert_puja
AFTER INSERT ON pujas_subasta
FOR EACH ROW
BEGIN
    DECLARE v_monto_actual DECIMAL(12,2);
    
    -- Obtener la oferta actual
    SELECT monto_ofertado_actual INTO v_monto_actual
    FROM publicaciones_subastas
    WHERE id_publicacion = NEW.id_publicacion;
    
    -- Si el monto de la puja es mayor, actualizar el monto ofertado actual
    IF NEW.monto > COALESCE(v_monto_actual, 0) THEN
        UPDATE publicaciones_subastas
        SET monto_ofertado_actual = NEW.monto
        WHERE id_publicacion = NEW.id_publicacion;
    END IF;
END//


-- ------------------------------------------------------------------------------
-- 6. EVENTO: Finalización automática de subastas
-- ------------------------------------------------------------------------------
-- Este evento corre cada 1 minuto (se puede ajustar a horas o días) y cierra
-- las subastas cuya fecha límite ya pasó.
CREATE EVENT ev_finalizar_subastas_vencidas
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
    UPDATE publicaciones p
    JOIN publicaciones_subastas ps ON p.id_publicacion = ps.id_publicacion
    SET p.estado = 'Finalizada'
    WHERE ps.fecha_fin_subasta <= NOW() AND p.estado = 'Activa';
END //

DELIMITER ;
