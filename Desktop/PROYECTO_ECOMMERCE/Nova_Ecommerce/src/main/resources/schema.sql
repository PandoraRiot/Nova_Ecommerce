-- SQL Script para la creación de la base de datos 'nova_ecommerce'
-- Autor: [Tu Nombre]
-- Fecha: 2025-05-24
-- Descripción: Este script define el esquema de la base de datos para la aplicación de e-commerce 'Nova_Ecommerce'.
-- Incluye tablas para usuarios, productos, categorías, pedidos, ítems del carrito, reseñas y pagos,
-- con sus respectivas relaciones de clave primaria y foránea.

-- ====================================================================
-- IMPORTANTE: Antes de ejecutar, asegúrate de que la base de datos 'nova_ecommerce' ya exista.
-- Puedes crearla con un simple: CREATE DATABASE nova_ecommerce;
-- ====================================================================

-- Selecciona la base de datos sobre la cual se aplicarán los cambios
USE nova_ecommerce;

-- Desactiva las comprobaciones de claves foráneas temporalmente.
-- Esto es útil para evitar errores de orden al crear tablas con dependencias.
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------------------
-- Tabla: Users
-- Descripción: Almacena la información de todos los usuarios del sistema,
--              incluyendo clientes y posibles administradores.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Users (
                                     id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único del usuario',
                                     username VARCHAR(50) NOT NULL UNIQUE COMMENT 'Nombre de usuario único para el login',
    password VARCHAR(255) NOT NULL COMMENT 'Contraseña cifrada (hashed) del usuario',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'Dirección de correo electrónico única del usuario',
    first_name VARCHAR(50) NOT NULL COMMENT 'Primer nombre del usuario',
    last_name VARCHAR(50) NOT NULL COMMENT 'Apellido del usuario',
    phone_number VARCHAR(20) COMMENT 'Número de teléfono del usuario',
    role VARCHAR(20) DEFAULT 'USER' COMMENT 'Rol del usuario en el sistema (ej: USER, ADMIN)', -- 'USER' por defecto
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última actualización del registro'
    ) ENGINE=InnoDB COMMENT='Tabla de usuarios del sistema';

-- --------------------------------------------------------------------
-- Tabla: Categories
-- Descripción: Define las categorías de los productos para su organización.
--              Ejemplos: 'Electrónica', 'Ropa', 'Libros', 'Hogar'.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Categories (
                                          id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único de la categoría',
                                          name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Nombre único de la categoría',
    description TEXT COMMENT 'Descripción detallada de la categoría'
    ) ENGINE=InnoDB COMMENT='Tabla de categorías de productos';

-- --------------------------------------------------------------------
-- Tabla: Products
-- Descripción: Contiene todos los productos disponibles para la venta.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Products (
                                        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único del producto',
                                        name VARCHAR(255) NOT NULL COMMENT 'Nombre del producto',
    description TEXT COMMENT 'Descripción detallada del producto',
    price DECIMAL(10, 2) NOT NULL COMMENT 'Precio unitario del producto',
    stock_quantity INT NOT NULL DEFAULT 0 COMMENT 'Cantidad de unidades disponibles en inventario',
    category_id BIGINT COMMENT 'Clave foránea a la tabla Categories',
    image_url VARCHAR(255) COMMENT 'URL de la imagen principal del producto',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro del producto',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última actualización del producto',
    FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE SET NULL ON UPDATE CASCADE
    ) ENGINE=InnoDB COMMENT='Tabla de productos en venta';

