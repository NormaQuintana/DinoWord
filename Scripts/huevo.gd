extends CharacterBody2D

@onready var animated_sprite = get_node("AnimatedSprite2D")
@onready var barra_de_vida_container = get_node("SubViewportContainer")
@onready var barra_de_vida = barra_de_vida_container.get_node("SubViewport/BarraDeVidaCanvas/BarraDeVida")

var vida = 100
var en_contacto_con_enemigo = false
var daño_recibido_por_segundo = 0

func _ready():
	if animated_sprite:
		animated_sprite.play("idle")
	if barra_de_vida:
		barra_de_vida.max_value = vida
		barra_de_vida.value = vida

func _physics_process(delta):
	if en_contacto_con_enemigo:
		vida -= daño_recibido_por_segundo * delta
		if barra_de_vida:
			barra_de_vida.value = vida
		if vida <= 0:
			_romper_huevo()

func _on_body_entered(body):
	if body is CharacterBody2D and body.has_method("obtener_daño"):
		en_contacto_con_enemigo = true
		daño_recibido_por_segundo = body.obtener_daño()
		print("Huevo en contacto con enemigo. Daño:", daño_recibido_por_segundo)

func _on_body_exited(body):
	if body is CharacterBody2D and body.has_method("obtener_daño"):
		en_contacto_con_enemigo = false
		daño_recibido_por_segundo = 0
		print("Huevo dejó de estar en contacto con el enemigo.")

func _romper_huevo():
	if animated_sprite:
		animated_sprite.play("break")
	set_physics_process(false)
	print("¡Huevo roto!")
	queue_free() 
