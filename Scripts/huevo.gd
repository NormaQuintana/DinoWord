extends CharacterBody2D

# ¡IMPORTANTE! Debes declarar la señal al inicio del script.
signal egg_destroyed # <--- ¡Añade esta línea!

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
    # Considera añadir el uso de grupos aquí para ser más robusto:
    # if body.is_in_group("enemigos") and body.has_method("obtener_daño"):
    if body is CharacterBody2D and body.has_method("obtener_daño"):
        en_contacto_con_enemigo = true
        daño_recibido_por_segundo = body.obtener_daño()
        print("Huevo en contacto con enemigo. Daño:", daño_recibido_por_segundo)

func _on_body_exited(body):
    # Considera añadir el uso de grupos aquí para ser más robusto:
    # if body.is_in_group("enemigos") and body.has_method("obtener_daño"):
    if body is CharacterBody2D and body.has_method("obtener_daño"):
        en_contacto_con_enemigo = false
        daño_recibido_por_segundo = 0
        print("Huevo dejó de estar en contacto con el enemigo.")

func _romper_huevo():
    # Añadimos una comprobación para evitar que se ejecute dos veces si el huevo ya está en proceso de eliminación
    if not is_queued_for_deletion():
        set_physics_process(false) # Detener el _physics_process para este huevo
        
        if animated_sprite:
            animated_sprite.play("break")
            # Esto es un buen punto de mejora: esperar a que la animación termine antes de liberar el nodo.
            # Actualmente esperas 0.8 segundos fijos, pero la animación podría durar más o menos.
            # Si quieres esperar a la animación real: await animated_sprite.animation_finished
            await get_tree().create_timer(0.8).timeout # Mantengo tu await actual por ahora
        
        print("¡Huevo roto!")
        emit_signal("egg_destroyed") # Emitir la señal aquí
        queue_free() # Liberar el nodo después de la animación y la señal
