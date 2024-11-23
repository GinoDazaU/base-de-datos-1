
-- Vistas basicas para el supuesto usuario de nuestro proyecto

-- ============================
-- Vista: InventarioActual
-- ============================
-- Propósito:
-- Proporciona una vista del inventario actual mostrando productos,
-- sus cantidades disponibles y precios unitarios.
CREATE OR REPLACE VIEW InventarioActual AS
SELECT 
    p.id_producto,
    p.nombre AS producto,
    p.marca,
    p.descripcion,
    p.cantidad AS stock_disponible,
    p.precio AS precio_unitario
FROM Productos p
ORDER BY p.cantidad DESC;

-- ============================
-- Vista: PedidosPendientes
-- ============================
-- Propósito:
-- Lista los pedidos que no han sido entregados, con información
-- del cliente y el estado actual del pedido.
CREATE OR REPLACE VIEW PedidosPendientes AS
SELECT 
    ped.id_pedido,
    cli.nombre AS cliente,
    cli.direccion,
    ped.fecha,
    ped.total,
    ped.estado
FROM Pedidos ped
JOIN Hace h ON ped.id_pedido = h.id_pedido
JOIN Clientes cli ON h.id_cliente = cli.id_cliente
WHERE ped.estado != 'entregado'
ORDER BY ped.fecha ASC;

-- ============================
-- Vista: VentasPorTipoProducto
-- ============================
-- Propósito:
-- Muestra las ventas totales y el número de pedidos asociados
-- por tipo de producto (agua, cerveza, gaseosa).
CREATE OR REPLACE VIEW VentasPorTipoProducto AS
SELECT 
    CASE
        WHEN a.id_producto IS NOT NULL THEN 'Agua'
        WHEN c.id_producto IS NOT NULL THEN 'Cerveza'
        WHEN g.id_producto IS NOT NULL THEN 'Gaseosa'
        ELSE 'Otros'
    END AS tipo_producto,
    SUM(dp.subtotal) AS ventas_totales,
    COUNT(DISTINCT dp.id_pedido) AS pedidos_asociados
FROM DetallesPedido dp
JOIN Productos p ON dp.id_producto = p.id_producto
LEFT JOIN Agua a ON p.id_producto = a.id_producto
LEFT JOIN Cervezas c ON p.id_producto = c.id_producto
LEFT JOIN Gaseosas g ON p.id_producto = g.id_producto
GROUP BY tipo_producto
ORDER BY ventas_totales DESC;

-- ============================
-- Vista: PagosPendientes
-- ============================
-- Propósito:
-- Identifica los pagos que están pendientes, mostrando el cliente,
-- monto del pago, fecha y método utilizado.
CREATE OR REPLACE VIEW PagosPendientes AS
SELECT 
    pa.id_pago,
    ped.id_pedido,
    cli.nombre AS cliente,
    pa.monto,
    pa.fecha,
    pa.metodo_pago,
    pa.estado
FROM Pagos pa
JOIN Pedidos ped ON pa.id_pedido = ped.id_pedido
JOIN Hace h ON ped.id_pedido = h.id_pedido
JOIN Clientes cli ON h.id_cliente = cli.id_cliente
WHERE pa.estado = 'pendiente'
ORDER BY pa.fecha ASC;

-- ============================
-- Vista: ProveedoresTop
-- ============================
-- Propósito:
-- Lista a los proveedores con el número de productos registrados
-- que han proporcionado, ordenados por relevancia.
CREATE OR REPLACE VIEW ProveedoresTop AS
SELECT 
    prov.nombre AS proveedor,
    COUNT(p.id_producto) AS total_productos
FROM Proveedores prov
JOIN Productos p ON prov.id_proveedor = p.id_proveedor
GROUP BY prov.nombre
ORDER BY total_productos DESC;
