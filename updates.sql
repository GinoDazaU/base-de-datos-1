-- Actualizar los totales en la tabla Pedidos en base a los subtotales de DetallesPedido
UPDATE Pedidos
SET total = subquery.total
FROM (
    SELECT id_pedido, COALESCE(SUM(subtotal), 0) AS total
    FROM DetallesPedido
    GROUP BY id_pedido
) AS subquery
WHERE Pedidos.id_pedido = subquery.id_pedido;

-- Actualizar el estado de los pedidos si el total de los pagos iguala o supera el total del pedido
WITH pagos_acumulados AS (
    SELECT
        p.id_pedido,
        COALESCE(SUM(pa.monto), 0) AS total_pagado
    FROM Pedidos p
    LEFT JOIN Pagos pa ON p.id_pedido = pa.id_pedido
    GROUP BY p.id_pedido
)
UPDATE Pedidos
SET estado = 'completado'
FROM pagos_acumulados pa
WHERE Pedidos.id_pedido = pa.id_pedido
  AND pa.total_pagado >= Pedidos.total;

-- Insertar pagos adicionales sin afectar el estado de los pedidos ya completados
-- (No se requiere ninguna acción adicional, los pagos se insertan normalmente).

-- Comprobar si los pagos exceden el total permitido (solo para referencia, no bloquea la inserción)
DO $$
BEGIN
    UPDATE Pagos
    SET monto = (
        SELECT LEAST(
            Pagos.monto,
            Pedidos.total - COALESCE((
                SELECT SUM(pagos_previos.monto)
                FROM Pagos pagos_previos
                WHERE pagos_previos.id_pedido = Pagos.id_pedido
            ), 0)
        )
        FROM Pedidos
        WHERE Pedidos.id_pedido = Pagos.id_pedido
    )
    WHERE EXISTS (
        SELECT 1
        FROM Pedidos
        WHERE Pagos.id_pedido = Pedidos.id_pedido
          AND Pagos.monto > Pedidos.total
    );
    -- Esto ajusta el pago para que no exceda el límite permitido, si es necesario.
END $$;

-- Informar el estado final (opcional)
SELECT
    id_pedido,
    total,
    estado,
    (SELECT COALESCE(SUM(monto), 0) FROM Pagos WHERE Pagos.id_pedido = Pedidos.id_pedido) AS total_pagado
FROM Pedidos;
