extends Node2D


# Diccionario con info por botón
var info_objetos = {
	"Button": {
		"texto": "Sofa",
		"descripcion": "Este sofa es muy comodo y morado.",
		"imagen": preload("res://src/enciclopedia/part-Slice 76.png")
	},
	"Button2": {
		"texto": "Refrigerador",
		"descripcion": "Esta refri es color fresa.",
		"imagen": preload("res://src/enciclopedia/part-Slice 194.png")
	},
	"Button3": {
		"texto": "Cama",
		"descripcion": "A mimir....",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
}


func _ready():
	$Panel2/ButtonBack.pressed.connect(_on_button_back_pressed)
	$Panel2/ButtonAfterPage.pressed.connect(_on_button_after_pressed)
	
	# Conecta todos los botones automáticamente
	for nombre in info_objetos.keys():
		var boton = $Panel2.get_node(nombre)
		boton.pressed.connect(func(): mostrar_info(nombre))
		

func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://Escenas/node_2d.tscn")

func _on_button_after_pressed():
	get_tree().change_scene_to_file("res://Escenas/enciclopediaCasa2.tscn")

func mostrar_info(nombre: String):
	var datos = info_objetos.get(nombre)
	if datos:
		$Panel2/Panel.visible = true
		$Panel2/Panel/Label.text = datos["texto"]
		$Panel2/Panel/LabelDescription.text = datos["descripcion"]
		$Panel2/Panel/Sprite2D.texture = datos["imagen"]
