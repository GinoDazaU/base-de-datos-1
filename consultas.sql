-- ***********************************************
-- CONSULTAS PRINCIPALES PARA EL PROYECTO
-- ***********************************************

-- Consulta 1: Estado actual de los pedidos y pagos realizados por los clientes
SELECT p.id_pedido, p.estado AS estado_pedido, pa.estado AS estado_pago
FROM Pedidos p
LEFT JOIN Pagos pa ON p.id_pedido = pa.id_pedido;

-- Consulta 2: Productos disponibles en inventario y en qué cantidad
SELECT nombre, cantidad
FROM Productos
WHERE cantidad > 0;

-- Consulta 3: Detalles de un pedido específico
SELECT dp.id_pedido, dp.id_producto, dp.cantidad_solicitada, dp.subtotal
FROM DetallesPedido dp
WHERE dp.id_pedido = <ID_PEDIDO>;

-- Consulta 4: Productos más vendidos en un determinado periodo de tiempo
SELECT dp.id_producto, SUM(dp.cantidad_solicitada) AS total_vendido
FROM DetallesPedido dp
JOIN Pedidos p ON dp.id_pedido = p.id_pedido
WHERE p.fecha BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY dp.id_producto
ORDER BY total_vendido DESC;

-- Consulta 5: Cliente que ha realizado más pedidos en el último trimestre
SELECT h.id_cliente, COUNT(*) AS total_pedidos
FROM Hace h
JOIN Pedidos p ON h.id_pedido = p.id_pedido
WHERE p.fecha >= NOW() - INTERVAL '3 months'
GROUP BY h.id_cliente
ORDER BY total_pedidos DESC
LIMIT 1;

-- Consulta 6: Kioskos asociados a un cliente específico y su ubicación
SELECT k.nombre, k.direccion
FROM Administra a
JOIN Kiosko k ON a.id_kiosko = k.id_kiosko
WHERE a.id_cliente = <ID_CLIENTE>;

-- Consulta 7: Monto total de ventas por proveedor en el último año
SELECT p.id_proveedor, SUM(dp.subtotal) AS total_ventas
FROM Productos p
JOIN DetallesPedido dp ON p.id_producto = dp.id_producto
JOIN Pedidos ped ON dp.id_pedido = ped.id_pedido
WHERE ped.fecha >= NOW() - INTERVAL '1 year'
GROUP BY p.id_proveedor;

-- Consulta 8: Pedidos con monto mayor a 1000 soles y los clientes que los realizaron
SELECT p.id_pedido, h.id_cliente, p.total
FROM Pedidos p
JOIN Hace h ON p.id_pedido = h.id_pedido
WHERE p.total > 1000;




-- ***********************************************
-- CONSULTAS BÁSICAS
-- ***********************************************

-- 1. Listar todos los productos
SELECT * FROM Productos;

-- 2. Listar todos los pedidos con sus totales
SELECT * FROM Pedidos;

-- 3. Listar todos los clientes
SELECT * FROM Clientes;

-- 4. Listar todos los proveedores
SELECT * FROM Proveedores;

-- ***********************************************
-- CONSULTAS CON RELACIONES
-- ***********************************************

-- 5. Ver los productos de un proveedor específico
SELECT p.id_producto, p.nombre, p.marca, p.precio, pr.nombre AS proveedor
FROM Productos p
JOIN Proveedores pr ON p.id_proveedor = pr.id_proveedor
WHERE pr.id_proveedor = 1; -- Cambiar el ID del proveedor

-- 6. Ver los productos en un pedido específico
SELECT dp.id_producto, p.nombre AS producto, dp.cantidad_solicitada, dp.precio_unitario, dp.cantidad_solicitada * dp.precio_unitario AS subtotal
FROM DetallesPedido dp
JOIN Productos p ON dp.id_producto = p.id_producto
WHERE dp.id_pedido = 1; -- Cambiar el ID del pedido

