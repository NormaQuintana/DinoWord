extends Node2D

func _ready():
	$Panel2/ButtonBack.pressed.connect(_on_button_back_pressed)
	$Panel2/ButtonBeforePage.pressed.connect(_on_button_before_pressed)


func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://Escenas/node_2d.tscn")
	
func _on_button_before_pressed():
	get_tree().change_scene_to_file("res://Escenas/enciclopediaCasa.tscn")
