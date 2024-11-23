-- 1. ¿Qué clientes han realizado pedidos en los últimos tres años, y cuáles son los detalles relacionados con kioskos, proveedores, productos, y pagos asociados?
-- Justificación: Esta consulta permite identificar el comportamiento de los clientes más activos en los últimos tres años, lo cual proporciona una visión completa de las interacciones entre clientes,
-- los kioskos que administran, los productos que adquieren, y los pagos realizados. Esta información es clave para diseñar estrategias de fidelización basadas en patrones de consumo e
-- identificar productos de mayor demanda y posibles oportunidades de optimización financiera.

SELECT 
    cli.nombre AS cliente,
    cli.correo AS contacto,
    kio.nombre AS kiosko,
    prov.nombre AS proveedor,
    p.nombre AS producto,
    SUM(dp.cantidad_solicitada) AS cantidad_total,
    SUM(dp.subtotal) AS total_gastado,
    pa.monto AS ultimo_pago,
    EXTRACT(YEAR FROM ped.fecha) AS anio_pedido
FROM Pedidos ped
JOIN Hace h ON ped.id_pedido = h.id_pedido
JOIN Clientes cli ON h.id_cliente = cli.id_cliente
JOIN DetallesPedido dp ON ped.id_pedido = dp.id_pedido
JOIN Productos p ON dp.id_producto = p.id_producto
JOIN Proveedores prov ON p.id_proveedor = prov.id_proveedor
JOIN Kiosko kio ON EXISTS (
    SELECT 1 
    FROM administra a
    WHERE a.id_kiosko = kio.id_kiosko 
      AND a.id_cliente = cli.id_cliente
)
LEFT JOIN Agua a ON p.id_producto = a.id_producto
LEFT JOIN Gaseosas g ON p.id_producto = g.id_producto
LEFT JOIN Cervezas c ON p.id_producto = c.id_producto
LEFT JOIN Pagos pa ON ped.id_pedido = pa.id_pedido
WHERE ped.fecha >= CURRENT_DATE - INTERVAL '3 years'
  AND EXISTS (
      SELECT 1 
      FROM DetallesPedido dp_sub 
      WHERE dp_sub.id_pedido = ped.id_pedido 
        AND dp_sub.cantidad_solicitada > 5
  )
GROUP BY cli.nombre, cli.correo, kio.nombre, prov.nombre, p.nombre, pa.monto, anio_pedido
HAVING SUM(dp.cantidad_solicitada) > 10
ORDER BY total_gastado DESC, anio_pedido;

-- 2. ¿Cuál es la rentabilidad total y promedio por mes de cada tipo de producto (agua, gaseosa, cerveza) para cada proveedor en los últimos tres años?
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

-- 3. ¿Cuáles son los productos más vendidos, clasificados por sus proveedores y por temporada (verano/invierno), durante los últimos dos años?
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
