
CREATE INDEX idx_pedidos_fecha ON Pedidos(fecha);
CREATE INDEX idx_detallespedido_id_pedido ON DetallesPedido(id_pedido);
CREATE INDEX idx_detallespedido_id_producto ON DetallesPedido(id_producto);
CREATE INDEX idx_productos_id_proveedor ON Productos(id_proveedor);
