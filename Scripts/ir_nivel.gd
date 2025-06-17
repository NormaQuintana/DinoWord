extends Button

# Ya no necesitamos @export var escena_del_nivel: PackedScene = ... aquí.
# La escena se obtendrá del estado global.

func _ready():
	self.pressed.connect(_on_ir_nivel_pressed)
	# Opcional: Para depuración, puedes imprimir el valor al cargar la vista
	print("vistaPotenciador: El botón 'Ir Nivel' intentará ir a: ", GlobalState.last_scene_path)

func _on_ir_nivel_pressed():
	if GlobalState.last_scene_path:
		print("Botón 'Ir Nivel' presionado. Cargando nivel desde: ", GlobalState.last_scene_path)
		var next_scene_path = GlobalState.last_scene_path
		# Limpia la variable global después de usarla para evitar comportamientos inesperados
		# si el jugador entra a la vista del potenciador de otra forma.
		GlobalState.last_scene_path = "" 
		
		# Carga la escena dinámicamente.
		# Es mejor usar 'change_scene_to_file' con la ruta de string
		# o precargarla si es una escena que se carga con frecuencia.
		# Para este caso, con la ruta de string, 'change_scene_to_file' es adecuado.
		get_tree().change_scene_to_file(next_scene_path)
	else:
		printerr("Error: No se ha establecido una ruta de nivel en GlobalState. Volviendo a una escena por defecto o mostrando un mensaje.")
		# Opcional: Redirigir a una escena por defecto si no hay una ruta guardada
		# get_tree().change_scene_to_file("res://Escenas/MenuPrincipal.tscn")
