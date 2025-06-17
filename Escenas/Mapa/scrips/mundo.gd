extends Node3D

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
	   
		GlobalState.last_scene_path = "res://Escenas/Nivel_Casa.tscn"
		get_tree().change_scene_to_file("res://Escenas/vistaPotenciador.tscn")

func _on_cruce_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		# Guarda la ruta de la escena a la que quieres regresar/ir después de vistaPotenciador
		GlobalState.last_scene_path = "res://Escenas/Nivel_Casa.tscn"
		get_tree().change_scene_to_file("res://Escenas/vistaPotenciador.tscn")

func _on_escuela_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		# Guarda la ruta de la escena a la que quieres regresar/ir después de vistaPotenciador
		GlobalState.last_scene_path = "res://Escenas/Nivel_Escuela.tscn" # Asegúrate de que esta sea la ruta correcta para Nivel_Escuela
		get_tree().change_scene_to_file("res://Escenas/vistaPotenciador.tscn")