-- 7. Ver los pedidos hechos por un cliente específico
SELECT ped.id_pedido, ped.fecha, ped.total, ped.estado
FROM Pedidos ped
JOIN Hace h ON ped.id_pedido = h.id_pedido
JOIN Clientes c ON h.id_cliente = c.id_cliente
WHERE c.id_cliente = 1; -- Cambiar el ID del cliente

-- 8. Ver los clientes que administran kioskos
SELECT c.id_cliente, c.nombre AS cliente, k.nombre AS kiosko
FROM Administra a
JOIN Clientes c ON a.id_cliente = c.id_cliente
JOIN Kiosko k ON a.id_kiosko = k.id_kiosko;

-- ***********************************************
-- CONSULTAS DE ANÁLISIS
-- ***********************************************

-- 9. Ver los productos más vendidos (en cantidad)
SELECT p.nombre, SUM(dp.cantidad_solicitada) AS total_vendido
FROM DetallesPedido dp
JOIN Productos p ON dp.id_producto = p.id_producto
GROUP BY p.nombre
ORDER BY total_vendido DESC;

-- 10. Ver el total de ingresos generados por pedidos
SELECT SUM(total) AS ingresos_totales
FROM Pedidos;

-- 11. Ver el total vendido por cada proveedor
SELECT pr.nombre AS proveedor, SUM(dp.cantidad_solicitada * dp.precio_unitario) AS total_vendido
FROM DetallesPedido dp
JOIN Productos p ON dp.id_producto = p.id_producto
JOIN Proveedores pr ON p.id_proveedor = pr.id_proveedor
GROUP BY pr.nombre
ORDER BY total_vendido DESC;

-- 12. Ver los pedidos por estado
SELECT estado, COUNT(*) AS total_pedidos
FROM Pedidos
GROUP BY estado;

-- 13. Ver los clientes que más han comprado
SELECT c.nombre, SUM(ped.total) AS total_comprado
FROM Hace h
JOIN Clientes c ON h.id_cliente = c.id_cliente
JOIN Pedidos ped ON h.id_pedido = ped.id_pedido
GROUP BY c.nombre
ORDER BY total_comprado DESC;

-- ***********************************************
-- CONSULTAS DE CONTROL Y VALIDACIÓN
-- ***********************************************

-- 14. Ver detalles de un pedido junto con el cliente
SELECT ped.id_pedido, ped.fecha, ped.total, c.nombre AS cliente
FROM Pedidos ped
JOIN Hace h ON ped.id_pedido = h.id_pedido
JOIN Clientes c ON h.id_cliente = c.id_cliente
WHERE ped.id_pedido = 1; -- Cambiar el ID del pedido

-- 15. Ver los productos que tienen bajo stock
SELECT nombre, cantidad
FROM Productos
WHERE cantidad < 10
ORDER BY cantidad ASC;

-- 16. Ver los pagos asociados a un pedido
SELECT p.id_pago, p.monto, p.fecha, p.metodo_pago, p.estado
FROM Pagos p
WHERE p.id_pedido = 1; -- Cambiar el ID del pedido

-- ***********************************************
-- CONSULTAS AVANZADAS
-- ***********************************************

-- 17. Ver los ingresos mensuales
SELECT DATE_TRUNC('month', fecha) AS mes, SUM(total) AS ingresos_mensuales
FROM Pedidos
GROUP BY mes
ORDER BY mes;

-- 18. Ver los productos más rentables
SELECT p.nombre, SUM(dp.cantidad_solicitada * dp.precio_unitario) AS ingresos_totales
FROM DetallesPedido dp
JOIN Productos p ON dp.id_producto = p.id_producto
GROUP BY p.nombre
ORDER BY ingresos_totales DESC;

-- 19. Ver los pedidos con más productos
SELECT dp.id_pedido, COUNT(dp.id_producto) AS total_productos
FROM DetallesPedido dp
GROUP BY dp.id_pedido
ORDER BY total_productos DESC;
