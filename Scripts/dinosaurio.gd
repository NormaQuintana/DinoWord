extends CharacterBody2D

@onready var animated_sprite = get_node("AnimatedSprite2D")
@onready var barra_de_vida_container = get_node("SubViewportContainer")
@onready var barra_de_vida = barra_de_vida_container.get_node("SubViewport/BarraDeVidaCanvas/BarraDeVida")

enum State {
	RUNNING,
	HURT,
	IDLE,
	DEAD
}

var velocidad = 50.0
var en_movimiento = true
var en_contacto_con_enemigo = false
var direccion = Vector2.RIGHT
var estado = State.RUNNING
var vida = 100
var daño_por_segundo = 5

func _ready():
	if animated_sprite:
		animated_sprite.play("run")
		estado = State.RUNNING
	if barra_de_vida:
		barra_de_vida.max_value = vida
		barra_de_vida.value = vida

func _physics_process(delta):
	match estado:
		State.RUNNING:
			if en_movimiento and animated_sprite and animated_sprite.animation == "run":
				velocity = direccion * velocidad
				var collision_info = move_and_collide(velocity * delta)
				if collision_info and collision_info.get_collider() is CharacterBody2D and collision_info.get_collider().name == "Enemigo":
					en_contacto_con_enemigo = true
					animated_sprite.play("Hurt")
					estado = State.HURT
				else:
					en_contacto_con_enemigo = false
			else:
				animated_sprite.play("idle")
				estado = State.IDLE
		State.HURT:
			velocity = Vector2.ZERO
			if en_contacto_con_enemigo:
				vida -= daño_por_segundo * delta
				if barra_de_vida:
					barra_de_vida.value = vida
				var enemigo = get_node_or_null("../Enemigo")
				if is_instance_valid(enemigo) and enemigo.vida <= 0:
					en_contacto_con_enemigo = false
					animated_sprite.play("run")
					estado = State.RUNNING
				elif not is_instance_valid(enemigo):
					en_contacto_con_enemigo = false
					animated_sprite.play("run")
					estado = State.RUNNING
				elif vida <= 0:
					_morir()
			else:
				animated_sprite.play("idle")
				estado = State.IDLE
		State.IDLE:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
		State.DEAD:
			velocity = Vector2.ZERO
			animated_sprite.play("Death")
			set_physics_process(false)
			set_process(false)
			queue_free()

func _morir():
	estado = State.DEAD
	set_physics_process(false)
	set_process(false)
	queue_free()
