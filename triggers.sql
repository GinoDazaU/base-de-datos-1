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



-- Función para validar el monto de pagos
CREATE OR REPLACE FUNCTION validar_pago()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar que el monto no exceda el total del pedido
    IF NEW.monto > (
        SELECT total FROM Pedidos WHERE id_pedido = NEW.id_pedido
    ) THEN
        RAISE EXCEPTION 'El monto del pago % excede el total del pedido %', NEW.monto, NEW.id_pedido;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para Pagos
CREATE TRIGGER trigger_validar_pago
BEFORE INSERT OR UPDATE ON Pagos
FOR EACH ROW
EXECUTE FUNCTION validar_pago();



-- Función para actualizar el estado del pedido
CREATE OR REPLACE FUNCTION actualizar_estado_pedido()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar el estado del pedido si el monto cubre el total
    IF (SELECT COALESCE(SUM(monto), 0) FROM Pagos WHERE id_pedido = NEW.id_pedido) >= (
        SELECT total FROM Pedidos WHERE id_pedido = NEW.id_pedido
    ) THEN
        UPDATE Pedidos
        SET estado = 'completado'
        WHERE id_pedido = NEW.id_pedido;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para Pagos
CREATE TRIGGER trigger_actualizar_estado_pedido
AFTER INSERT OR UPDATE ON Pagos
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_pedido();



-- Función para validar el estado del pedido
CREATE OR REPLACE FUNCTION validar_estado_pedido()
RETURNS TRIGGER AS $$
BEGIN
    -- Bloquear la operación si el pedido está completado
    IF (SELECT estado FROM Pedidos WHERE id_pedido = NEW.id_pedido) = 'completado' THEN
        RAISE EXCEPTION 'No se pueden agregar o modificar detalles para un pedido completado';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para DetallesPedido
CREATE TRIGGER trigger_validar_estado_pedido
BEFORE INSERT OR UPDATE ON DetallesPedido
FOR EACH ROW
EXECUTE FUNCTION validar_estado_pedido();