-- Tabla Proveedores
CREATE TABLE Proveedores (
    id_proveedor INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    correo VARCHAR(50) NOT NULL,
    numero VARCHAR(9) NOT NULL
);

-- Tabla Productos
CREATE TABLE Productos (
    id_producto INT PRIMARY KEY,
    id_proveedor INT NOT NULL REFERENCES Proveedores(id_proveedor),
    nombre VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    cantidad INT NOT NULL,
    precio DOUBLE PRECISION NOT NULL
);

-- Tabla Agua (subclase de Productos)
CREATE TABLE Agua (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    con_gas BOOLEAN NOT NULL
);

-- Tabla Cervezas (subclase de Productos)
CREATE TABLE Cervezas (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    grados_alcohol DOUBLE PRECISION NOT NULL
);

-- Tabla Gaseosas (subclase de Productos)
CREATE TABLE Gaseosas (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    nivel_azucar VARCHAR(10) NOT NULL -- Valores: 'regular', 'light', 'zero'
);

-- Tabla Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY,
    numero VARCHAR(15) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    direccion VARCHAR(100) NOT NULL
);

-- Tabla Kiosko
CREATE TABLE Kiosko (
    id_kiosko INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    numero VARCHAR(15) NOT NULL,
    direccion VARCHAR(100) NOT NULL
);

-- Relación Clientes administra Kiosko
CREATE TABLE Administra (
    id_kiosko INT REFERENCES Kiosko(id_kiosko),
    id_cliente INT REFERENCES Clientes(id_cliente),
    PRIMARY KEY (id_kiosko, id_cliente)
);

-- Tabla Pedidos
CREATE TABLE Pedidos (
    id_pedido INT PRIMARY KEY,
    total DOUBLE PRECISION NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR(50) NOT NULL
);

-- Relación Clientes hace Pedidos
CREATE TABLE Hace (
    id_pedido INT REFERENCES Pedidos(id_pedido),
    id_cliente INT REFERENCES Clientes(id_cliente),
    PRIMARY KEY (id_pedido, id_cliente)
);

-- Tabla Detalles Pedido
CREATE TABLE DetallesPedido (
    id_pedido INT REFERENCES Pedidos(id_pedido),
    id_producto INT REFERENCES Productos(id_producto),
    cantidad_solicitada INT NOT NULL,
    precio_unitario DOUBLE PRECISION NOT NULL,
    subtotal DOUBLE PRECISION GENERATED ALWAYS AS (cantidad_solicitada * precio_unitario) STORED,
    PRIMARY KEY (id_pedido, id_producto)
);


-- Tabla Pagos
CREATE TABLE Pagos (
    id_pago INT PRIMARY KEY,
    id_pedido INT NOT NULL REFERENCES Pedidos(id_pedido),
    monto DOUBLE PRECISION NOT NULL,
    fecha DATE NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL
);

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

-- Crear la función para actualizar el total de Pedidos
CREATE OR REPLACE FUNCTION actualizar_total_pedido()
RETURNS TRIGGER AS $$
BEGIN
    -- Recalcular el total para el pedido afectado
    UPDATE Pedidos
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM DetallesPedido
        WHERE DetallesPedido.id_pedido = NEW.id_pedido
    )
    WHERE id_pedido = NEW.id_pedido;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para DetallesPedido
CREATE TRIGGER trigger_actualizar_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON DetallesPedido
FOR EACH ROW
EXECUTE FUNCTION actualizar_total_pedido();
