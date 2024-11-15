[Guia de asesoria](https://utec.zoom.us/rec/play/iQCioZjgNJaDvpgoizvUyXcvnn53nvw7pL0dFRKldyjGcRgJog3VYYVMAvR9EcO3NRb_LaRA3aP7QsB4.49yaF2lKIQBzV7k0?canPlayFromShare=true&from=share_recording_detail&continueMode=true&componentName=rec-play&originRequestUrl=https%3A%2F%2Futec.zoom.us%2Frec%2Fshare%2FtT2kX-ECbpgnmfoK20QP6IFzs6uIpQ0j3BDQ_7HACuJMyWFhkfNstQXRmNxyH4A.pGIGNwY6NhCzc8kH)

## TODO:

1. **Implementación de la Base de Datos:**
   - Crear las tablas en PostgreSQL basadas en el modelo relacional definido.
   - Definir relaciones y restricciones clave.
   - Configurar la base de datos para manejar datos sintéticos generados con Faker.

2. **Poblar la Base de Datos:**
   - Utilizar Faker para generar datos sintéticos realistas.
   - Insertar datos para todas las tablas: `Proveedores`, `Productos`, `Clientes`, `Pedidos`, `Pagos`, etc.

3. **Consultas SQL:**
   - Diseñar y ejecutar consultas para satisfacer los requerimientos operativos.
   - Ejemplos de consultas:
     - Estado de pedidos y pagos.
     - Disponibilidad de productos en inventario.
     - Reportes de ventas por cliente, proveedor o periodo.

4. **Optimización:**
   - Identificar consultas críticas.
   - Implementar índices en columnas clave para mejorar el rendimiento.
   - Analizar y comparar tiempos de respuesta con y sin índices.

5. **Experimentación:**
   - Realizar pruebas de rendimiento con diferentes volúmenes de datos (1,000; 10,000; 100,000; 1,000,000 registros).
   - Documentar los resultados y análisis de los tiempos de ejecución.

6. **Documentación:**
   - Incluir un informe detallado de las implementaciones y resultados obtenidos.
   - Agregar un vídeo de las pruebas con 1 millón de registros.

## Resumen de la Parte 2

### Implementación en PostgreSQL
- Crear la estructura de la base de datos utilizando las tablas definidas en el modelo relacional.
- Registrar los datos necesarios para las operaciones de la distribuidora.

### Optimización y Experimentación
- Implementar índices en columnas críticas para mejorar la eficiencia de las consultas.
- Realizar experimentos con datos simulados, evaluando el rendimiento de las consultas:
  - Sin índices.
  - Con índices.
- Registrar los resultados y crear cuadros comparativos para analizar la mejora en los tiempos de respuesta.

### Informe Técnico
- Explicar la creación y configuración de las tablas.
- Detallar el proceso de generación y carga de datos con Faker.
- Documentar las consultas SQL utilizadas para el análisis.
- Analizar el impacto de los índices en las operaciones de la base de datos.

### Vídeo de Experimentación
- Incluir un vídeo demostrando la manipulación de la base de datos con 1 millón de registros, comparando tiempos de respuesta con y sin índices.

### Opcional (Puntos Extras)
- Desarrollar un front-end simple que permita interactuar con la base de datos desde una interfaz web.
