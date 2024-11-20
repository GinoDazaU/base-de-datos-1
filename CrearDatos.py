import pandas as pd
from faker import Faker
import random

fake = Faker()

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
for i in range(100): # Cambiamos este numero luego
    proveedores.append({
        'id_proveedor': i + 1,
        'nombre': fake.company(),
        'direccion': fake.address(),
        'correo': fake.company_email(),
        'numero': fake.msisdn()[:9]
    })

# Datos Productos y subclases
for i in range(300): # Cambiamos este numero luego
    id_proveedor = random.choice(proveedores)['id_proveedor']
    nombre = fake.word().capitalize()
    marca = fake.company()
    descripcion = fake.sentence(nb_words=6)
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

    # Clasificar productos en subclases
    clase = random.choice(['agua', 'cerveza', 'gaseosa'])
    if clase == 'agua':
        agua.append({'id_producto': i + 1, 'con_gas': random.choice([True, False])})
    elif clase == 'cerveza':
        cervezas.append({'id_producto': i + 1, 'grados_alcohol': round(random.uniform(0.0, 15.0), 2)})
    elif clase == 'gaseosa':
        gaseosas.append({'id_producto': i + 1, 'nivel_azucar': random.choice(['regular', 'light', 'zero'])})

# Datos Clientes
for i in range(200): # Cambiamos este numero luego
    clientes.append({
        'id_cliente': i + 1,
        'numero': fake.msisdn()[:9],
        'nombre': fake.name(),
        'correo': fake.email(),
        'direccion': fake.address()
    })

# Datos Kiosko
for i in range(50): # Cambiamos este numero luego
    kioskos.append({
        'id_kiosko': i + 1,
        'nombre': fake.company(),
        'numero': fake.msisdn()[:9],
        'direccion': fake.address()
    })

# Relacion Administra: Kiosko y Clientes
for kiosko in kioskos:
    administra.append({
        'id_kiosko': kiosko['id_kiosko'],
        'id_cliente': random.choice(clientes)['id_cliente']
    })

# Datos Pedidos
for i in range(500): # Cambiamos este numero luego
    pedidos.append({
        'id_pedido': i + 1,
        'total': 0,  # Esto con trigger
        'fecha': fake.date_this_year(),
        'estado': random.choice(['procesado', 'enviado', 'entregado'])
    })

# Relacion Hace: Clientes hacen pedidos
for pedido in pedidos:
    hace.append({
        'id_pedido': pedido['id_pedido'],
        'id_cliente': random.choice(clientes)['id_cliente']
    })

# Datos DetallesPedido
for pedido in pedidos:
    num_detalles = random.randint(1, 5)
    subtotal_total = 0

    for _ in range(num_detalles):
        producto = random.choice(productos)
        cantidad_solicitada = random.randint(1, 10)
        precio_unitario = producto['precio']
        subtotal = round(cantidad_solicitada * precio_unitario, 2)
        subtotal_total += subtotal

        detalles_pedido.append({
            'id_pedido': pedido['id_pedido'],
            'id_producto': producto['id_producto'],
            'cantidad_solicitada': cantidad_solicitada,
            'precio_unitario': precio_unitario,
            'subtotal': subtotal
        })

    pedido['total'] = round(subtotal_total, 2)

# Datos Pagos
for i in range(300): # Cambiamos este numero luego
    pedido = random.choice(pedidos)
    pagos.append({
        'id_pago': i + 1,
        'id_pedido': pedido['id_pedido'],
        'monto': pedido['total'],
        'fecha': fake.date_this_year(),
        'metodo_pago': random.choice(['efectivo', 'tarjeta', 'transferencia']),
        'estado': random.choice(['pendiente', 'completado'])
    })

def save_to_csv(data, filename):
    pd.DataFrame(data).to_csv(filename, index=False)
    print(f"{filename} creado.")

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
