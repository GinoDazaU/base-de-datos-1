CREATE INDEX idx_pedidos_fecha_btree ON Pedidos USING btree (fecha);
CREATE INDEX idx_pedidos_id_pedido_hash ON Pedidos USING hash (id_pedido);
CREATE INDEX idx_clientes_id_cliente_hash ON Clientes USING hash (id_cliente);
CREATE INDEX idx_hace_pedido_hash ON Hace USING hash (id_pedido);
CREATE INDEX idx_hace_cliente_hash ON Hace USING hash (id_cliente);
CREATE INDEX idx_detallespedido_pedido_hash ON DetallesPedido USING hash (id_pedido);
CREATE INDEX idx_detallespedido_producto_hash ON DetallesPedido USING hash (id_producto);
CREATE INDEX idx_detallespedido_cantidad_btree ON DetallesPedido USING btree (cantidad_solicitada);
CREATE INDEX idx_productos_id_producto_hash ON Productos USING hash (id_producto);
CREATE INDEX idx_productos_id_proveedor_hash ON Productos USING hash (id_proveedor);
CREATE INDEX idx_proveedores_id_proveedor_hash ON Proveedores USING hash (id_proveedor);
CREATE INDEX idx_kiosko_id_kiosko_hash ON Kiosko USING hash (id_kiosko);
CREATE INDEX idx_administra_kiosko_hash ON administra USING hash (id_kiosko);
CREATE INDEX idx_administra_cliente_hash ON administra USING hash (id_cliente);
CREATE INDEX idx_pagos_id_pedido_hash ON Pagos USING hash (id_pedido);
CREATE INDEX idx_agua_id_producto_hash ON Agua USING hash (id_producto);
CREATE INDEX idx_gaseosa_id_producto_hash ON Gaseosas USING hash (id_producto);
CREATE INDEX idx_cerveza_id_producto_hash ON Cervezas USING hash (id_producto);