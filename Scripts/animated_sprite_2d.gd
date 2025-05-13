extends CharacterBody2D # O KinematicBody2D

@onready var animated_sprite = get_node("AnimatedSprite2D")
@onready var carril_line_1 = get_node("../Carril 1") 
@onready var punto_inicio = get_node("../PuntosAparicion/Aparicion_Carril1")
@onready var punto_final = get_node("../Objetivos/Objetivo_Carril1")

var velocidad = 50.0
var en_movimiento = false

func _ready():
	if animated_sprite:
		animated_sprite.play("run")
		en_movimiento = true
		position = punto_inicio.position # Colocar al inicio del carril

func _physics_process(delta):
	if en_movimiento and animated_sprite and animated_sprite.animation == "run":
		# Movimiento lineal simple de izquierda a derecha
		var direccion = (punto_final.position - position).normalized()
		velocity = direccion * velocidad
		move_and_slide()

		# Detener al llegar al final (con una pequeña tolerancia)
		if position.distance_to(punto_final.position) < 5: # Ajusta la tolerancia
			en_movimiento = false
			animated_sprite.play("idle") # Cambiar a animación de reposo
