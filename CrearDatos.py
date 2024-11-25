import pandas as pd
from faker import Faker
import random
import os

# Inicialización
fake = Faker()
Faker.seed(0)
random.seed(0)

TOTAL_DATOS = 1000000 # CAMBIAR ESTO dependiendo del esquema

PROVEEDORES = TOTAL_DATOS
PRODUCTOS = TOTAL_DATOS * 3
PEDIDOS = TOTAL_DATOS
DETALLES_PEDIDO = TOTAL_DATOS
PAGOS = TOTAL_DATOS
CLIENTES = TOTAL_DATOS
KIOSKOS = TOTAL_DATOS

# Conjuntos para garantizar unicidad
correos_generados = set()
numeros_generados = set()

# Marcas y nombres reales por categoría
AGUA_MARCAS = ["Cielo", "San Mateo", "San Luis", "Socosani", "Andea"]
CERVEZA_MARCAS = ["Cusqueña", "Pilsen", "Cristal", "Arequipeña", "Barena"]
GASEOSA_MARCAS = ["Inca Kola", "Kola Real", "Coca Cola", "Pepsi", "Fanta"]

# Generar datos
proveedores, productos, agua, cervezas, gaseosas = [], [], [], [], []
clientes, kioskos, pedidos, detalles_pedido, pagos, administra, hace = [], [], [], [], [], [], []

# Generar Proveedores
for i in range(PROVEEDORES):
    while True:
        numero = fake.unique.msisdn()[:9]
        if numero not in numeros_generados:
            numeros_generados.add(numero)
            proveedores.append({
                'id_proveedor': i + 1,
                'nombre': f"Distribuidora {fake.word().capitalize()}",
                'direccion': fake.address(),
                'correo': fake.unique.company_email(),
                'numero': numero
            })
            break

# Generar Productos y Subclases (Distribución fija)
num_agua = PRODUCTOS // 3
num_cervezas = PRODUCTOS // 3
num_gaseosas = PRODUCTOS - num_agua - num_cervezas

for i in range(PRODUCTOS):
    id_proveedor = random.choice(proveedores)['id_proveedor']
    cantidad = random.randint(500, 1500)
    precio = round(random.uniform(5.0, 20.0), 2)  # Precios más altos

    if i < num_agua:
        marca = random.choice(AGUA_MARCAS)
        nombre = f"Agua {marca} {i+1}"
        descripcion = f"Agua mineral {marca} pura y refrescante"
        agua.append({'id_producto': i + 1, 'con_gas': random.choice([True, False])})
    elif i < num_agua + num_cervezas:
        marca = random.choice(CERVEZA_MARCAS)
        nombre = f"Cerveza {marca} {i+1}"
        descripcion = f"Cerveza {marca}, calidad premium con sabor único"
        cervezas.append({'id_producto': i + 1, 'grados_alcohol': round(random.uniform(4.0, 12.0), 2)})
    else:
        marca = random.choice(GASEOSA_MARCAS)
        nombre = f"Gaseosa {marca} {i+1}"
        descripcion = f"Gaseosa {marca} con sabor inconfundible y refrescante"
        gaseosas.append({'id_producto': i + 1, 'nivel_azucar': random.choice(['regular', 'light', 'zero'])})

    productos.append({
        'id_producto': i + 1,
        'id_proveedor': id_proveedor,
        'nombre': nombre,
        'marca': marca,
        'descripcion': descripcion,
        'cantidad': cantidad,
        'precio': precio
    })

# Generar Clientes
for i in range(CLIENTES):
    while True:
        correo = fake.unique.company_email()
        numero = fake.unique.msisdn()[:9]
        if numero not in numeros_generados:
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
    numero = fake.unique.msisdn()[:9]
    kioskos.append({
        'id_kiosko': i + 1,
        'nombre': fake.company(),
        'numero': numero,
        'direccion': fake.address()
    })

# Relación Administra (Clientes -> Kioskos)
for i in range(KIOSKOS):
    administra.append({
        'id_kiosko': kioskos[i]['id_kiosko'],
        'id_cliente': clientes[i % len(clientes)]['id_cliente']
    })

# Generar Pedidos
for i in range(PEDIDOS):
    pedidos.append({
        'id_pedido': i + 1,
        'total': 0,  # Se calculará con los detalles del pedido
        'fecha': fake.date_between(start_date="-2y", end_date="today"),
        'estado': random.choice(['procesado', 'enviado', 'entregado'])
    })

# Relación Hace (Clientes -> Pedidos)
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
    total_pedido = 0
    for _ in range(num_detalles):
        producto = random.choice(productos)
        key = (pedido['id_pedido'], producto['id_producto'])
        if key not in detalles_existentes:
            detalles_existentes.add(key)
            cantidad = random.randint(1, 10)
            subtotal = cantidad * producto['precio']
            detalles_pedido.append({
                'id_detalle': detalle_id,
                'id_pedido': pedido['id_pedido'],
                'id_producto': producto['id_producto'],
                'cantidad_solicitada': cantidad,
                'precio_unitario': producto['precio']
            })
            total_pedido += subtotal
            detalle_id += 1
    pedido['total'] = round(total_pedido, 2)  # Actualizar el total del pedido

# Generar Pagos
for i in range(PAGOS):
    pedido = random.choice(pedidos)
    monto = random.randint(1, int(pedido['total'] * 0.2))  # Pagos pequeños (máx. 20% del total)
    
    pagos.append({
        'id_pago': i + 1,
        'id_pedido': pedido['id_pedido'],
        'monto': monto,
        'fecha': fake.date_between(start_date=pedido['fecha'], end_date="today"),
        'metodo_pago': random.choice(['efectivo', 'tarjeta', 'transferencia']),
        'estado': 'pendiente'
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
