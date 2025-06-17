extends ConfirmationDialog

func _ready() -> void:
	visible = false  # para que el cuadro de diálogo inicie oculto

	# Personalizar título y mensaje
	title = "Saldrás al mapa"
	dialog_text = "¿Estás seguro?"

	# Personalizar botones
	if has_method("get_ok_button"):
		get_ok_button().text = "Sí, salir"
	if has_method("get_cancel_button"):
		get_cancel_button().text = "No, quedarse"

	# Cambiar estilo (opcional)
	add_theme_color_override("panel", Color(0.1, 0.1, 0.1, 0.8))  # Fondo oscuro
	add_theme_color_override("font_color", Color(1, 1, 1))  # Texto blanco

func show_dialog() -> void:
	self.show()  # Muestra el diálogo

func _on_confirmed() -> void:
	get_tree().change_scene_to_file("res://Escenas/Mapa/Mundo.tscn")  # Cambia a la pantalla del mapa
