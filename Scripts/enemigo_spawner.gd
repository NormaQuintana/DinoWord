extends Node2D

@export var tiempo_de_aparicion = 3.0
@export var nodo_enemigo_original: CharacterBody2D 
@export var puntos_de_aparicion: Array[Marker2D]

var tiempo_transcurrido = 0.0
var cantidad_carriles = 0

func _ready():
	cantidad_carriles = puntos_de_aparicion.size()
	if cantidad_carriles == 0:
		printerr("¡Advertencia! No se han asignado puntos de aparición para los enemigos.")
	if not is_instance_valid(nodo_enemigo_original):
		printerr("¡Advertencia! No se ha asignado el nodo enemigo original.")

func _process(delta):
	tiempo_transcurrido += delta
	if tiempo_transcurrido >= tiempo_de_aparicion and is_instance_valid(nodo_enemigo_original) and cantidad_carriles > 0:
		_aparecer_enemigo()
		tiempo_transcurrido = 0.0

func _aparecer_enemigo():
	var indice_carril_aleatorio = randi_range(0, cantidad_carriles - 1)
	var punto_de_aparicion = puntos_de_aparicion[indice_carril_aleatorio]

	if is_instance_valid(punto_de_aparicion) and is_instance_valid(nodo_enemigo_original):
		var nuevo_enemigo = nodo_enemigo_original.duplicate()
		nuevo_enemigo.global_position = punto_de_aparicion.global_position
		get_parent().add_child(nuevo_enemigo)
