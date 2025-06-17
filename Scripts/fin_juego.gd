# finjuego.gd
extends Node2D

@onready var game_over_label: Label = $"Panel/Label" # Ajusta la ruta si está anidado
@onready var try_again_button: Button = $"Panel/Button" # Ajusta la ruta si está anidado

func _ready():
	# Opcional: Pausar el juego si no lo despausaste antes de cambiar de escena
	# get_tree().paused = true # Si no despausaste en nivel_casa.gd

	# Conectar las señales de los botones
	try_again_button.pressed.connect(_on_try_again_button_pressed)

	# Opcional: Mostrar la puntuación final si la pasas o la obtienes de un Global Singleton
	# game_over_label.text = "¡GAME OVER!\nPuntuación: " + str(GlobalData.final_score) 
	# (Necesitarías pasar el score o guardarlo en GlobalData antes de cambiar de escena)

func _on_try_again_button_pressed():
	get_tree().paused = false # Despausar el juego
	# Vuelve a cargar la escena de tu nivel principal (nivel_casa.tscn)
	# Asegúrate de que esta ruta sea la correcta de tu escena de nivel.
	get_tree().change_scene_to_file("res://Escenas/Nivel_Casa.tscn") # ¡¡¡CAMBIA ESTA RUTA!!!
