SET search_path TO s1m;

SET enable_seqscan = ON;
SET enable_bitmapscan = OFF;
SET enable_indexscan = OFF;

VACUUM (FULL, ANALYZE) proveedores;
VACUUM (FULL, ANALYZE) productos;
VACUUM (FULL, ANALYZE) agua;
VACUUM (FULL, ANALYZE) cervezas;
VACUUM (FULL, ANALYZE) gaseosas;
VACUUM (FULL, ANALYZE) clientes;
VACUUM (FULL, ANALYZE) kiosko;
VACUUM (FULL, ANALYZE) administra;
VACUUM (FULL, ANALYZE) pedidos;
VACUUM (FULL, ANALYZE) hace;
VACUUM (FULL, ANALYZE) detallespedido;
VACUUM (FULL, ANALYZE) pagos;
