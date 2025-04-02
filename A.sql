import flet as ft
import mysql.connector

# Configurar la conexión a la base de datos
conn = mysql.connector.connect(
    host="localhost",
    user="tu_usuario",
    password="tu_contraseña",
    database="tu_base_de_datos"
)
cursor = conn.cursor()

def main(page: ft.Page):
    page.title = "Sistema POS - El Negrito"
    page.theme_mode = ft.ThemeMode.LIGHT

    cliente_list = ft.ListView()
    empleado_list = ft.ListView()

    def fetch_clients():
        cursor.execute("SELECT id, nombre, telefono, email, direccion FROM clientes")
        return cursor.fetchall()
    
    def fetch_employees():
        cursor.execute("SELECT id, nombre, puesto, telefono, email, fecha FROM empleados")
        return cursor.fetchall()

    def update_client_list():
        cliente_list.controls.clear()
        for cliente in fetch_clients():
            cliente_list.controls.append(
                ft.Row([
                    ft.Text(cliente[1]),
                    ft.Text(cliente[2]),
                    ft.Text(cliente[3]),
                    ft.Text(cliente[4]),
                    ft.IconButton(ft.icons.EDIT, on_click=lambda e, id=cliente[0]: edit_cliente(id)),
                    ft.IconButton(ft.icons.DELETE, on_click=lambda e, id=cliente[0]: delete_cliente(id))
                ])
            )
        page.update()
    
    def add_cliente(e):
        cursor.execute("INSERT INTO clientes (nombre, telefono, email, direccion) VALUES (%s, %s, %s, %s)",
                       (nombre_cliente.value, telefono_cliente.value, email_cliente.value, direccion_cliente.value))
        conn.commit()
        clear_cliente_fields()
        update_client_list()
    
    def edit_cliente(id):
        cursor.execute("SELECT nombre, telefono, email, direccion FROM clientes WHERE id = %s", (id,))
        cliente = cursor.fetchone()
        nombre_cliente.value, telefono_cliente.value, email_cliente.value, direccion_cliente.value = cliente
        page.update()
        btn_add_cliente.text = "Actualizar Cliente"
        btn_add_cliente.on_click = lambda e: update_cliente(id)
        page.update()
    
    def update_cliente(id):
        cursor.execute("UPDATE clientes SET nombre=%s, telefono=%s, email=%s, direccion=%s WHERE id=%s",
                       (nombre_cliente.value, telefono_cliente.value, email_cliente.value, direccion_cliente.value, id))
        conn.commit()
        clear_cliente_fields()
        btn_add_cliente.text = "Agregar Cliente"
        btn_add_cliente.on_click = add_cliente
        update_client_list()
    
    def delete_cliente(id):
        cursor.execute("DELETE FROM clientes WHERE id = %s", (id,))
        conn.commit()
        update_client_list()
    
    def clear_cliente_fields():
        nombre_cliente.value = ""
        telefono_cliente.value = ""
        email_cliente.value = ""
        direccion_cliente.value = ""
        page.update()
    
    nombre_cliente = ft.TextField(label="Nombre")
    telefono_cliente = ft.TextField(label="Teléfono")
    email_cliente = ft.TextField(label="Email")
    direccion_cliente = ft.TextField(label="Dirección")
    btn_add_cliente = ft.ElevatedButton("Agregar Cliente", on_click=add_cliente)
    
    cliente_form = ft.Column([
        ft.Text("Agregar Cliente", size=20, weight=ft.FontWeight.BOLD),
        nombre_cliente, telefono_cliente, email_cliente, direccion_cliente, btn_add_cliente, cliente_list
    ])
    
    def update_employee_list():
        empleado_list.controls.clear()
        for empleado in fetch_employees():
            empleado_list.controls.append(
                ft.Row([
                    ft.Text(empleado[1]),
                    ft.Text(empleado[2]),
                    ft.Text(empleado[3]),
                    ft.Text(empleado[4]),
                    ft.Text(empleado[5]),
                    ft.IconButton(ft.icons.EDIT, on_click=lambda e, id=empleado[0]: edit_empleado(id)),
                    ft.IconButton(ft.icons.DELETE, on_click=lambda e, id=empleado[0]: delete_empleado(id))
                ])
            )
        page.update()
    
    def add_empleado(e):
        cursor.execute("INSERT INTO empleados (nombre, puesto, telefono, email, fecha) VALUES (%s, %s, %s, %s, %s)",
                       (nombre_empleado.value, puesto_empleado.value, telefono_empleado.value, email_empleado.value, fecha_contratacion.value))
        conn.commit()
        clear_empleado_fields()
        update_employee_list()
    
    def edit_empleado(id):
        cursor.execute("SELECT nombre, puesto, telefono, email, fecha FROM empleados WHERE id = %s", (id,))
        empleado = cursor.fetchone()
        nombre_empleado.value, puesto_empleado.value, telefono_empleado.value, email_empleado.value, fecha_contratacion.value = empleado
        page.update()
        btn_add_empleado.text = "Actualizar Empleado"
        btn_add_empleado.on_click = lambda e: update_empleado(id)
        page.update()
    
    def update_empleado(id):
        cursor.execute("UPDATE empleados SET nombre=%s, puesto=%s, telefono=%s, email=%s, fecha=%s WHERE id=%s",
                       (nombre_empleado.value, puesto_empleado.value, telefono_empleado.value, email_empleado.value, fecha_contratacion.value, id))
        conn.commit()
        clear_empleado_fields()
        btn_add_empleado.text = "Agregar Empleado"
        btn_add_empleado.on_click = add_empleado
        update_employee_list()
    
    def delete_empleado(id):
        cursor.execute("DELETE FROM empleados WHERE id = %s", (id,))
        conn.commit()
        update_employee_list()
    
    tabs = ft.Tabs(selected_index=0, tabs=[ft.Tab(text="Clientes", content=cliente_form), ft.Tab(text="Empleados", content=empleado_form)])
    page.add(tabs)

ft.app(target=main)

