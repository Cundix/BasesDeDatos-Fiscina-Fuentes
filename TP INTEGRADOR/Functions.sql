DELIMITER //

-- ------------------------------------------------------------------------------
-- 1. FUNCIÓN: Obtener la categoría de reputación en texto
-- ------------------------------------------------------------------------------
-- Toma el valor numérico (0 a 100) y devuelve un texto amigable para mostrar 
-- en la interfaz. Ideal para usar en los listados.
CREATE FUNCTION fn_etiqueta_reputacion(p_reputacion DECIMAL(5,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_etiqueta VARCHAR(20);
    
    IF p_reputacion IS NULL THEN
        SET v_etiqueta = 'Nuevo / Sin ventas';
    ELSEIF p_reputacion >= 80 THEN
        SET v_etiqueta = 'Excelente';
    ELSEIF p_reputacion >= 50 THEN
        SET v_etiqueta = 'Buena';
    ELSE
        SET v_etiqueta = 'Mala';
    END IF;
    
    RETURN v_etiqueta;
END; //


-- ------------------------------------------------------------------------------
-- 2. FUNCIÓN: Calcular los días restantes de una subasta
-- ------------------------------------------------------------------------------
-- Calcula cuánto falta para que termine una publicación de tipo subasta.
-- Si la subasta ya venció, devuelve 0.
CREATE FUNCTION fn_dias_restantes_subasta(p_id_publicacion INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_dias INT;
    
    -- Calcula la diferencia en días entre la fecha de fin y el momento actual
    SELECT DATEDIFF(fecha_fin_subasta, NOW()) INTO v_dias
    FROM publicaciones_subastas
    WHERE id_publicacion = p_id_publicacion;
    
    -- Si el resultado es negativo (ya pasó la fecha), devolvemos 0
    IF v_dias < 0 THEN
        SET v_dias = 0;
    END IF;
    
    -- Si no encuentra la subasta, devuelve 0 por seguridad usando COALESCE
    RETURN COALESCE(v_dias, 0);
END; //

DELIMITER ;