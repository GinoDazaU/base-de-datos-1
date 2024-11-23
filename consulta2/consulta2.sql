-- Pregunta: ¿Qué tipos de productos han sido los más vendidos en los últimos cinco años, cuáles son sus nombres y marcas, y qué proveedores los distribuyen?
-- Justificación: Esta consulta responde al análisis de desempeño por tipo de producto, considerando nombres, marcas y proveedores. Esto es útil para identificar los productos más populares, analizar las relaciones con los proveedores y planificar estrategias de inventario, promoción y alianzas. También ayuda a detectar patrones de consumo, medir la contribución de cada producto al total de ventas, y evaluar la eficiencia de los proveedores en términos de popularidad y ventas promedio por pedido.

SELECT 
    CASE
        WHEN a.id_producto IS NOT NULL THEN 'Agua'
        WHEN g.id_producto IS NOT NULL THEN 'Gaseosa'
        WHEN c.id_producto IS NOT NULL THEN 'Cerveza'
        ELSE 'Otro'
    END AS tipo_producto,
    p.nombre AS producto,
    p.marca AS marca,
    prov.nombre AS proveedor,
    COUNT(dp.id_producto) AS productos_vendidos,
    SUM(dp.subtotal) AS total_ventas,
    ROUND(SUM(dp.subtotal) / COUNT(DISTINCT ped.id_pedido), 2) AS promedio_venta_por_pedido
FROM DetallesPedido dp
JOIN Productos p ON dp.id_producto = p.id_producto
JOIN Proveedores prov ON p.id_proveedor = prov.id_proveedor
JOIN Pedidos ped ON dp.id_pedido = ped.id_pedido
LEFT JOIN Agua a ON p.id_producto = a.id_producto
LEFT JOIN Gaseosas g ON p.id_producto = g.id_producto
LEFT JOIN Cervezas c ON p.id_producto = c.id_producto
WHERE ped.fecha >= CURRENT_DATE - INTERVAL '5 years'
GROUP BY tipo_producto, p.nombre, p.marca, prov.nombre
ORDER BY total_ventas DESC, productos_vendidos DESC;
