import pandas as pd
from faker import Faker
import random
import os
from datetime import date, timedelta

# Inicialización
fake = Faker()
Faker.seed(0)
random.seed(0)

# Variables de escalabilidad
TOTAL_DATOS = 100000  # Cambia a 1k, 10k, 100k, 1M según lo necesites
PROVEEDORES = max(1, int(TOTAL_DATOS * 0.05))  # 5%
PRODUCTOS = max(1, int(TOTAL_DATOS * 0.4))  # 40%
CLIENTES = max(1, int(TOTAL_DATOS * 0.15))  # 15%
KIOSKOS = max(1, int(TOTAL_DATOS * 0.05))  # 5%
PEDIDOS = max(1, int(TOTAL_DATOS * 0.25))  # 25%
DETALLES_PEDIDO = max(1, int(TOTAL_DATOS * 0.4))  # 40%
PAGOS = max(1, int(PEDIDOS * 0.5))  # 50% de pedidos

# Conjuntos para garantizar unicidad
correos_generados = set()
numeros_generados = set()

# Generar datos
proveedores, productos, agua, cervezas, gaseosas = [], [], [], [], []
clientes, kioskos, pedidos, detalles_pedido, pagos, administra, hace = [], [], [], [], [], [], []

# Generar Proveedores
for i in range(PROVEEDORES):
    proveedores.append({
        'id_proveedor': i + 1,
        'nombre': f"Distribuidora {fake.word().capitalize()}",
        'direccion': fake.address(),
        'correo': fake.unique.company_email(),
        'numero': fake.unique.msisdn()[:9]
    })

# Generar Productos y Subclases
for i in range(PRODUCTOS):
    id_proveedor = random.choice(proveedores)['id_proveedor']
    clase = random.choices(['agua', 'cerveza', 'gaseosa'], weights=[0.2, 0.3, 0.5], k=1)[0]
    nombre = f"{fake.word().capitalize()} {i+1}"
    marca = random.choice(["Socosani", "San Mateo", "Cusquena", "Pilsen", "Inca Kola"])
    descripcion = f"Producto de calidad {marca}"
    cantidad = random.randint(500, 1500)
    precio = round(random.uniform(1.0, 15.0), 2)

    productos.append({
        'id_producto': i + 1,
        'id_proveedor': id_proveedor,
        'nombre': nombre,
        'marca': marca,
        'descripcion': descripcion,
        'cantidad': cantidad,
        'precio': precio
    })

    if clase == 'agua':
        agua.append({'id_producto': i + 1, 'con_gas': random.choice([True, False])})
    elif clase == 'cerveza':
        cervezas.append({'id_producto': i + 1, 'grados_alcohol': round(random.uniform(4.0, 12.0), 2)})
    elif clase == 'gaseosa':
        gaseosas.append({'id_producto': i + 1, 'nivel_azucar': random.choice(['regular', 'light', 'zero'])})

# Generar Clientes
for i in range(CLIENTES):
    while True:
        correo = fake.email()
        numero = fake.msisdn()[:9]
        if correo not in correos_generados and numero not in numeros_generados:
            correos_generados.add(correo)
            numeros_generados.add(numero)
            clientes.append({
                'id_cliente': i + 1,
                'numero': numero,
                'nombre': fake.name(),
                'correo': correo,
                'direccion': fake.address()
            })
            break

# Generar Kioskos
for i in range(KIOSKOS):
    while True:
        numero = fake.msisdn()[:9]
        if numero not in numeros_generados:
            numeros_generados.add(numero)
            kioskos.append({
                'id_kiosko': i + 1,
                'nombre': fake.company(),
                'numero': numero,
                'direccion': fake.address()
            })
            break

# Relación Administra
for kiosko in kioskos:
    administra.append({
        'id_kiosko': kiosko['id_kiosko'],
        'id_cliente': random.choice(clientes)['id_cliente']
    })

# Generar Pedidos
for i in range(PEDIDOS):
    pedidos.append({
        'id_pedido': i + 1,
        'total': 0,  # Se recalcula con triggers
        'fecha': fake.date_between(start_date="-2y", end_date="today"),
        'estado': random.choice(['procesado', 'enviado', 'entregado'])
    })

# Relación Hace
for pedido in pedidos:
    hace.append({
        'id_pedido': pedido['id_pedido'],
        'id_cliente': random.choice(clientes)['id_cliente']
    })

# Generar DetallesPedido
detalle_id = 1
detalles_existentes = set()
for pedido in pedidos:
    num_detalles = random.randint(1, 5)
    for _ in range(num_detalles):
        producto = random.choice(productos)
        key = (pedido['id_pedido'], producto['id_producto'])
        if key not in detalles_existentes:
            detalles_existentes.add(key)
            detalles_pedido.append({
                'id_detalle': detalle_id,
                'id_pedido': pedido['id_pedido'],
                'id_producto': producto['id_producto'],
                'cantidad_solicitada': random.randint(1, 10),
                'precio_unitario': producto['precio']
            })
            detalle_id += 1

# Generar Pagos
for i in range(PAGOS):
    pedido = random.choice(pedidos)
    pagos.append({
        'id_pago': i + 1,
        'id_pedido': pedido['id_pedido'],
        'monto': round(random.uniform(50.0, 500.0), 2),
        'fecha': fake.date_between(start_date=pedido['fecha'], end_date="today"),
        'metodo_pago': random.choice(['efectivo', 'tarjeta', 'transferencia']),
        'estado': random.choice(['pendiente', 'completado'])
    })

# Guardar en CSV
def save_to_csv(data, filename):
    folder = "datos"
    if not os.path.exists(folder):
        os.makedirs(folder)
    filepath = os.path.join(folder, filename)
    pd.DataFrame(data).to_csv(filepath, index=False)
    print(f"{filepath} creado.")

# Guardar
save_to_csv(proveedores, "proveedores.csv")
save_to_csv(productos, "productos.csv")
save_to_csv(agua, "agua.csv")
save_to_csv(cervezas, "cervezas.csv")
save_to_csv(gaseosas, "gaseosas.csv")
save_to_csv(clientes, "clientes.csv")
save_to_csv(kioskos, "kioskos.csv")
save_to_csv(administra, "administra.csv")
save_to_csv(pedidos, "pedidos.csv")
save_to_csv(hace, "hace.csv")
save_to_csv(detalles_pedido, "detalles_pedido.csv")
save_to_csv(pagos, "pagos.csv")
