CREATE DATABASE MyIphonesv;
GO

USE MyIphonesv;
GO

CREATE TABLE Usuarios
(
    UsuarioID   INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(100) NOT NULL,
    Correo      VARCHAR(100) UNIQUE NOT NULL,
    Contraseña  NVARCHAR(255) NOT NULL,
    Rol         NVARCHAR(50) CHECK (Rol IN ('Admin', 'VIP')) NOT NULL
);
GO

CREATE TABLE Clientes
(
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre       VARCHAR(100) NOT NULL,
    Correo       VARCHAR(100) UNIQUE NOT NULL,
    Telefono     NVARCHAR(20),
    Direccion    NVARCHAR(255),
    UsuarioID    INT NULL,
    Rol          NVARCHAR(50) CHECK (Rol IN ('Frecuente','Nuevo')) NOT NULL DEFAULT 'Nuevo',
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);
GO

CREATE TABLE Productos
(
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(300),
    Precio      DECIMAL(10,2) NOT NULL,
    Stock       INT NOT NULL,
    Categoria   NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE Pedidos
(
    PedidoID   INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID  INT NOT NULL,
    FechaPedido DATETIME DEFAULT GETDATE(),
    Total      DECIMAL(10,2) NOT NULL,
    Estado     NVARCHAR(50) CHECK (Estado IN ('Pendiente', 'Enviado', 'Completado', 'Cancelado')) NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);
GO

CREATE TABLE DetallePedido
(
    DetalleID   INT IDENTITY(1,1) PRIMARY KEY,
    PedidoID    INT NOT NULL,
    ProductoID  INT NOT NULL,
    Cantidad    INT NOT NULL,
    Subtotal    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (PedidoID)   REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);
GO


CREATE TABLE Recibos
(
    ReciboID    INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID   INT NOT NULL,
    PedidoID    INT NOT NULL,
    NombreCliente VARCHAR(100) NOT NULL,
    CorreoCliente VARCHAR(100) NOT NULL,
    TelefonoCliente NVARCHAR(20),
    FechaPedido DATETIME NOT NULL,
    TotalPedido DECIMAL(10,2) NOT NULL,
    EstadoPedido NVARCHAR(50) NOT NULL,
    DetallesPedido NVARCHAR(MAX) NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID)
);
GO

-- TABLA: Proveedores
CREATE TABLE Proveedores
(
    ProveedorID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(100) NOT NULL,
    Correo      VARCHAR(100) UNIQUE NOT NULL,
    Telefono    NVARCHAR(20),
    ProductoOfrecido VARCHAR(100) NOT NULL
);
GO

-- el procedimiento almacenado para generar recibo
CREATE PROCEDURE GenerarRecibo
    @ClienteID INT,
    @PedidoID INT
AS
BEGIN
    DECLARE @NombreCliente VARCHAR(100),
            @CorreoCliente VARCHAR(100),
            @TelefonoCliente NVARCHAR(20),
            @FechaPedido DATETIME,
            @TotalPedido DECIMAL(10,2),
            @EstadoPedido NVARCHAR(50),
            @DetallesPedido NVARCHAR(MAX);

    -- Obtener informacion del cliente
    SELECT @NombreCliente = Nombre,
           @CorreoCliente = Correo,
           @TelefonoCliente = Telefono
    FROM Clientes
    WHERE ClienteID = @ClienteID;

    -- Obtener informacion del pedido
    SELECT @FechaPedido = FechaPedido,
           @TotalPedido = Total,
           @EstadoPedido = Estado
    FROM Pedidos
    WHERE PedidoID = @PedidoID;


    SELECT @DetallesPedido = STRING_AGG(CONCAT('ProductoID: ', ProductoID, ', Cantidad: ', Cantidad, ', Subtotal: ', Subtotal), '; ')
    FROM DetallePedido
    WHERE PedidoID = @PedidoID;


    INSERT INTO Recibos (ClienteID, PedidoID, NombreCliente, CorreoCliente, TelefonoCliente, FechaPedido, TotalPedido, EstadoPedido, DetallesPedido)
    VALUES (@ClienteID, @PedidoID, @NombreCliente, @CorreoCliente, @TelefonoCliente, @FechaPedido, @TotalPedido, @EstadoPedido, @DetallesPedido);
