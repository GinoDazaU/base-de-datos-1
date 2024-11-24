
--1m:12s
-- B-Tree índices para rangos y ordenamiento
CREATE INDEX idx_pedidos_fecha ON Pedidos(fecha);  -- Para rangos de fecha
CREATE INDEX idx_detallespedido_id_pedido ON DetallesPedido(id_pedido);  -- Unión con Pedidos
CREATE INDEX idx_detallespedido_id_producto ON DetallesPedido(id_producto);  -- Filtro por id_producto
CREATE INDEX idx_pagos_id_pedido ON Pagos(id_pedido);  -- Unión con Pedidos
CREATE INDEX idx_productos_id_proveedor ON Productos(id_proveedor);  -- Unión con Proveedores

-- Hash índices para igualdad
CREATE INDEX idx_productos_id_producto_hash ON Productos USING HASH(id_producto);  -- Consultas por igualdad
CREATE INDEX idx_kiosko_id_kiosko_hash ON Kiosko USING HASH(id_kiosko);  -- Consultas por igualdad
