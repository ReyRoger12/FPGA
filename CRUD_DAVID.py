import flet as ft
import mysql.connector

db_config = {
    "host": "192.168.100.79",
    "user": "root",
    "password": "Fmsinter2",
    "database": "db_taller"
}

def get_connection():
    return mysql.connector.connect(**db_config)

def obtener_datos(tabla):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(f"SELECT * FROM {tabla}")
    datos = cursor.fetchall()
    cursor.close()
    conn.close()
    return datos

def insertar_dato(tabla, datos):
    conn = get_connection()
    cursor = conn.cursor()
    columnas = ", ".join(datos.keys())
    valores = ", ".join(["%s"] * len(datos))
    sql = f"INSERT INTO {tabla} ({columnas}) VALUES ({valores})"
    cursor.execute(sql, list(datos.values()))
    conn.commit()
    cursor.close()
    conn.close()

def actualizar_dato(tabla, id_valor, datos):
    conn = get_connection()
    cursor = conn.cursor()
    asignaciones = ", ".join([f"{col}=%s" for col in datos.keys()])
    sql = f"UPDATE {tabla} SET {asignaciones} WHERE id=%s"
    valores = list(datos.values()) + [id_valor]
    cursor.execute(sql, valores)
    conn.commit()
    cursor.close()
    conn.close()

def eliminar_dato(tabla, id_valor):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(f"DELETE FROM {tabla} WHERE id = %s", (id_valor,))
    conn.commit()
    cursor.close()
    conn.close()

def main(page: ft.Page):
    page.title = "POS El Negrito - Catálogos"
    page.window_maximized = True

    def crear_tab_panel(nombre_tabla, nombre_sql, campos, campos_especiales=None, mostrar_relacion=None):
        campos_especiales = campos_especiales or {}
        campos_inputs = []
        id_actualizando = ft.Ref[int]()

        for campo in campos:
            if campo in campos_especiales:
                campos_inputs.append(campos_especiales[campo])
            else:
                campos_inputs.append(ft.TextField(label=campo, expand=True))

        def limpiar():
            for ctrl in campos_inputs:
                ctrl.value = ""
            id_actualizando.current = None
            btn_guardar.text = "Agregar"
            tabla.rows.clear()
            cargar_tabla()
            page.update()

        def guardar(e):
            datos = {campo: ctrl.value for campo, ctrl in zip(campos, campos_inputs)}
            if id_actualizando.current is None:
                insertar_dato(nombre_sql, datos)
            else:
                actualizar_dato(nombre_sql, id_actualizando.current, datos)
            limpiar()

        def cargar_tabla():
            registros = obtener_datos(nombre_sql)
            for item in registros:
                fila = [ft.DataCell(ft.Text(str(item.get("id", ""))))]
                for campo in campos:
                    valor = item.get(campo, "")
                    if mostrar_relacion and campo in mostrar_relacion:
                        valor = mostrar_relacion[campo](valor)
                    fila.append(ft.DataCell(ft.Text(str(valor))))
                fila.append(
                    ft.DataCell(
                        ft.Row([
                            ft.IconButton(ft.icons.EDIT, tooltip="Editar", on_click=lambda e, i=item: editar(i)),
                            ft.IconButton(ft.icons.DELETE, tooltip="Eliminar", on_click=lambda e, i=item: (eliminar_dato(nombre_sql, i["id"]), limpiar()))
                        ])
                    )
                )
                tabla.rows.append(ft.DataRow(cells=fila))
            page.update()

        def editar(item):
            for campo, ctrl in zip(campos, campos_inputs):
                ctrl.value = item[campo]
            id_actualizando.current = item["id"]
            btn_guardar.text = "Actualizar"
            page.update()

        btn_guardar = ft.FilledButton("Agregar", icon=ft.icons.SAVE, on_click=guardar)
        tabla = ft.DataTable(
            columns=[ft.DataColumn(ft.Text("ID"))] + [ft.DataColumn(ft.Text(c)) for c in campos] + [ft.DataColumn(ft.Text("Acciones"))],
            rows=[],
            expand=True
        )

        cargar_tabla()

        return ft.Container(
            padding=20,
            content=ft.Column([
                ft.Text(nombre_tabla, size=24, weight=ft.FontWeight.BOLD),
                ft.ResponsiveRow(
                    controls=[ft.Container(ctrl, col={"md": 4}) for ctrl in campos_inputs],
                    spacing=10
                ),
                btn_guardar,
                ft.Divider(),
                tabla
            ], scroll=ft.ScrollMode.ADAPTIVE)
        )

    def tab_categoria():
        estado = ft.Dropdown(
            label="Estado",
            options=[ft.dropdown.Option("Activo"), ft.dropdown.Option("Inactivo")]
        )
        return crear_tab_panel("Categorías", "categorias", ["Nombre", "Descripción", "Fecha_creacion", "Estado"], {"Estado": estado})

    def tab_articulo():
        categorias = obtener_datos("categorias")
        cat_dropdown = ft.Dropdown(
            label="CategoriaID",
            options=[ft.dropdown.Option(str(c["id"]), c["Nombre"]) for c in categorias]
        )
        disponible = ft.Dropdown(
            label="Disponible",
            options=[ft.dropdown.Option("Sí"), ft.dropdown.Option("No")]
        )

        def mostrar_nombre(id):
            for c in categorias:
                if str(c["id"]) == str(id):
                    return c["Nombre"]
            return "Desconocida"

        return crear_tab_panel(
            "Artículos",
            "articulos",
            ["Nombre", "Precio", "Stock", "Codigo", "Unidad", "Disponible", "CategoriaID"],
            {"Disponible": disponible, "CategoriaID": cat_dropdown},
            {"CategoriaID": mostrar_nombre}
        )

    def tab_cliente():
        return crear_tab_panel("Clientes", "clientes", ["Nombre", "Telefono", "Correo", "Direccion", "RFC", "Fecha_registro"])

    def tab_empleado():
        activo = ft.Dropdown(
            label="Activo",
            options=[ft.dropdown.Option("Sí"), ft.dropdown.Option("No")]
        )
        return crear_tab_panel("Empleados", "empleados", ["Nombre", "Puesto", "Salario", "Direccion", "Fecha_ingreso", "Activo"], {"Activo": activo})

    tabs = ft.Tabs(
        expand=True,
        selected_index=0,
        animation_duration=300,
        tabs=[
            ft.Tab(text="Categorías", content=tab_categoria()),
            ft.Tab(text="Artículos", content=tab_articulo()),
            ft.Tab(text="Clientes", content=tab_cliente()),
            ft.Tab(text="Empleados", content=tab_empleado()),
        ]
    )

    page.add(
        ft.Column([
            ft.Container(
                content=ft.Text("El Negrito - Sistema de Gestión", size=30, weight=ft.FontWeight.BOLD),
                padding=20,
                alignment=ft.alignment.center
            ),
            tabs
        ])
    )

ft.app(target=main)
