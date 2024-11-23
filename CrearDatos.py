import pandas as pd
import numpy as np
from faker import Faker
import random
import os

# Inicialización
fake = Faker()
Faker.seed(0)
random.seed(0)
np.random.seed(0)

TOTAL_DATOS = 10000

PROVEEDORES = TOTAL_DATOS
PRODUCTOS = TOTAL_DATOS * 3
PEDIDOS = TOTAL_DATOS
PAGOS = TOTAL_DATOS
CLIENTES = TOTAL_DATOS
KIOSKOS = TOTAL_DATOS * 2

# Generar números únicos de teléfono
def generate_unique_phone_numbers(N):
    return [f"{number:09d}" for number in random.sample(range(100000000, 999999999), N)]

# Generar correos únicos
def generate_unique_emails(N, domain):
    return [f"user{number:07d}@{domain}" for number in range(1, N + 1)]

# Generar un conjunto de datos para nombres y direcciones
def generate_sample_data(size, data_function):
    return [data_function() for _ in range(size)]

# Generar Proveedores
def generate_proveedores(PROVEEDORES):
    phone_numbers = generate_unique_phone_numbers(PROVEEDORES)
    emails = generate_unique_emails(PROVEEDORES, "proveedores.com")
    nombres = generate_sample_data(PROVEEDORES, lambda: f"Distribuidora {fake.word().capitalize()}")
    direcciones = generate_sample_data(PROVEEDORES, fake.address)
    data = {
        'id_proveedor': np.arange(1, PROVEEDORES + 1),
        'nombre': nombres,
        'direccion': direcciones,
        'correo': emails,
        'numero': phone_numbers
    }
    return pd.DataFrame(data)

# Generar Clientes
def generate_clientes(CLIENTES):
    phone_numbers = generate_unique_phone_numbers(CLIENTES)
    emails = generate_unique_emails(CLIENTES, "clientes.com")
    nombres = generate_sample_data(CLIENTES, fake.name)
    direcciones = generate_sample_data(CLIENTES, fake.address)
    data = {
        'id_cliente': np.arange(1, CLIENTES + 1),
        'numero': phone_numbers,
        'nombre': nombres,
        'correo': emails,
        'direccion': direcciones
    }
    return pd.DataFrame(data)

# Generar Kioskos
def generate_kioskos(KIOSKOS):
    phone_numbers = generate_unique_phone_numbers(KIOSKOS)
    nombres = generate_sample_data(KIOSKOS, fake.company)
    direcciones = generate_sample_data(KIOSKOS, fake.address)
    data = {
        'id_kiosko': np.arange(1, KIOSKOS + 1),
        'nombre': nombres,
        'numero': phone_numbers,
        'direccion': direcciones
    }
    return pd.DataFrame(data)

# Generar Productos y sus subclases
def generate_productos(PRODUCTOS, proveedores_df):
    num_agua = PRODUCTOS // 3
    num_cervezas = PRODUCTOS // 3
    num_gaseosas = PRODUCTOS - num_agua - num_cervezas

    id_producto = np.arange(1, PRODUCTOS + 1)
    id_proveedor = np.random.choice(proveedores_df['id_proveedor'], size=PRODUCTOS)
    cantidades = np.random.randint(500, 1500, size=PRODUCTOS)
    precios = np.round(np.random.uniform(5.0, 20.0, size=PRODUCTOS), 2)

    marcas_agua = np.random.choice(["Cielo", "San Mateo", "San Luis", "Socosani", "Andea"], size=num_agua)
    marcas_cerveza = np.random.choice(["Cusqueña", "Pilsen", "Cristal", "Arequipeña", "Barena"], size=num_cervezas)
    marcas_gaseosa = np.random.choice(["Inca Kola", "Kola Real", "Coca Cola", "Pepsi", "Fanta"], size=num_gaseosas)

    productos_list = []
    agua_list = []
    cervezas_list = []
    gaseosas_list = []

    for i in range(PRODUCTOS):
        if i < num_agua:
            marca = marcas_agua[i]
            nombre = f"Agua {marca} {i+1}"
            descripcion = f"Agua mineral {marca} pura y refrescante"
            productos_list.append({
                'id_producto': id_producto[i],
                'id_proveedor': id_proveedor[i],
                'nombre': nombre,
                'marca': marca,
                'descripcion': descripcion,
                'cantidad': cantidades[i],
                'precio': precios[i]
            })
            agua_list.append({
                'id_producto': id_producto[i],
                'con_gas': np.random.choice([True, False])
            })
        elif i < num_agua + num_cervezas:
            idx = i - num_agua
            marca = marcas_cerveza[idx]
            nombre = f"Cerveza {marca} {i+1}"
            descripcion = f"Cerveza {marca}, calidad premium con sabor único"
            productos_list.append({
                'id_producto': id_producto[i],
                'id_proveedor': id_proveedor[i],
                'nombre': nombre,
                'marca': marca,
                'descripcion': descripcion,
                'cantidad': cantidades[i],
                'precio': precios[i]
            })
            cervezas_list.append({
                'id_producto': id_producto[i],
                'grados_alcohol': round(random.uniform(4.0, 12.0), 2)
            })
        else:
            idx = i - num_agua - num_cervezas
            marca = marcas_gaseosa[idx]
            nombre = f"Gaseosa {marca} {i+1}"
            descripcion = f"Gaseosa {marca} con sabor inconfundible y refrescante"
            productos_list.append({
                'id_producto': id_producto[i],
                'id_proveedor': id_proveedor[i],
                'nombre': nombre,
                'marca': marca,
                'descripcion': descripcion,
                'cantidad': cantidades[i],
                'precio': precios[i]
            })
            gaseosas_list.append({
                'id_producto': id_producto[i],
                'nivel_azucar': np.random.choice(['regular', 'light', 'zero'])
            })

    productos_df = pd.DataFrame(productos_list)
    agua_df = pd.DataFrame(agua_list)
    cervezas_df = pd.DataFrame(cervezas_list)
    gaseosas_df = pd.DataFrame(gaseosas_list)

    return productos_df, agua_df, cervezas_df, gaseosas_df

