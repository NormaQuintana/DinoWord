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

@export var velocidad = 50.0
var en_movimiento = true
var en_contacto_con_enemigo = false
var direccion = Vector2.RIGHT
var estado = State.RUNNING

# ¡Ahora estas variables se inicializarán desde PlayerData!
var vida: float # Usar float para daño por segundo
var daño_por_segundo: float # Usar float para daño por segundo

func _ready():
    # Cargar los valores de vida y daño del dinosaurio desde PlayerData
    vida = float(PlayerData.saved_life) # Asegúrate de que sea float para las operaciones con delta
    daño_por_segundo = float(PlayerData.saved_attack) # Asegúrate de que sea float

    # Reiniciar PlayerData stats al inicio de cada nivel
    # Esto asegura que si el jugador muere o el nivel termina,
    # el siguiente nivel comience con stats base, a menos que el flujo de juego
    # indique que los potenciadores persisten entre niveles (lo cual es un diseño diferente).
    # Si los potenciadores deben persistir a lo largo de múltiples niveles hasta una muerte o reinicio total,
    # esta línea debería ir en un script de 'GameManager' o al final del nivel.
    # Por el momento, la dejaremos aquí para cumplir con "cuando se acabe el nivel los valores ... deberan volver a la normalidad".
    # Una alternativa más robusta es que el 'GameManager' o el script que maneja el fin de nivel
    # llame a PlayerData.reset_player_stats() explícitamente.
    PlayerData.reset_player_stats() # <--- RESETA LOS VALORES DE PLAYERDATA AL INICIO DEL NIVEL


    if animated_sprite:
        animated_sprite.play("run")
        estado = State.RUNNING
    if barra_de_vida:
        barra_de_vida.max_value = vida # El max_value de la barra debe ser la vida inicial cargada
        barra_de_vida.value = vida
    print("Dinosaurio cargado con: Vida ", vida, ", Daño por segundo ", daño_por_segundo)

func _physics_process(delta):
    match estado:
        State.RUNNING:
            if en_movimiento and animated_sprite and animated_sprite.animation == "run":
                velocity = direccion * velocidad
                var collision_info = move_and_collide(velocity * delta)
                if collision_info and collision_info.get_collider().is_in_group("enemigos"):
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
                
                # Obtener el enemigo de manera más robusta, idealmente por señal o referencia directa
                # o buscando en el collision_info si es un nodo de enemigo
                var enemigo = get_node_or_null("../Enemigo") # Esto asume una jerarquía muy específica
                # Mejor, el enemigo debería tener una señal de "muerte" o el collision_info debería darte el enemigo.
                # Por simplicidad, mantendremos tu forma actual, pero tenlo en cuenta.
                
                if is_instance_valid(enemigo) and enemigo.has_method("get_vida") and enemigo.get_vida() <= 0:
                    en_contacto_con_enemigo = false
                    animated_sprite.play("run")
                    estado = State.RUNNING
                elif not is_instance_valid(enemigo): # Si el enemigo ya no existe
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
