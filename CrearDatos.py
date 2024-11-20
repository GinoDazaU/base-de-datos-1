import pandas as pd
from faker import Faker
import random
import os

fake = Faker()

# Listas de datos temáticos
marcas_agua = ["Pureza", "Vital", "AquaLife", "Fuente Clara"]
marcas_cerveza = ["Cerveza Dorada", "Malta Real", "Lúpulo Fino", "Cerveza Artesana"]
marcas_gaseosa = ["Fizz Cola", "Sabor Limonada", "Energía Zero", "Burbujeante"]
nombres_productos = ["Agua Mineral", "Cerveza Artesanal", "Gaseosa Clásica", "Tónica"]
nombres_kioskos = ["Tienda Esquina", "Kiosko Central", "Abastecimientos Rápidos", "La Esquina Verde"]

# Inicialización de listas para cada tabla
proveedores = []
productos = []
agua = []
cervezas = []
gaseosas = []
clientes = []
kioskos = []
pedidos = []
detalles_pedido = []
pagos = []
administra = []
hace = []

# Datos Proveedores
for i in range(100):
    proveedores.append({
        'id_proveedor': i + 1,
        'nombre': f"Distribuidora {fake.word().capitalize()}",
        'direccion': fake.address(),
        'correo': fake.company_email(),
        'numero': fake.msisdn()[:9]
    })

# Datos Productos y subclases
clases = ['agua'] * 40 + ['cerveza'] * 30 + ['gaseosa'] * 30
for i, clase in enumerate(random.choices(clases, k=300)):
    id_proveedor = random.choice(proveedores)['id_proveedor']
    nombre = f"{random.choice(nombres_productos)} {i+1}"
    marca = (
        random.choice(marcas_agua) if clase == "agua" else
        random.choice(marcas_cerveza) if clase == "cerveza" else
        random.choice(marcas_gaseosa)
    )
    descripcion = f"Producto de alta calidad: {marca}"
    cantidad = random.randint(0, 1000)
    precio = round(random.uniform(1.0, 75.0), 2)

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
        cervezas.append({'id_producto': i + 1, 'grados_alcohol': round(random.uniform(0.0, 15.0), 2)})
    elif clase == 'gaseosa':
        gaseosas.append({'id_producto': i + 1, 'nivel_azucar': random.choice(['regular', 'light', 'zero'])})

# Datos Clientes
for i in range(200):
    clientes.append({
        'id_cliente': i + 1,
        'numero': fake.msisdn()[:9],
        'nombre': fake.name(),
        'correo': fake.email(),
        'direccion': fake.address()
    })

# Datos Kiosko
for i in range(50):
    kioskos.append({
        'id_kiosko': i + 1,
        'nombre': random.choice(nombres_kioskos),
        'numero': fake.msisdn()[:9],
        'direccion': fake.address()
    })

# Relación Administra: Kiosko y Clientes
for kiosko in kioskos:
    administra.append({
        'id_kiosko': kiosko['id_kiosko'],
        'id_cliente': random.choice(clientes)['id_cliente']
    })

# Datos Pedidos
for i in range(500):
    pedidos.append({
        'id_pedido': i + 1,
        'total': 0,  # Se deja en 0 para que el trigger lo calcule
        'fecha': fake.date_this_year(),
        'estado': random.choice(['procesado', 'enviado', 'entregado'])
    })

# Relación Hace: Clientes hacen pedidos
for pedido in pedidos:
    hace.append({
        'id_pedido': pedido['id_pedido'],
        'id_cliente': random.choice(clientes)['id_cliente']
    })

# Datos DetallesPedido
detalles_existentes = set()  # Usamos un conjunto para evitar duplicados

for pedido in pedidos:
    num_detalles = random.randint(1, 5)

    for _ in range(num_detalles):
        producto = random.choice(productos)
        key = (pedido['id_pedido'], producto['id_producto'])

        if key not in detalles_existentes:  # Verificamos duplicados
            detalles_existentes.add(key)
            cantidad_solicitada = random.randint(1, 10)
            precio_unitario = producto['precio']

            detalles_pedido.append({
                'id_pedido': pedido['id_pedido'],
                'id_producto': producto['id_producto'],
                'cantidad_solicitada': cantidad_solicitada,
                'precio_unitario': precio_unitario
            })

# Datos Pagos
for i in range(300):
    pedido = random.choice(pedidos)
    pagos.append({
        'id_pago': i + 1,
        'id_pedido': pedido['id_pedido'],
        'monto': round(pedido['total'] * random.uniform(0.8, 1.0), 2),  # 80%-100% del total
        'fecha': fake.date_this_year(),
        'metodo_pago': random.choice(['efectivo', 'tarjeta', 'transferencia']),
        'estado': random.choice(['pendiente', 'completado'])
    })

# Función para guardar los datos en CSV
def save_to_csv(data, filename):
    folder = "datos"
    if not os.path.exists(folder):
        os.makedirs(folder)
    filepath = os.path.join(folder, filename)
    pd.DataFrame(data).to_csv(filepath, index=False)
    print(f"{filepath} creado.")
    

# Guardar cada tabla en un archivo CSV
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
