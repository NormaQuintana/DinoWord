extends Node2D

@export var casa_scene: PackedScene
@export var office_scene: PackedScene
@export var school_scene: PackedScene
@export var cafeteria_scene: PackedScene
@export var crosswalk_scene: PackedScene
@export var jexpress_scene: PackedScene

func _ready():
	$Panel/ButtonCasa.pressed.connect(_on_button_casa_pressed)
	$Panel/ButtonOffice.pressed.connect(_on_button_office_pressed)
	$Panel/ButtonSchool.pressed.connect(_on_button_school_pressed)
	$Panel/ButtonCafeteria.pressed.connect(_on_button_cafeteria_pressed)
	$Panel/ButtonCrosswalk.pressed.connect(_on_button_crosswalk_pressed)
	$Panel/ButtonJExpress.pressed.connect(_on_button_jexpress_pressed)

func _on_button_casa_pressed():
	get_tree().change_scene_to_packed(casa_scene)

func _on_button_office_pressed():
	get_tree().change_scene_to_packed(office_scene)

func _on_button_school_pressed():
	get_tree().change_scene_to_packed(school_scene)

func _on_button_cafeteria_pressed():
	get_tree().change_scene_to_packed(cafeteria_scene)

func _on_button_crosswalk_pressed():
	get_tree().change_scene_to_packed(crosswalk_scene)

func _on_button_jexpress_pressed():
	get_tree().change_scene_to_packed(jexpress_scene)
