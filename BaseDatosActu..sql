use Master
GO
 
CREATE DATABASE MyIphonesv;
GO

USE MyIphonesv;
Go

--tabla usuario (modificada)

CREATE TABLE Usuarios
(
    UsuarioID   INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(100) NOT NULL,
    Correo      VARCHAR(100) UNIQUE NOT NULL,
    Contraseña  NVARCHAR(255) NOT NULL,
    Rol         NVARCHAR(50) CHECK (Rol IN ('Admin', 'VIP', 'Proveedores')) NOT NULL
);
GO

--tabla Cliente

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

--Tabla Productos

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

--tabla pedidos

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

--tabla detalle pedidos

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

--tabla recibos

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

-- TABLA: Proveedores (modificada)

CREATE TABLE Proveedores
(
    ProveedorID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(100) NOT NULL,
    Correo      VARCHAR(100) UNIQUE NOT NULL,
    Telefono    NVARCHAR(20),
    ProductoOfrecido VARCHAR(100) NOT NULL,
	UsuarioID Int null,
	Foreign key (UsuarioID) References Usuarios(UsuarioID)
);
GO

--Tabla facturacion (nuevo)

Create table Facturacion
(
FacturaID int identity(1,1) Primary key,
PedidoID int not null,
Fecha datetime default Getdate(),
MontoTotal Decimal(10,2) not null,
ClienteID int not null,
UsuarioID int null,
FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);
GO

--Tabla Bodega (nuevo)
Create table Bodega
(
TransaccionID int Identity(1,1) Primary key,
ProductoID int not null,
TipoMovimiento nvarchar(50) check (tipomovimiento in ('Entrada', 'Salida')) not null,
Cantidad int not null,
Fecha datetime default getdate(),
ProveedorID int null,
Foreign key (ProductoID) References Productos(ProductoID),
foreign key (ProveedorID) References Proveedores(ProveedorID)
);
GO


--tabla Historial (Prueba)
CREATE TABLE HistorialCambios
(
    CambioID int identity(1,1) Primary Key,
    UsuarioID int not null,
    TablaAfectada nvarchar(100) not null,
    FechaCambio datetime default getdate(),
    DescripcionCambio nvarchar(255),
    Foreign key (UsuarioID) references Usuarios(UsuarioID)
);
Go

--Vistas (nuevas)

Create view Vista_Usuarios As
select Nombre, Descripcion, Precio, Stock, Categoria
From Productos
Where stock > 0;
Go

CREATE VIEW Vista_Empleados AS
SELECT ClienteID, Nombre, Correo, Telefono, Direccion
FROM Clientes;
Go

CREATE VIEW Vista_Admin AS
SELECT 
    p.ProductoID AS Producto_ID,
    p.Nombre AS Producto_Nombre,
    p.Descripcion AS Producto_Descripcion,
    p.Precio AS Producto_Precio,
    p.Stock AS Producto_Stock,
    c.ClienteID AS Cliente_ID,  -- Renombre aquí para evitar un duplicado
    c.Nombre AS Cliente_Nombre,
    c.Correo AS Cliente_Correo,
    ped.PedidoID AS Pedido_ID,
    ped.FechaPedido AS Pedido_Fecha,
    ped.Total AS Pedido_Total,
    ped.Estado AS Pedido_Estado
FROM 
    Productos p
JOIN 
    DetallePedido dp ON p.ProductoID = dp.ProductoID
JOIN 
    Pedidos ped ON dp.PedidoID = ped.PedidoID
JOIN 
    Clientes c ON ped.ClienteID = c.ClienteID;
GO


-- Procedimiento para Reporte dinamico (mas vendido, C.frecuencia, Estado inv.) (nuevo)

Create Procedure ReporteProductosMasVendido
As 
begin
Select top 10 p.Nombre, Sum(dp.Cantidad) As totalVendido
From Productos p
Join DetallePedido dp on p.ProductoID = dp.ProductoID
Group by p.Nombre
Order by TotalVendido Desc;
End;
Go

-- el procedimiento para generar recibo
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
('iPhone 12 Pro Dorado 128GB', '100% bateria', 350.00, 10, 'Smartphone'),
('iPhone 12 Pro Silver 256GB', '100% bateria', 370.00, 8, 'Smartphone'),
('iPhone 13 Pro Azul 128GB', '100% bateria', 500.00, 5, 'Smartphone'),
('iPhone 13 Pro Silver 256GB', '100% bateria', 500.00, 7, 'Smartphone'),
('iPhone 13 Rojo 128GB', '100% bateria', 400.00, 6, 'Smartphone'),
('iPhone 13 Negro 128GB', '100% bateria', 380.00, 4, 'Smartphone'),
('iPhone 13 Pro Max Dorado 128GB', 'Bateria nueva', 600.00, 3, 'Smartphone'),
('iPhone 13 Pro Max Azul 256GB', '100% bateria', 550.00, 2, 'Smartphone'),
('iPhone 14 Negro', '', 500.00, 10, 'Smartphone'),
('iPhone 14 Dorado', '', 500.00, 10, 'Smartphone'),
('iPhone 14 Silver', '', 500.00, 10, 'Smartphone'),
('iPhone 14 Plus Silver', '', 600.00, 5, 'Smartphone'),
('iPhone 14 Plus Azul', '', 600.00, 5, 'Smartphone'),
('iPhone 15 Azul', '', 700.00, 3, 'Smartphone'),
('iPhone 15 Negro', '', 700.00, 3, 'Smartphone'),
('iPhone 15 Plus Blanco Bater?a nueva', '', 6750.00, 3, 'Smartphone');
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
Go

