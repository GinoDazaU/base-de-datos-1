-- Restricciones de unicidad
ALTER TABLE Proveedores
ADD CONSTRAINT unique_correo_proveedor UNIQUE (correo),
ADD CONSTRAINT unique_numero_proveedor UNIQUE (numero);

ALTER TABLE Clientes
ADD CONSTRAINT unique_correo_cliente UNIQUE (correo),
ADD CONSTRAINT unique_numero_cliente UNIQUE (numero);

ALTER TABLE Kiosko
ADD CONSTRAINT unique_numero_kiosko UNIQUE (numero);

-- Validar correos
ALTER TABLE Proveedores
ADD CONSTRAINT chk_correo_proveedor CHECK (correo ~* '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$');

ALTER TABLE Clientes
ADD CONSTRAINT chk_correo_cliente CHECK (correo ~* '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$');

-- Validar fechas
ALTER TABLE Pedidos
ADD CONSTRAINT chk_fecha_pedido CHECK (fecha <= CURRENT_DATE);

ALTER TABLE Pagos
ADD CONSTRAINT chk_fecha_pago CHECK (fecha <= CURRENT_DATE);

-- Validar precios y cantidades
ALTER TABLE Productos
ADD CONSTRAINT chk_precio_producto CHECK (precio > 0),
ADD CONSTRAINT chk_cantidad_producto CHECK (cantidad >= 0);

ALTER TABLE DetallesPedido
ADD CONSTRAINT chk_cantidad_detalle CHECK (cantidad_solicitada > 0),
ADD CONSTRAINT chk_precio_unitario_detalle CHECK (precio_unitario > 0);

-- Restricción de métodos de pago
ALTER TABLE Pagos
ADD CONSTRAINT chk_metodo_pago CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia'));

-- Restricción de estados de pedido
ALTER TABLE Pedidos
ADD CONSTRAINT chk_estado_pedido CHECK (estado IN ('procesado', 'enviado', 'entregado'));

-- Restricción de nivel de azúcar en Gaseosas
ALTER TABLE Gaseosas
ADD CONSTRAINT chk_nivel_azucar CHECK (nivel_azucar IN ('regular', 'light', 'zero'));
