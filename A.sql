-- Base de Datos para "El Negrito" (Hamburguesería)

CREATE DATABASE IF NOT EXISTS ElNegrito;
USE ElNegrito;

-- Tabla de Clientes
CREATE TABLE IF NOT EXISTS Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE,
    direccion TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar clientes
INSERT INTO Clientes (nombre, telefono, email, direccion) VALUES
('Juan Pérez', '5551234567', 'juanperez@gmail.com', 'Calle Falsa 123'),
('María López', '5559876543', 'marialopez@gmail.com', 'Av. Reforma 456'),
('Carlos Gómez', '5554567890', 'carlosgomez@gmail.com', 'Blvd. Principal 789'),
('Ana Torres', '5557890123', 'anatorres@gmail.com', 'Calle del Sol 321'),
('Luis Ramírez', '5553210987', 'luisramirez@gmail.com', 'Colonia Centro 654'),
('Gabriela Sánchez', '5556543210', 'gabrielasanchez@gmail.com', 'Zona Norte 987'),
('Pedro Fernández', '5551472583', 'pedrofernandez@gmail.com', 'Calle de los Olivos 258'),
('Laura Martínez', '5553698521', 'lauramartinez@gmail.com', 'Avenida Insurgentes 147'),
('Miguel Castro', '5558529631', 'miguelcastro@gmail.com', 'Callejón Pequeño 369'),
('Sofía Herrera', '5559637412', 'sofiaherrera@gmail.com', 'Fraccionamiento El Bosque 852');

-- Tabla de Empleados
CREATE TABLE IF NOT EXISTS Empleados (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    puesto ENUM('Cajero', 'Cocinero', 'Repartidor', 'Gerente') NOT NULL,
    telefono VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE,
    fecha_contratacion DATE NOT NULL
);

-- Insertar empleados
INSERT INTO Empleados (nombre, puesto, telefono, email, fecha_contratacion) VALUES
('Diego Moreno', 'Cajero', '5551112233', 'diego.moreno@gmail.com', '2023-05-01'),
('Elena Rojas', 'Cocinero', '5552223344', 'elena.rojas@gmail.com', '2023-06-15'),
('Ricardo Díaz', 'Repartidor', '5553334455', 'ricardo.diaz@gmail.com', '2023-07-20'),
('Carmen Silva', 'Gerente', '5554445566', 'carmen.silva@gmail.com', '2023-04-10'),
('Sergio Álvarez', 'Cajero', '5555556677', 'sergio.alvarez@gmail.com', '2023-08-01'),
('Paola Núñez', 'Cocinero', '5556667788', 'paola.nunez@gmail.com', '2023-09-05'),
('Jorge Martínez', 'Repartidor', '5557778899', 'jorge.martinez@gmail.com', '2023-10-12'),
('Andrea Vargas', 'Cocinero', '5558889900', 'andrea.vargas@gmail.com', '2023-11-22'),
('Rodrigo Gutiérrez', 'Cajero', '5559990011', 'rodrigo.gutierrez@gmail.com', '2023-12-30'),
('Lucía Herrera', 'Repartidor', '5550001122', 'lucia.herrera@gmail.com', '2024-01-10');

-- Tabla de Proveedores
CREATE TABLE Proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE,
    direccion TEXT
);
-- Insertar proveedores
INSERT INTO Proveedores (nombre, telefono, email, direccion) VALUES
('Proveedor Carnes Premium', '5554321001', 'contacto@carnespremium.com', 'Av. Industrial 55'),
('Proveedor Lácteos Selectos', '5554321002', 'ventas@lacteosselectos.com', 'Blvd. Comercial 78'),
('Panadería Artesanal', '5554321003', 'info@panartesanal.com', 'Calle Panaderos 99'),
('Bebidas Naturales MX', '5554321004', 'contacto@bebidasmx.com', 'Zona Centro 45'),
('Distribuidora de Quesos', '5554321005', 'ventas@quesosdistrib.com', 'Colonia Gourmet 32'),
('Carnicería Especial', '5554321006', 'contacto@carniceriaespecial.com', 'Mercado Central 10'),
('Refrescos y Jugos', '5554321007', 'info@refrescosjugos.com', 'Av. Principal 111'),
('Proveedor de Especias', '5554321008', 'contacto@especiasmx.com', 'Colonia Sabores 76'),
('Verduras y Hortalizas', '5554321009', 'ventas@verduras.com', 'Zona Agrícola 20'),
('Embutidos del Sur', '5554321010', 'info@embutidosdelsur.com', 'Blvd. Embutidos 14');

-- Tabla de Productos (Ingredientes, Hamburguesas, Bebidas, Snacks y Extras)
CREATE TABLE IF NOT EXISTS Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('Ingrediente', 'Hamburguesa', 'Bebida', 'Snack', 'Extra', 'Taco') NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    id_proveedor INT,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
);

