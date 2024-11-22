-- Actualizar los totales en la tabla Pedidos
UPDATE Pedidos
SET total = subquery.total
FROM (
    SELECT id_pedido, COALESCE(SUM(subtotal), 0) AS total
    FROM DetallesPedido
    GROUP BY id_pedido
) AS subquery
WHERE Pedidos.id_pedido = subquery.id_pedido;

-- Actualizar el estado de los pagos
WITH pagos_acumulados AS (
    SELECT id_pedido, COALESCE(SUM(monto), 0) AS total_pagado
    FROM Pagos
    GROUP BY id_pedido
)
UPDATE Pagos
SET estado = CASE
    WHEN pagos_acumulados.total_pagado >= (
        SELECT total FROM Pedidos WHERE id_pedido = pagos_acumulados.id_pedido
    ) THEN 'completado'
    ELSE 'pendiente'
END
FROM pagos_acumulados
WHERE Pagos.id_pedido = pagos_acumulados.id_pedido;

-- Actualizar el estado de los pedidos
WITH pedidos_actualizados AS (
    SELECT id_pedido, COALESCE(SUM(monto), 0) AS total_pagado
    FROM Pagos
    GROUP BY id_pedido
)
UPDATE Pedidos
SET estado = CASE
    WHEN pedidos_actualizados.total_pagado >= Pedidos.total THEN 'entregado'
    ELSE estado
END
FROM pedidos_actualizados
WHERE Pedidos.id_pedido = pedidos_actualizados.id_pedido;