-- --------------------------------------------------------------------
-- Tabla: Addresses
-- Descripción: Almacena las direcciones de envío y facturación de los usuarios.
--              Un usuario puede tener múltiples direcciones.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Addresses (
                                         id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único de la dirección',
                                         user_id BIGINT NOT NULL COMMENT 'Clave foránea al usuario propietario de la dirección',
                                         street_address VARCHAR(255) NOT NULL COMMENT 'Calle y número de la dirección',
    city VARCHAR(100) NOT NULL COMMENT 'Ciudad de la dirección',
    state_province VARCHAR(100) NOT NULL COMMENT 'Estado o provincia de la dirección',
    zip_code VARCHAR(20) NOT NULL COMMENT 'Código postal de la dirección',
    country VARCHAR(100) NOT NULL COMMENT 'País de la dirección',
    address_type VARCHAR(20) NOT NULL COMMENT 'Tipo de dirección (SHIPPING para envío, BILLING para facturación)',
    is_default BOOLEAN DEFAULT FALSE COMMENT 'Indica si es la dirección por defecto para su tipo',
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB COMMENT='Tabla de direcciones de usuarios';

-- --------------------------------------------------------------------
-- Tabla: Orders
-- Descripción: Registra los pedidos que los usuarios realizan.
--              Contiene información general del pedido como fecha, monto total y estado.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Orders (
                                      id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único del pedido',
                                      user_id BIGINT NOT NULL COMMENT 'Clave foránea al usuario que realizó el pedido',
                                      order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora en que se realizó el pedido',
                                      total_amount DECIMAL(10, 2) NOT NULL COMMENT 'Monto total del pedido, incluyendo impuestos y envío',
    status VARCHAR(50) DEFAULT 'PENDING' COMMENT 'Estado actual del pedido (PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED)',
    shipping_address_id BIGINT COMMENT 'Clave foránea a la dirección de envío del pedido',
    billing_address_id BIGINT COMMENT 'Clave foránea a la dirección de facturación del pedido',
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (shipping_address_id) REFERENCES Addresses(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (billing_address_id) REFERENCES Addresses(id) ON DELETE RESTRICT ON UPDATE CASCADE
    ) ENGINE=InnoDB COMMENT='Tabla de pedidos de usuarios';

-- --------------------------------------------------------------------
-- Tabla: Order_Items
-- Descripción: Detalla los productos incluidos en cada pedido.
--              Cada fila representa un producto específico y su cantidad dentro de un pedido.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Order_Items (
                                           id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único del ítem del pedido',
                                           order_id BIGINT NOT NULL COMMENT 'Clave foránea al pedido al que pertenece este ítem',
                                           product_id BIGINT NOT NULL COMMENT 'Clave foránea al producto incluido en el pedido',
                                           quantity INT NOT NULL COMMENT 'Cantidad de este producto en el pedido',
                                           price_at_order DECIMAL(10, 2) NOT NULL COMMENT 'Precio unitario del producto en el momento exacto del pedido',
    FOREIGN KEY (order_id) REFERENCES Orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(id) ON DELETE RESTRICT ON UPDATE CASCADE
    ) ENGINE=InnoDB COMMENT='Tabla de ítems dentro de cada pedido';

-- --------------------------------------------------------------------
-- Tabla: Shopping_Carts
-- Descripción: Representa el carrito de compras actual de un usuario.
--              Cada usuario tiene un único carrito activo.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Shopping_Carts (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único del carrito de compras',
                                              user_id BIGINT NOT NULL UNIQUE COMMENT 'Clave foránea al usuario propietario del carrito (único por usuario)',
                                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del carrito',
                                              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la última actualización del carrito',
                                              FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB COMMENT='Tabla de carritos de compras de usuarios';

-- --------------------------------------------------------------------
-- Tabla: Cart_Items
-- Descripción: Detalla los productos que un usuario ha añadido a su carrito de compras.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Cart_Items (
                                          id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único del ítem en el carrito',
                                          cart_id BIGINT NOT NULL COMMENT 'Clave foránea al carrito de compras al que pertenece este ítem',
                                          product_id BIGINT NOT NULL COMMENT 'Clave foránea al producto añadido al carrito',
                                          quantity INT NOT NULL COMMENT 'Cantidad de este producto en el carrito',
                                          FOREIGN KEY (cart_id) REFERENCES Shopping_Carts(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (cart_id, product_id) COMMENT 'Restricción: un producto solo puede estar una vez en un carrito'
    ) ENGINE=InnoDB COMMENT='Tabla de ítems dentro del carrito de compras';

-- --------------------------------------------------------------------
-- Tabla: Reviews
-- Descripción: Almacena las reseñas y calificaciones que los usuarios dan a los productos.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Reviews (
                                       id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único de la reseña',
                                       product_id BIGINT NOT NULL COMMENT 'Clave foránea al producto reseñado',
                                       user_id BIGINT NOT NULL COMMENT 'Clave foránea al usuario que escribió la reseña',
                                       rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5) COMMENT 'Calificación del producto (1 a 5 estrellas)',
    comment TEXT COMMENT 'Comentario de la reseña',
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora en que se envió la reseña',
    FOREIGN KEY (product_id) REFERENCES Products(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (product_id, user_id) COMMENT 'Restricción: un usuario solo puede dejar una reseña por producto'
    ) ENGINE=InnoDB COMMENT='Tabla de reseñas y calificaciones de productos';

-- --------------------------------------------------------------------
-- Tabla: Payments
-- Descripción: Registra los detalles de las transacciones de pago asociadas a los pedidos.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Payments (
                                        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único del pago',
                                        order_id BIGINT NOT NULL UNIQUE COMMENT 'Clave foránea al pedido asociado a este pago (un pago por pedido)',
                                        payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora en que se procesó el pago',
                                        amount DECIMAL(10, 2) NOT NULL COMMENT 'Monto exacto del pago',
    payment_method VARCHAR(50) NOT NULL COMMENT 'Método de pago utilizado (ej: Credit Card, PayPal, Transferencia)',
    transaction_id VARCHAR(255) COMMENT 'ID de la transacción proporcionado por el procesador de pagos',
    status VARCHAR(50) DEFAULT 'PENDING' COMMENT 'Estado del pago (PENDING, COMPLETED, FAILED, REFUNDED)',
    FOREIGN KEY (order_id) REFERENCES Orders(id) ON DELETE RESTRICT ON UPDATE CASCADE
    ) ENGINE=InnoDB COMMENT='Tabla de registros de pagos';

-- Reactiva las comprobaciones de claves foráneas.
-- Es buena práctica dejarlo activado en operaciones normales.
SET FOREIGN_KEY_CHECKS = 1;