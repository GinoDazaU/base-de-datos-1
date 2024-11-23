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