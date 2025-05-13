extends Node2D

@onready var back_button = $BackButton

# Variable para almacenar el área del botón
var button_rect: Rect2

func _ready():
	# Esperar un frame para asegurarse de que el botón esté inicializado
	await get_tree().process_frame
	# Obtener el rectángulo del botón (área clickeable)
	button_rect = Rect2(back_button.global_position, back_button.size)
	print("Área del botón inicializada:", button_rect)

func _input(event):
	# Para pantallas táctiles (móviles)
	if event is InputEventScreenTouch and event.pressed:
		if button_rect.has_point(event.position):
			print("Botón tocado (pantalla táctil)")
			get_tree().change_scene_to_file("res://Mundo.tscn")
	
	# Para clics de ratón (PC)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if button_rect.has_point(event.position):
			print("Botón clicado (ratón)")
			get_tree().change_scene_to_file("res://Mundo.tscn")
