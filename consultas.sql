VACUUM ANALYZE Proveedores;
VACUUM ANALYZE Productos;
VACUUM ANALYZE Agua;
VACUUM ANALYZE Cervezas;
VACUUM ANALYZE Gaseosas;
VACUUM ANALYZE Clientes;
VACUUM ANALYZE Kiosko;
VACUUM ANALYZE Administra;
VACUUM ANALYZE Pedidos;
VACUUM ANALYZE Hace;
VACUUM ANALYZE DetallesPedido;
VACUUM ANALYZE Pagos;

-- Consulta 1: Eficiencia de los proveedores
-- Pregunta:
-- ¿Cuáles son los proveedores que abastecieron más productos en los últimos 6 meses y cuál fue su participación en las ventas de la distribuidora?
-- Justificación:
-- Identificar a los proveedores más eficientes permite evaluar si sus productos contribuyen significativamente a las ventas de la distribuidora, ayudando a tomar decisiones sobre futuras negociaciones.

SELECT 
    pr.nombre AS proveedor,
    COUNT(p.id_producto) AS productos_abastecidos,
    SUM(dp.subtotal) AS total_ventas_proveedor,
    ROUND((SUM(dp.subtotal) * 100.0) / (SELECT SUM(dp2.subtotal) 
        FROM DetallesPedido dp2 
        JOIN Pedidos p2 ON dp2.id_pedido = p2.id_pedido 
        WHERE p2.fecha >= CURRENT_DATE - INTERVAL '6 months'), 2) AS participacion_ventas
FROM 
    Productos p
    JOIN Proveedores pr ON p.id_proveedor = pr.id_proveedor
    JOIN DetallesPedido dp ON p.id_producto = dp.id_producto
    JOIN Pedidos ped ON dp.id_pedido = ped.id_pedido
WHERE 
    ped.fecha >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY 
    pr.id_proveedor
ORDER BY 
    total_ventas_proveedor DESC;

-- Consulta 2: Rendimiento de los tipos de productos
-- Pregunta:
-- ¿Cuál es el rendimiento por tipo de producto (agua, gaseosa, cerveza) en los últimos dos años, en términos de ventas totales y promedio mensual?
-- Justificación:
-- La empresa necesita entender qué tipo de productos tienen un mejor desempeño en ventas para ajustar estrategias de inventario y distribución.

SELECT 
    tipo_producto,
    SUM(dp.subtotal) AS ventas_totales,
    ROUND(SUM(dp.subtotal) / (24.0), 2) AS promedio_mensual
FROM (
    SELECT 
        dp.subtotal,
        CASE
            WHEN a.id_producto IS NOT NULL THEN 'Agua'
            WHEN g.id_producto IS NOT NULL THEN 'Gaseosa'
            WHEN c.id_producto IS NOT NULL THEN 'Cerveza'
            ELSE 'Otros'
        END AS tipo_producto
    FROM 
        DetallesPedido dp
        JOIN Productos p ON dp.id_producto = p.id_producto
        LEFT JOIN Agua a ON p.id_producto = a.id_producto
        LEFT JOIN Cervezas c ON p.id_producto = c.id_producto
        LEFT JOIN Gaseosas g ON p.id_producto = g.id_producto
        JOIN Pedidos ped ON dp.id_pedido = ped.id_pedido
    WHERE 
        ped.fecha >= CURRENT_DATE - INTERVAL '2 years'
) AS ventas_por_tipo
GROUP BY 
    tipo_producto
ORDER BY 
    ventas_totales DESC;

-- Consulta 3: Tendencias de ventas estacionales
-- Pregunta:
-- ¿Cuáles son los productos más vendidos en las temporadas de verano e invierno de los últimos dos años?
-- Justificación:
-- Ayuda a identificar productos con mayor demanda en períodos específicos del año, facilitando la planificación de inventarios y campañas estacionales.

SELECT 
    p.nombre AS producto,
    p.marca,
    CASE
        WHEN EXTRACT(MONTH FROM ped.fecha) IN (12, 1, 2) THEN 'Verano'
        WHEN EXTRACT(MONTH FROM ped.fecha) IN (6, 7, 8) THEN 'Invierno'
    END AS temporada,
    SUM(dp.cantidad_solicitada) AS cantidad_vendida
FROM 
    DetallesPedido dp
    JOIN Productos p ON dp.id_producto = p.id_producto
    JOIN Pedidos ped ON dp.id_pedido = ped.id_pedido
WHERE 
    ped.fecha >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 
    p.id_producto, temporada
ORDER BY 
    temporada, cantidad_vendida DESC;