# Generar Pedidos y DetallesPedido
def generate_pedidos_y_detalles(PEDIDOS, productos_df, clientes_df):
    id_pedido = np.arange(1, PEDIDOS + 1)
    fechas = [fake.date_between(start_date="-2y", end_date="today") for _ in range(PEDIDOS)]
    estados_pedido = np.random.choice(['procesado', 'enviado', 'entregado'], size=PEDIDOS)
    pedidos_df = pd.DataFrame({
        'id_pedido': id_pedido,
        'total': 0.0,  # Se actualizará más tarde
        'fecha': fechas,
        'estado': estados_pedido
    })

    # Relación Hace
    hace_df = pd.DataFrame({
        'id_pedido': id_pedido,
        'id_cliente': np.random.choice(clientes_df['id_cliente'], size=PEDIDOS)
    })

    # Generar DetallesPedido
    detalles_pedido_list = []
    total_por_pedido = {}
    for pedido_id in id_pedido:
        num_detalles = random.randint(1, 5)
        productos_seleccionados = productos_df.sample(num_detalles)
        total_pedido = 0.0
        for _, producto in productos_seleccionados.iterrows():
            cantidad = random.randint(1, 10)
            precio_unitario = producto['precio']
            subtotal = cantidad * precio_unitario
            total_pedido += subtotal
            detalles_pedido_list.append({
                'id_detalle': pedido_id,  # Usamos pedido_id como id_detalle para simplificar
                'id_pedido': pedido_id,
                'id_producto': producto['id_producto'],
                'cantidad_solicitada': cantidad,
                'precio_unitario': precio_unitario
            })
        total_por_pedido[pedido_id] = total_pedido

    detalles_pedido_df = pd.DataFrame(detalles_pedido_list)

    # Actualizar total de cada pedido
    pedidos_df['total'] = pedidos_df['id_pedido'].map(total_por_pedido)

    # Reordenar las columnas según el orden deseado
    pedidos_df = pedidos_df[['id_pedido', 'total', 'fecha', 'estado']]

    return pedidos_df, detalles_pedido_df, hace_df

# Generar Pagos
def generate_pagos(PAGOS, pedidos_df):
    id_pago = np.arange(1, PAGOS + 1)
    pedidos_seleccionados = pedidos_df.sample(PAGOS, replace=True)
    montos = [random.uniform(1, pedido_total * 0.2) for pedido_total in pedidos_seleccionados['total']]
    fechas_pago = [fake.date_between(start_date=pedido_fecha, end_date="today") for pedido_fecha in pedidos_seleccionados['fecha']]
    metodos_pago = np.random.choice(['efectivo', 'tarjeta', 'transferencia'], size=PAGOS)
    estados_pago = ['pendiente'] * PAGOS
    pagos_df = pd.DataFrame({
        'id_pago': id_pago,
        'id_pedido': pedidos_seleccionados['id_pedido'].values,
        'monto': montos,
        'fecha': fechas_pago,
        'metodo_pago': metodos_pago,
        'estado': estados_pago
    })
    return pagos_df

# Generar Administra (Clientes -> Kioskos)
def generate_administra(kioskos_df, clientes_df):
    administra_df = pd.DataFrame({
        'id_kiosko': kioskos_df['id_kiosko'],
        'id_cliente': np.random.choice(clientes_df['id_cliente'], size=len(kioskos_df))
    })
    return administra_df

# Guardar en CSV
def save_to_csv(df, filename):
    folder = "datos"
    if not os.path.exists(folder):
        os.makedirs(folder)
    filepath = os.path.join(folder, filename)
    df.to_csv(filepath, index=False)
    print(f"{filepath} creado.")

# Ejecutar generación de datos
def main():
    print("Generando proveedores...")
    proveedores_df = generate_proveedores(PROVEEDORES)
    print("Generando clientes...")
    clientes_df = generate_clientes(CLIENTES)
    print("Generando kioskos...")
    kioskos_df = generate_kioskos(KIOSKOS)
    print("Generando productos...")
    productos_df, agua_df, cervezas_df, gaseosas_df = generate_productos(PRODUCTOS, proveedores_df)
    print("Generando pedidos y detalles de pedido...")
    pedidos_df, detalles_pedido_df, hace_df = generate_pedidos_y_detalles(PEDIDOS, productos_df, clientes_df)
    print("Generando pagos...")
    pagos_df = generate_pagos(PAGOS, pedidos_df)
    print("Generando relación administra...")
    administra_df = generate_administra(kioskos_df, clientes_df)

    # Guardar
    save_to_csv(proveedores_df, "proveedores.csv")
    save_to_csv(productos_df, "productos.csv")
    save_to_csv(agua_df, "agua.csv")
    save_to_csv(cervezas_df, "cervezas.csv")
    save_to_csv(gaseosas_df, "gaseosas.csv")
    save_to_csv(clientes_df, "clientes.csv")
    save_to_csv(kioskos_df, "kioskos.csv")
    save_to_csv(administra_df, "administra.csv")
    save_to_csv(pedidos_df, "pedidos.csv")
    save_to_csv(hace_df, "hace.csv")
    save_to_csv(detalles_pedido_df, "detalles_pedido.csv")
    save_to_csv(pagos_df, "pagos.csv")
    print("¡Datos generados y guardados exitosamente!")

if __name__ == "__main__":
    main()
