-- Falta revisar

-- Restricción para asegurar que el precio de un producto sea mayor a 0
ALTER TABLE Productos
ADD CONSTRAINT chk_precio_producto CHECK (precio > 0);

-- Restricción para validar que la cantidad de un producto no sea negativa
ALTER TABLE Productos
ADD CONSTRAINT chk_cantidad_producto CHECK (cantidad >= 0);

-- Restricción para asegurar que el subtotal en DetallesPedido sea coherente
ALTER TABLE DetallesPedido
ADD CONSTRAINT chk_subtotal_detalle CHECK (subtotal = cantidad_solicitada * precio_unitario);

-- Restricción para validar que el monto de un pago sea mayor a 0
ALTER TABLE Pagos
ADD CONSTRAINT chk_monto_pago CHECK (monto > 0);

-- Restricción para los estados de los pedidos
ALTER TABLE Pedidos
ADD CONSTRAINT chk_estado_pedido CHECK (estado IN ('procesado', 'enviado', 'entregado'));

-- Restricción para los métodos de pago
ALTER TABLE Pagos
ADD CONSTRAINT chk_metodo_pago CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia'));

-- Restricción para el nivel de azúcar en Gaseosas
ALTER TABLE Gaseosas
ADD CONSTRAINT chk_nivel_azucar CHECK (nivel_azucar IN ('regular', 'light', 'zero'));
