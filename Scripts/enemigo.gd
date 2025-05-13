extends CharacterBody2D

@onready var animated_sprite = get_node("AnimatedSprite2D")
@onready var barra_de_vida_container = get_node("SubViewportContainer")
@onready var barra_de_vida = barra_de_vida_container.get_node("SubViewport/BarraDeVidaCanvas/BarraDeVida")

enum State {
	RUNNING,
	HURT,
	IDLE,
	DEAD,
	BITING # Nuevo estado para atacar el huevo
}

@export var velocidad = 70.0
var en_movimiento = true
var en_contacto_con_dinosaurio = false
var en_contacto_con_huevo = false # Nueva variable para el contacto con el huevo
var direccion = Vector2.LEFT
var estado = State.RUNNING
@export var vida = 100
@export var daño_por_segundo = 10 # Valor por defecto, será sobrescrito

var dinosaurio_manager
var huevo_objetivo # Referencia al huevo que está atacando
var huevo_roto = false # Nueva variable para indicar si el huevo fue roto

func _ready():
	var posibles_daños = [10, 15, 20]
	daño_por_segundo = posibles_daños[randi_range(0, posibles_daños.size() - 1)]
	print("Enemigo creado con daño:", daño_por_segundo)

	dinosaurio_manager = get_node_or_null("../DinosaurioManager")
	if not is_instance_valid(dinosaurio_manager):
		printerr("Error: No se encontró el nodo DinosaurioManager.")

	if animated_sprite:
		animated_sprite.play("move")
		animated_sprite.flip_h = true
		estado = State.RUNNING
	if barra_de_vida:
		barra_de_vida.max_value = vida
		barra_de_vida.value = vida

func _physics_process(delta):
	match estado:
		State.RUNNING:
			if en_movimiento and animated_sprite and animated_sprite.animation == "move":
				velocity = direccion * velocidad
				var collision_info = move_and_collide(velocity * delta)
				if collision_info and collision_info.get_collider() is CharacterBody2D:
					if dinosaurio_manager and collision_info.get_collider() in dinosaurio_manager.obtener_dinosaurios():
						en_contacto_con_dinosaurio = true
						animated_sprite.play("hurt")
						estado = State.HURT
					elif collision_info.get_collider().has_method("_romper_huevo"):
						velocity = Vector2.ZERO # Detener al enemigo al llegar al huevo
						estado = State.BITING # Cambiar al estado de ataque al huevo
						animated_sprite.play("bite") # Reproducir la animación de ataque
						huevo_objetivo = collision_info.get_collider() # Guardar referencia al huevo
						en_contacto_con_huevo = true
						huevo_roto = false # Reiniciar la bandera al iniciar el ataque
			else:
				animated_sprite.play("idle")
				estado = State.IDLE
		State.HURT:
			velocity = Vector2.ZERO
			if en_contacto_con_dinosaurio:
				vida -= daño_por_segundo * delta
				if barra_de_vida:
					barra_de_vida.value = vida
				if vida <= 0:
					_morir()
			else:
				animated_sprite.play("idle")
				estado = State.IDLE
		State.BITING:
			velocity = Vector2.ZERO
			animated_sprite.play("bite")
			if is_instance_valid(huevo_objetivo): # Verificar si el huevo objetivo sigue siendo válido
				if en_contacto_con_huevo:
					huevo_objetivo.vida -= daño_por_segundo * delta
					if is_instance_valid(huevo_objetivo.barra_de_vida):
						huevo_objetivo.barra_de_vida.value = huevo_objetivo.vida
					if huevo_objetivo.vida <= 0 and not huevo_roto:
						huevo_objetivo._romper_huevo()
						huevo_roto = true # Marcar el huevo como roto para la transición
				elif huevo_roto:
					estado = State.RUNNING # Volver a correr después de que el huevo fue roto
			else:
				estado = State.RUNNING # Si el huevo objetivo ya no es válido
		State.IDLE:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
		State.DEAD:
			velocity = Vector2.ZERO
			animated_sprite.play("dead")
			set_physics_process(false)
			set_process(false)
			queue_free()

func _morir():
	estado = State.DEAD
	set_physics_process(false)
	set_process(false)
	queue_free()

func obtener_daño():
	return daño_por_segundo