-- Tabla de Pedidos
CREATE TABLE IF NOT EXISTS Pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('Pendiente', 'En Preparación', 'En Camino', 'Entregado', 'Cancelado') DEFAULT 'Pendiente',
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- Insertar pedidos
INSERT INTO Pedidos (id_cliente, total, estado) VALUES
(1, 95.00, 'Pendiente'), (2, 125.00, 'En Preparación'), (3, 20.00, 'Entregado'),
(4, 110.00, 'Pendiente'), (5, 250.00, 'En Camino'), (6, 135.00, 'Entregado'),
(7, 120.00, 'Cancelado'), (8, 250.00, 'Pendiente'), (9, 65.00, 'Pendiente'),
(10, 22.00, 'Pendiente');

-- Tabla de Detalle de Pedidos
CREATE TABLE IF NOT EXISTS Detalle_Pedidos (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

-- Insertar detalles de pedidos
INSERT INTO Detalle_Pedidos (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 11, 1, 95.00), (2, 12, 1, 125.00), (3, 3, 1, 20.00),
(4, 13, 1, 110.00), (5, 14, 1, 250.00), (6, 15, 1, 135.00),
(7, 16, 1, 120.00), (8, 17, 1, 250.00), (9, 18, 1, 65.00),
(10, 19, 1, 22.00);


-- Tabla de Inventario
CREATE TABLE IF NOT EXISTS Inventario (
    id_inventario INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    cantidad INT NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

-- Insertar inventario
INSERT INTO Inventario (id_producto, cantidad) VALUES
(1, 50), (2, 50), (3, 50), (4, 50), (5, 50), (6, 50), (7, 50), (8, 30), (9, 30), (10, 30);



-- Tabla de Métodos de Pago
CREATE TABLE IF NOT EXISTS Metodos_Pago (
    id_metodo INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('Efectivo', 'Tarjeta de Crédito', 'Tarjeta de Débito', 'Transferencia', 'PayPal') NOT NULL
);

-- Tabla de Pagos
CREATE TABLE IF NOT EXISTS Pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_metodo INT,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_metodo) REFERENCES Metodos_Pago(id_metodo)
);

-- Insertar pagos
INSERT INTO Pagos (id_pedido, id_metodo, monto) VALUES
(1, 1, 95.00), (2, 2, 125.00), (3, 3, 20.00), (4, 1, 110.00),
(5, 4, 250.00), (6, 2, 135.00), (7, 5, 120.00), (8, 3, 250.00),
(9, 4, 65.00), (10, 1, 22.00);

-- Tabla de Promociones
CREATE TABLE IF NOT EXISTS Promociones (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    descripcion TEXT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    dia ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo') NOT NULL
);

-- Insertar bebidas naturales
INSERT INTO Productos (nombre, tipo, precio, stock) VALUES
('Jamaica', 'Bebida', 20.00, 50),
('Horchata', 'Bebida', 20.00, 50),
('Maracuyá', 'Bebida', 20.00, 50),
('Limón - Chia', 'Bebida', 20.00, 50),
('Té jazmín', 'Bebida', 20.00, 50),
('Limón - Fresa', 'Bebida', 20.00, 50),
('Limón - Pepino', 'Bebida', 20.00, 50);

-- Insertar refrescos
INSERT INTO Productos (nombre, tipo, precio, stock) VALUES
('Arizona Mango', 'Bebida', 22.00, 30),
('Arizona Sandía', 'Bebida', 22.00, 30),
('Arizona Kiwi Fresa', 'Bebida', 22.00, 30),
('Arizona Té Verde', 'Bebida', 22.00, 30),
('Coca-Cola', 'Bebida', 25.00, 40);

-- Insertar snacks
INSERT INTO Productos (nombre, tipo, precio, stock) VALUES
('Papas gajo (250 gr)', 'Snack', 65.00, 20);

-- Insertar extras
INSERT INTO Productos (nombre, tipo, precio, stock) VALUES
('Rebanada de queso amarillo', 'Extra', 5.00, 100),
('Queso cheddar', 'Extra', 15.00, 50),
('Tocino', 'Extra', 10.00, 50),
('Rebanada de piña', 'Extra', 10.00, 30),
('Pepinillos', 'Extra', 10.00, 30),
('Quesillo', 'Extra', 15.00, 30),
('Chistorra', 'Extra', 20.00, 30),
('Chorizo argentino', 'Extra', 20.00, 30),
('Arrachera', 'Extra', 25.00, 30),
('Salchicha de pavo', 'Extra', 10.00, 30);

-- Insertar hamburguesas y tacos
INSERT INTO Productos (nombre, tipo, precio, stock) VALUES
('Negrita BBQ', 'Hamburguesa', 95.00, 20),
('Tacos "BOLUDOS" con chorizo argentino', 'Taco', 110.00, 20);

-- Insertar promociones
INSERT INTO Promociones (descripcion, precio, dia) VALUES
('Martes de hot dog clásicos (3x2)', 0.00, 'Martes'),
('Miércoles de combo: Hamburguesa clásica + papas + Arizona', 125.00, 'Miércoles'),
('Jueves de hot dogs "Negrito Premium" (2 por 135)', 135.00, 'Jueves'),
('Viernes de hot dogs "Especial Negrito" (2 por 120)', 120.00, 'Viernes'),
('Sábado de alitas (1 kg)', 250.00, 'Sábado'),
('Domingo combo "Pareja": 2 hamburguesas clásicas + aros + papas', 250.00, 'Domingo');

