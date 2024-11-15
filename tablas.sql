-- Tabla Proveedores
CREATE TABLE Proveedores (
    id_proveedor INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(50),
    correo VARCHAR(50),
    numero VARCHAR(9)
);

-- Tabla Productos
CREATE TABLE Productos (
    id_producto INT PRIMARY KEY,
    id_proveedor INT REFERENCES Proveedores(id_proveedor),
    nombre VARCHAR(50) NOT NULL,
    marca VARCHAR(50),
    descripcion VARCHAR(50),
    cantidad INT,
    precio DOUBLE PRECISION
);

-- Tabla Agua (subclase de Productos)
CREATE TABLE Agua (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    con_gas BOOLEAN
);

-- Tabla Cervezas (subclase de Productos)
CREATE TABLE Cervezas (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    grados_alcohol DOUBLE PRECISION
);

-- Tabla Gaseosas (subclase de Productos)
CREATE TABLE Gaseosas (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    nivel_azucar VARCHAR(10) -- Valores: 'regular', 'light', 'zero'
);

-- Tabla Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY,
    numero VARCHAR(15),
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    direccion VARCHAR(100)
);

-- Tabla Kiosko
CREATE TABLE Kiosko (
    id_kiosko INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    numero VARCHAR(15),
    direccion VARCHAR(100)
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
    total DOUBLE PRECISION,
    fecha DATE NOT NULL,
    estado VARCHAR(50)
);

-- Relación Clientes hace Pedidos
CREATE TABLE Hace (
    id_pedido INT REFERENCES Pedidos(id_pedido),
    id_cliente INT REFERENCES Clientes(id_cliente),
    PRIMARY KEY (id_pedido, id_cliente)
);

-- Tabla Detalles Pedido
CREATE TABLE DetallesPedido (
    id_detalle INT PRIMARY KEY,
    id_pedido INT REFERENCES Pedidos(id_pedido),
    id_producto INT REFERENCES Productos(id_producto),
    cantidad_solicitada INT,
    precio_unitario DOUBLE PRECISION,
    subtotal DOUBLE PRECISION
);

-- Tabla Pagos
CREATE TABLE Pagos (
    id_pago INT PRIMARY KEY,
    id_pedido INT REFERENCES Pedidos(id_pedido),
    monto DOUBLE PRECISION,
    fecha DATE,
    metodo_pago VARCHAR(50),
    estado VARCHAR(50)
);
