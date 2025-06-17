# BotonFinNivel.gd
extends Button

@export var escena_destino: PackedScene = preload("res://Escenas/Mapa/Mundo.tscn")

func _ready():
	# Conecta la señal "pressed" del botón a la función _on_button_pressed
	self.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	print("Botón 'FinNivel' presionado. Redirigiendo a Mapa/Mundo.tscn")
	# Verifica si la escena de destino es válida antes de intentar cambiar
	if escena_destino:
		get_tree().change_scene_to_packed(escena_destino)
	else:
		printerr("Error: La escena de destino no está asignada o no es válida.")