--Diccionario de datos
--Tabla Cliente
--ClienteID: Identificador único del cliente (INT, PK, Autoincremental).
--Nombre: Nombre completo del cliente (NVARCHAR(100), NOT NULL).
--Correo: Correo electrónico único del cliente (NVARCHAR(100), NOT NULL).
--Teléfono: Número de contacto del cliente (NVARCHAR(20)).
--Dirección: Dirección del cliente (NVARCHAR(255)).
--UsuarioID: Relación opcional con la tabla Usuarios para asignar gestor (INT, FK).
--Tabla Usuario
--UsuarioID: Identificador único del usuario (INT, PK, Autoincremental).
--Nombre: Nombre completo del usuario (NVARCHAR(100), NOT NULL).
--Correo: Correo electrónico único del usuario (NVARCHAR(100), NOT NULL).
--Contraseña: Contraseña del usuario (NVARCHAR(255), NOT NULL).
--Rol: Nivel de acceso del usuario (Admin, VIP, GestorProveedores, Empleado, Supervisor) (NVARCHAR(50), NOT NULL).
--Tabla Proveedores
--ProveedorID: Identificador único del proveedor (INT, PK, Autoincremental).
--Nombre: Nombre del proveedor (NVARCHAR(100), NOT NULL).
--Correo: Correo electrónico único del proveedor (NVARCHAR(100), NOT NULL).
--Teléfono: Número de contacto del proveedor (NVARCHAR(20)).
--ProductoOfrecido: Producto que el proveedor ofrece (NVARCHAR(100), NOT NULL).
--UsuarioID: Relación con la tabla Usuarios para definir el gestor del proveedor (INT, FK).
--Tabla Producto
--ProductoID: Identificador único del producto (INT, PK, Autoincremental).
--Nombre: Nombre del producto (NVARCHAR(100), NOT NULL).
--Descripción: Detalle breve del producto (NVARCHAR(255)).
--Precio: Precio unitario del producto (DECIMAL(10,2), NOT NULL).
--Stock: Cantidad en inventario del producto (INT, NOT NULL).
--Categoría: Clasificación del producto (NVARCHAR(50), NOT NULL).
--Tabla Pedido
--PedidoID: Identificador único del pedido (INT, PK, Autoincremental).
--ClienteID: Relación con la tabla Clientes (INT, FK, NOT NULL).
--FechaPedido: Fecha del pedido (DATETIME, DEFAULT GETDATE()).
--Total: Monto total del pedido (DECIMAL(10,2), NOT NULL).
--Estado: Estado del pedido (Pendiente, Enviado, Completado, Cancelado) (NVARCHAR(50), NOT NULL).
--Tabla Detalle del Pedido
--DetalleID: Identificador único del detalle del pedido (INT, PK, Autoincremental).
--PedidoID: Relación con la tabla Pedidos (INT, FK, NOT NULL).
--ProductoID: Relación con la tabla Productos (INT, FK, NOT NULL).
--Cantidad: Unidades compradas del producto (INT, NOT NULL).
--Subtotal: Total parcial del producto en el pedido (DECIMAL(10,2), NOT NULL).
--Tabla Bodega
--TransacciónID: Identificador único de la transacción (INT, PK, Autoincremental).
--ProductoID: Relación con la tabla Productos (INT, FK, NOT NULL).
--TipoMovimiento: Tipo de movimiento (Entrada, Salida) (NVARCHAR(50), NOT NULL).
--Cantidad: Cantidad de productos involucrados (INT, NOT NULL).
--Fecha: Fecha de la transacción (DATETIME, DEFAULT GETDATE()).
--ProveedorID: Relación con la tabla Proveedores (INT, FK).
--Tabla Facturación
--FacturaID: Identificador único de la factura (INT, PK, Autoincremental).
--PedidoID: Relación con la tabla Pedidos (INT, FK, NOT NULL).
--Fecha: Fecha de generación de la factura (DATETIME, DEFAULT GETDATE()).
--MontoTotal: Total de la factura (DECIMAL(10,2), NOT NULL).
--ClienteID: Relación con la tabla Clientes (INT, FK, NOT NULL).
--UsuarioID: Relación opcional con la tabla Usuarios (INT, FK).
--Vistas
--Vista_Usuarios: Presenta los productos disponibles (Nombre, Precio, Stock, Categoría).
--Vista_Empleados: Presenta información básica de clientes (Nombre, Correo, Teléfono, Dirección).
--Vista_Admin: Integra información clave de productos, pedidos y clientes para decisiones avanzadas.