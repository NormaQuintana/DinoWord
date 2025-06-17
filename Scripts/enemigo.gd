# dinosaurio.gd (o el script de tu enemigo)
extends CharacterBody2D

signal enemigo_destruido # Señal para notificar al spawner cuando este enemigo es destruido

@onready var animated_sprite = get_node("AnimatedSprite2D")
@onready var barra_de_vida_container = get_node("SubViewportContainer")
@onready var barra_de_vida = barra_de_vida_container.get_node("SubViewport/BarraDeVidaCanvas/BarraDeVida")

enum State {
	RUNNING,
	HURT,
	IDLE,
	DEAD,
	BITING 
}

@export var velocidad = 70.0
var en_movimiento = true
var en_contacto_con_dinosaurio = false
var en_contacto_con_huevo = false # Nueva variable para el contacto con el huevo
var direccion = Vector2.LEFT
var estado = State.RUNNING
@export var vida = 100
@export var daño_por_segundo = 50 # Valor por defecto, será sobrescrito

var dinosaurio_manager
var huevo_objetivo # Referencia al huevo que está atacando
var huevo_roto = false # Nueva variable para indicar si el huevo fue roto

func _ready():
	add_to_group("enemigos")

	dinosaurio_manager = $"../DinosaurioManager" 
	if not is_instance_valid(dinosaurio_manager):
		printerr("Error: No se encontró el nodo DinosaurioManager. Asegúrate de que la ruta sea correcta.")

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
				animated_sprite.play("move")
				estado = State.RUNNING
		State.HURT:
			velocity = Vector2.ZERO
			if en_contacto_con_dinosaurio:
				vida -= daño_por_segundo * delta
				if barra_de_vida:
					barra_de_vida.value = vida
				if vida <= 0:
					_morir() # Llama a _morir() para la destrucción
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
					estado = State.RUNNING 
			else:
				estado = State.RUNNING 
		State.IDLE:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
		State.DEAD:
			# El estado DEAD solo se encarga de la animación final. La eliminación se hace en _morir().
			velocity = Vector2.ZERO
			animated_sprite.play("dead") 
			# No hacemos queue_free() aquí directamente para asegurar la señal se emita en _morir().

func _morir():
	print("Enemigo muriendo.") # Para depuración
	estado = State.DEAD
	set_physics_process(false) # Detiene el movimiento y la lógica de física
	set_process(false)         # Detiene el _process general del nodo
	
	enemigo_destruido.emit() # Emitir la señal ANTES de liberar el nodo
	
	queue_free() # Libera el nodo del enemigo de la memoria


func obtener_daño():
	return daño_por_segundo
