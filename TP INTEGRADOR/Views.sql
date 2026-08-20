-- ==============================================================================
-- VISTAS (VIEWS) - Optimizan las consultas de lectura y búsquedas
-- ==============================================================================

-- 1. VISTA: Catálogo de Publicaciones Activas
-- Une todas las tablas necesarias para mostrar el listado de productos a la venta, 
-- trayendo el nombre del vendedor, la categoría y ordenando por la exposición.
CREATE VIEW vw_publicaciones_activas AS
SELECT 
    p.id_publicacion,
    prod.nombre AS producto,
    prod.descripcion,
    c.nombre AS categoria,
    p.precio,
    p.tipo AS modalidad_venta,
    np.nombre AS nivel_exposicion,
    u.nombre AS vendedor,
    u.reputacion AS reputacion_vendedor
FROM publicaciones p
JOIN productos prod ON p.id_producto = prod.id_producto
JOIN categorias c ON p.id_categoria = c.id_categoria
JOIN usuarios u ON p.id_usuario = u.id_usuario
JOIN niveles_publicacion np ON p.id_nivel = np.id_nivel
WHERE p.estado = 'Activa'
-- Ordenamos para que las publicaciones Oro/Platino salgan primero 
-- (Asumiendo que a mayor id_nivel, mayor prioridad)
ORDER BY p.id_nivel DESC; 


-- ------------------------------------------------------------------------------
-- 2. VISTA: Resumen y estado de los Usuarios
-- Ideal para el administrador del sistema, muestra de un vistazo en qué 
-- categoría (Normal, Platinum, Gold) está cada usuario y su reputación.
CREATE VIEW vw_estado_usuarios AS
SELECT 
    u.id_usuario,
    u.nombre,
    u.email,
    cu.nombre AS categoria_actual,
    u.reputacion,
    COALESCE(u.total_ventas, 0) AS total_ventas_concretadas,
    COALESCE(u.monto_facturado, 0) AS dinero_facturado
FROM usuarios u
LEFT JOIN categorias_usuario cu ON u.id_categoria_usuario = cu.id_categoria_usuario;