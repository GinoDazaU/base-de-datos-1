-- Tabla Proveedores
CREATE TABLE Proveedores (
    id_proveedor INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(75) NOT NULL,
    correo VARCHAR(50) NOT NULL,
    numero VARCHAR(9) NOT NULL
);

-- Tabla Productos
CREATE TABLE Productos (
    id_producto INT PRIMARY KEY,
    id_proveedor INT NOT NULL REFERENCES Proveedores(id_proveedor),
    nombre VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150) NOT NULL,
    cantidad INT NOT NULL,
    precio NUMERIC(10, 2) NOT NULL
);

-- Tabla Agua (subclase de Productos)
CREATE TABLE Agua (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    con_gas BOOLEAN NOT NULL
);

-- Tabla Cervezas (subclase de Productos)
CREATE TABLE Cervezas (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    grados_alcohol NUMERIC(4, 2) NOT NULL
);

-- Tabla Gaseosas (subclase de Productos)
CREATE TABLE Gaseosas (
    id_producto INT PRIMARY KEY REFERENCES Productos(id_producto),
    nivel_azucar VARCHAR(10) NOT NULL -- Valores: 'regular', 'light', 'zero'
);

-- Tabla Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY,
    numero VARCHAR(9) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    correo VARCHAR(50) NOT NULL,
    direccion VARCHAR(75) NOT NULL
);

-- Tabla Kiosko
CREATE TABLE Kiosko (
    id_kiosko INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    numero VARCHAR(9) NOT NULL,
    direccion VARCHAR(75) NOT NULL
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
    total NUMERIC(10, 2) NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR(15) NOT NULL
);

-- Relación Clientes hace Pedidos
CREATE TABLE Hace (
    id_pedido INT REFERENCES Pedidos(id_pedido),
    id_cliente INT REFERENCES Clientes(id_cliente),
    PRIMARY KEY (id_pedido, id_cliente)
);

-- Tabla Detalles Pedido
CREATE TABLE DetallesPedido (
    id_detalle INT,
    id_pedido INT REFERENCES Pedidos(id_pedido),
    id_producto INT REFERENCES Productos(id_producto),
    cantidad_solicitada INT NOT NULL,
    precio_unitario NUMERIC(10, 2) NOT NULL,
    subtotal NUMERIC(10, 2) GENERATED ALWAYS AS (cantidad_solicitada * precio_unitario) STORED,
    PRIMARY KEY (id_detalle, id_pedido, id_producto)
);


-- Tabla Pagos
CREATE TABLE Pagos (
    id_pago INT PRIMARY KEY,
    id_pedido INT NOT NULL REFERENCES Pedidos(id_pedido),
    monto NUMERIC(10, 2) NOT NULL,
    fecha DATE NOT NULL,
    metodo_pago VARCHAR(15) NOT NULL,
    estado VARCHAR(15) NOT NULL
);