END;
GO


INSERT INTO Usuarios (Nombre, Correo, Contraseña, Rol) VALUES
('Gerson', 'gerson@example.com', 'password123', 'VIP'),
('Ped1', 'ped1@gmail.com', 'password123', 'Admin'),
('Ped2', 'ped2@gmail.com', 'password123', 'Admin');
GO

-- Insertar datos en la tabla Clientes
INSERT INTO Clientes (Nombre, Correo, Telefono, Direccion, UsuarioID, Rol) VALUES
('Cliente1', 'cliente1@example.com', '1234567890', 'Direccion1', NULL, 'Nuevo'),
('Cliente2', 'cliente2@example.com', '0987654321', 'Direccion2', NULL, 'Nuevo'),
('Cliente3', 'cliente3@example.com', '1122334455', 'Direccion3', NULL, 'Nuevo');
GO


INSERT INTO Productos (Nombre, Descripcion, Precio, Stock, Categoria) VALUES
('iPhone 12 Pro Dorado 128GB', '100% batería', 350.00, 10, 'Smartphone'),
('iPhone 12 Pro Silver 256GB', '100% batería', 370.00, 8, 'Smartphone'),
('iPhone 13 Pro Azul 128GB', '100% batería', 500.00, 5, 'Smartphone'),
('iPhone 13 Pro Silver 256GB', '100% batería', 500.00, 7, 'Smartphone'),
('iPhone 13 Rojo 128GB', '100% batería', 400.00, 6, 'Smartphone'),
('iPhone 13 Negro 128GB', '100% batería', 380.00, 4, 'Smartphone'),
('iPhone 13 Pro Max Dorado 128GB', 'Batería nueva', 600.00, 3, 'Smartphone'),
('iPhone 13 Pro Max Azul 256GB', '100% batería', 550.00, 2, 'Smartphone'),
('iPhone 14 Negro', '', 500.00, 10, 'Smartphone'),
('iPhone 14 Dorado', '', 500.00, 10, 'Smartphone'),
('iPhone 14 Silver', '', 500.00, 10, 'Smartphone'),
('iPhone 14 Plus Silver', '', 600.00, 5, 'Smartphone'),
('iPhone 14 Plus Azul', '', 600.00, 5, 'Smartphone'),
('iPhone 15 Azul', '', 700.00, 3, 'Smartphone'),
('iPhone 15 Negro', '', 700.00, 3, 'Smartphone'),
('iPhone 15 Plus Blanco Batería nueva', '', 6750.00, 3, 'Smartphone');
GO


INSERT INTO Pedidos (ClienteID, Total, Estado) VALUES
(1, 350.00, 'Pendiente'), -- Pedido de Cliente1
(2, 370.00, 'Enviado'), -- Pedido de Cliente2
(3, 500.00, 'Completado'); -- Pedido de Cliente3
GO

INSERT INTO DetallePedido (PedidoID, ProductoID, Cantidad, Subtotal) VALUES
(1, 1, 1, 350.00), -- Detalle del pedido de Cliente1
(2, 2, 1, 370.00), -- Detalle del pedido de Cliente2
(3, 3, 1, 500.00); -- Detalle del pedido de Cliente3
GO


INSERT INTO Proveedores (Nombre, Correo, Telefono, ProductoOfrecido) VALUES
('Proveedor1', 'proveedor1@gmail.com', '1234567890', 'iPhone 12 Pro'),
('Proveedor2', 'proveedor2@gmail.com', '0987654321', 'iPhone 13 Pro'),
('Proveedor3', 'proveedor3@gmail.com', '1122334455', 'iPhone 14 Plus');
GO

EXEC GenerarRecibo @ClienteID = 1, @PedidoID = 1;  -- esta linea es la que genera el recibo en base al cliente con su debido pedido

SELECT * FROM Recibos WHERE ClienteID = 1 AND PedidoID = 1; -- este es para ver el recivo generado