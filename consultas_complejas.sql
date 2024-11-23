-- 1. ¿Qué clientes realizaron pedidos con múltiples productos de diferentes tipos (agua, gaseosa, cerveza) en el último año, y cuáles fueron los detalles de cada pedido (total, pagos realizados, saldo pendiente)?
-- Justificación: Esta consulta permite identificar clientes frecuentes que compran diferentes categorías de productos,
-- lo que ayuda a diseñar estrategias de fidelización. Además, muestra información financiera clave para evaluar la eficiencia de los pagos.

SELECT 
    cli.nombre AS cliente,
    cli.correo AS contacto,
    ped.id_pedido,
    ped.fecha AS fecha_pedido,
    ped.total AS total_pedido,
    SUM(dp.subtotal) AS subtotal_productos,
    SUM(pa.monto) AS total_pagado,
    ped.total - COALESCE(SUM(pa.monto), 0) AS saldo_pendiente,
    STRING_AGG(DISTINCT 
        CASE
            WHEN a.id_producto IS NOT NULL THEN 'Agua'
            WHEN g.id_producto IS NOT NULL THEN 'Gaseosa'
            WHEN c.id_producto IS NOT NULL THEN 'Cerveza'
        END, ', ') AS tipos_producto
FROM Pedidos ped
JOIN Hace h ON ped.id_pedido = h.id_pedido
JOIN Clientes cli ON h.id_cliente = cli.id_cliente
JOIN DetallesPedido dp ON ped.id_pedido = dp.id_pedido
JOIN Productos p ON dp.id_producto = p.id_producto
LEFT JOIN Agua a ON p.id_producto = a.id_producto
LEFT JOIN Gaseosas g ON p.id_producto = g.id_producto
LEFT JOIN Cervezas c ON p.id_producto = c.id_producto
LEFT JOIN Pagos pa ON ped.id_pedido = pa.id_pedido
WHERE ped.fecha >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY cli.nombre, cli.correo, ped.id_pedido, ped.fecha, ped.total
HAVING COUNT(DISTINCT 
    CASE 
        WHEN a.id_producto IS NOT NULL THEN 'Agua'
        WHEN g.id_producto IS NOT NULL THEN 'Gaseosa'
        WHEN c.id_producto IS NOT NULL THEN 'Cerveza'
    END) > 1
ORDER BY ped.fecha DESC;

-- 2. ¿Cuáles son los productos más vendidos, clasificados por sus proveedores y por temporada (verano/invierno), durante los últimos dos años?
-- Justificación: Esta consulta identifica los productos más demandados en diferentes temporadas, desglosados por proveedor,
-- para planificar inventarios y negociar acuerdos estratégicos.

SELECT 
    prov.nombre AS proveedor,
    p.nombre AS producto,
    CASE
        WHEN EXTRACT(MONTH FROM ped.fecha) IN (12, 1, 2) THEN 'Verano'
        WHEN EXTRACT(MONTH FROM ped.fecha) IN (6, 7, 8) THEN 'Invierno'
        ELSE 'Otras'
    END AS temporada,
    COUNT(dp.cantidad_solicitada) AS cantidad_vendida,
    SUM(dp.subtotal) AS total_ventas
FROM DetallesPedido dp
JOIN Productos p ON dp.id_producto = p.id_producto
JOIN Proveedores prov ON p.id_proveedor = prov.id_proveedor
JOIN Pedidos ped ON dp.id_pedido = ped.id_pedido
WHERE ped.fecha >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY prov.nombre, p.nombre, temporada
ORDER BY temporada, total_ventas DESC, cantidad_vendida DESC;

-- 3. ¿Cuál es la rentabilidad total y promedio por mes de cada tipo de producto (agua, gaseosa, cerveza) para cada proveedor en los últimos tres años?
-- Justificación: Esto ayuda a identificar qué proveedores y tipos de productos son más rentables,
-- permitiendo optimizar contratos y estrategias de adquisición.

SELECT 
    prov.nombre AS proveedor,
    CASE
        WHEN a.id_producto IS NOT NULL THEN 'Agua'
        WHEN g.id_producto IS NOT NULL THEN 'Gaseosa'
        WHEN c.id_producto IS NOT NULL THEN 'Cerveza'
    END AS tipo_producto,
    SUM(dp.subtotal) AS rentabilidad_total,
    ROUND(SUM(dp.subtotal) / 36.0, 2) AS promedio_mensual
FROM DetallesPedido dp
JOIN Productos p ON dp.id_producto = p.id_producto
JOIN Proveedores prov ON p.id_proveedor = prov.id_proveedor
LEFT JOIN Agua a ON p.id_producto = a.id_producto
LEFT JOIN Gaseosas g ON p.id_producto = g.id_producto
LEFT JOIN Cervezas c ON p.id_producto = c.id_producto
JOIN Pedidos ped ON dp.id_pedido = ped.id_pedido
WHERE ped.fecha >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY prov.nombre, tipo_producto
ORDER BY rentabilidad_total DESC, proveedor;
