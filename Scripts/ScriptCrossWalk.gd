extends Node2D

func _ready():
	$Panel4/ButtonBack.pressed.connect(_on_button_back_pressed)

func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://Escenas/node_2d.tscn")
