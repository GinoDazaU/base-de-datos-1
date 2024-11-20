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
