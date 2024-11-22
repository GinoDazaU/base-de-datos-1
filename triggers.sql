-- Función para actualizar el total de Pedidos
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

-- Función para actualizar el stock de productos
CREATE OR REPLACE FUNCTION actualizar_stock_producto()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar que haya suficiente stock antes de realizar el pedido
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.cantidad_solicitada > (
        SELECT cantidad FROM Productos WHERE id_producto = NEW.id_producto
    ) THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto %', NEW.id_producto;
    END IF;

    -- Reducir el stock del producto tras insertar o actualizar el detalle
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE Productos
        SET cantidad = cantidad - NEW.cantidad_solicitada
        WHERE id_producto = NEW.id_producto;
    END IF;

    -- Revertir el stock del producto si se elimina un detalle de pedido
    IF TG_OP = 'DELETE' THEN
        UPDATE Productos
        SET cantidad = cantidad + OLD.cantidad_solicitada
        WHERE id_producto = OLD.id_producto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para DetallesPedido
CREATE TRIGGER trigger_actualizar_stock_producto
AFTER INSERT OR UPDATE OR DELETE ON DetallesPedido
FOR EACH ROW
EXECUTE FUNCTION actualizar_stock_producto();

-- Función para validar y ajustar el monto de los pagos
CREATE OR REPLACE FUNCTION validar_pago()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar estado del pago a completado si el total es alcanzado
    IF (SELECT COALESCE(SUM(monto), 0) 
        FROM Pagos 
        WHERE id_pedido = NEW.id_pedido) >= (
        SELECT total 
        FROM Pedidos 
        WHERE id_pedido = NEW.id_pedido
    ) THEN
        UPDATE Pagos
        SET estado = 'completado'
        WHERE id_pedido = NEW.id_pedido;
    ELSE
        NEW.estado := 'pendiente';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para validar pagos
CREATE TRIGGER trigger_validar_pago
BEFORE INSERT OR UPDATE ON Pagos
FOR EACH ROW
EXECUTE FUNCTION validar_pago();

-- Función para actualizar el estado de los pedidos
CREATE OR REPLACE FUNCTION actualizar_estado_pedido()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar estado del pedido a entregado si el pago está completo
    IF (SELECT COALESCE(SUM(monto), 0) 
        FROM Pagos 
        WHERE id_pedido = NEW.id_pedido) >= (
        SELECT total 
        FROM Pedidos 
        WHERE id_pedido = NEW.id_pedido
    ) THEN
        UPDATE Pedidos
        SET estado = 'entregado'
        WHERE id_pedido = NEW.id_pedido;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para actualizar el estado de pedidos
CREATE TRIGGER trigger_actualizar_estado_pedido
AFTER INSERT OR UPDATE ON Pagos
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_pedido();

-- Función para bloquear modificaciones a pedidos completados
CREATE OR REPLACE FUNCTION validar_estado_pedido()
RETURNS TRIGGER AS $$
BEGIN
    -- Bloquear cualquier operación si el pedido está entregado
    IF (SELECT estado FROM Pedidos WHERE id_pedido = NEW.id_pedido) = 'entregado' THEN
        RAISE EXCEPTION 'No se pueden modificar detalles de un pedido entregado';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para validar modificaciones en pedidos
CREATE TRIGGER trigger_validar_estado_pedido
BEFORE INSERT OR UPDATE ON DetallesPedido
FOR EACH ROW
EXECUTE FUNCTION validar_estado_pedido();
