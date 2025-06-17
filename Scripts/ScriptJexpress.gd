extends Node2D

# firebase

var uid = "demo_uid123"  # Puedes cambiarlo luego por un UID real si usas login
var botones_desbloqueados = {}
var firebase_url = "https://tessara-32078-default-rtdb.firebaseio.com/usuarios/%s/enciclopedia/locacion/JoselineExpress.json" % uid

# Stuff

var info_objetos = {
	"Button": {
		"texto": "cash register",
		"Traduccion": "caja registradora",
		"imagen": preload("res://src/enciclopedia/part-Slice 76.png")
	},
	"Button2": {
		"texto": "Recipe",
		"Traduccion": "Recibo",
		"imagen": preload("res://src/enciclopedia/part-Slice 194.png")
	},
	"Button3": {
		"texto": "Cashier",
		"Traduccion": "Cajero/a",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
	"Button4": {
		"texto": "Customer",
		"Traduccion": "Cliente",
		"imagen": preload("res://src/enciclopedia/part-Slice 76.png")
	},
	"Button5": {
		"texto": "Shell",
		"Traduccion": "Estante",
		"imagen": preload("res://src/enciclopedia/Shell.png")
	},
	"Button6": {
		"texto": "Aisle",
		"Traduccion": "Pasillo",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
	"Button7": {
		"texto": "Cart",
		"Traduccion": "Carrito",
		"imagen": preload("res://src/enciclopedia/part-Slice 76.png")
	},
	"Button8": {
		"texto": "Offer",
		"Traduccion": "Oferta",
		"imagen": preload("res://src/enciclopedia/part-Slice 194.png")
	},
	"Button9": {
		"texto": "Barcode",
		"Traduccion": "Codigo de barras",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
	"Button10": {
		"texto": "Bag",
		"Traduccion": "Bolsa",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
	"Button11": {
		"texto": "Where is the restroom?",
		"Traduccion": "¿Dónde está el baño?",
		"imagen": preload("res://src/enciclopedia/part-Slice 76.png")
	},
	"Button12": {
		"texto": "Can i see your ID? ",
		"Traduccion": "¿Puedo ver su identificación?",
		"imagen": preload("res://src/enciclopedia/part-Slice 194.png")
	},
	"Button13": {
		"texto": "How much does this cost?",
		"Traduccion": "¿Cuánto cuesta esto?",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
	"Button14": {
		"texto": "Do you have this [product] in stock?",
		"Traduccion": "¿Tiene [producto] en existencia?",
		"imagen": preload("res://src/enciclopedia/part-Slice 76.png")
	},
	"Button15": {
		"texto": "Dou you need the receipt?",
		"Traduccion": "¿Necesita el recibo?",
		"imagen": preload("res://src/enciclopedia/Shell.png")
	},
	"Button16": {
		"texto": "Would you like a bag?",
		"Traduccion": "¿Le gustaría una bolsa?",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
	"Button17": {
		"texto": "did you accept credit cards?",
		"Traduccion": "¿Aceptan tarjeta?",
		"imagen": preload("res://src/enciclopedia/part-Slice 76.png")
	},
	"Button18": {
		"texto": "Where i can find [product]?",
		"Traduccion": "¿Dónde puedo encontrar [producto]?",
		"imagen": preload("res://src/enciclopedia/part-Slice 194.png")
	},
	"Button19": {
		"texto": "What is the total?",
		"Traduccion": "¿Cuál es el total?",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
	"Button20": {
		"texto": "At what time do you close?",
		"Traduccion": "¿A qué hora cierran?",
		"imagen": preload("res://src/enciclopedia/part-Slice 158.png")
	},
}

func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)

	# Cargar datos desde Firebase
	$HTTPRequest.request(firebase_url)
	
	$Panel6/BotonMagico.pressed.connect(func(): guardar_estado_boton("Button", true))

	$Panel6/ButtonBack.pressed.connect(_on_button_back_pressed)
	
	# Conecta todos los botones automáticamente
	for nombre in info_objetos.keys():
		var boton = $Panel6.get_node(nombre)
		boton.pressed.connect(func(): mostrar_info(nombre))
		

func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://Escenas/node_2d.tscn")
	
func mostrar_info(nombre: String):
	var datos = info_objetos.get(nombre)
	if datos:
		$Panel6/Panel.visible = true
		$Panel6/Panel/Label.text = datos["texto"]
		$Panel6/Panel/LabelTraduccion.text = datos["Traduccion"]
		$Panel6/Panel/Sprite2D.texture = datos["imagen"]
		
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json:
			botones_desbloqueados = json
			actualizar_estado_botones()
	else:
		print("Error al cargar datos de Firebase:", response_code)

func actualizar_estado_botones():
	for nombre in info_objetos.keys():
		var boton = $Panel6.get_node(nombre)
		var desbloqueado = botones_desbloqueados.get(nombre, 0)
		boton.visible = desbloqueado == 1

# para pruebas

func guardar_estado_boton(nombre_boton: String, desbloqueado: bool):
	var data = {}
	if desbloqueado:
		data[nombre_boton] = 1
	else:
		data[nombre_boton] = 0

	var json_body = JSON.stringify(data)

	$HTTPRequest.request(
		firebase_url,
		["Content-Type: application/json"],
		HTTPClient.METHOD_PATCH,
		json_body
	)
