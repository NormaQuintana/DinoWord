extends Node2D

@export var tiempo_de_aparicion = 3.0
@export var puntos_de_aparicion: Array[Marker2D]
@export var enemigo_scene : PackedScene
@export var max_enemigos_a_aparecer = 10

@onready var fin_nivel_panel: Control = $"../FinNivel" 

var tiempo_transcurrido = 0.0
var cantidad_carriles = 0
var enemigos_aparecidos_count = 0 
var enemigos_activos_count = 0  

func _ready():
	cantidad_carriles = puntos_de_aparicion.size()
	if cantidad_carriles == 0:
		printerr("¡Advertencia! No se han asignado puntos de aparición para los enemigos.")
	
	# Verifica si el panel fue encontrado y lo oculta al inicio
	if fin_nivel_panel:
		fin_nivel_panel.visible = false
		print("Panel 'FinNivel' encontrado y oculto.")
	else:
		printerr("¡ERROR! Panel 'FinNivel' no encontrado en la ruta especificada: ../FinNivel")

	# Crea el primer enemigo al inicio del juego
	_aparecer_enemigo() 

func _process(delta):
	tiempo_transcurrido += delta
	if tiempo_transcurrido >= tiempo_de_aparicion \
	and cantidad_carriles > 0 \
	and enemigos_aparecidos_count < max_enemigos_a_aparecer \
	and (fin_nivel_panel == null or not fin_nivel_panel.visible): 
		_aparecer_enemigo()
		tiempo_transcurrido = 0.0

func _aparecer_enemigo():
	# Si ya hemos instanciado el número máximo de enemigos para este nivel,
	# no creamos más. El panel se activará cuando estos mueran.
	if enemigos_aparecidos_count >= max_enemigos_a_aparecer:
		print("Se ha alcanzado el límite TOTAL de enemigos a instanciar. No se crearán más.")
		return 

	var enemigo = enemigo_scene.instantiate()
	enemigo.velocidad = 70
	enemigo.vida = 100
	enemigo.daño_por_segundo = 50 # Asigna el daño si el spawner debe controlarlo
	
	var indice_carril_aleatorio = randi_range(0, cantidad_carriles - 1)
	var punto_de_aparicion = puntos_de_aparicion[indice_carril_aleatorio]

	if is_instance_valid(punto_de_aparicion):
		enemigo.global_position = punto_de_aparicion.global_position
		get_parent().add_child(enemigo)
		
		if enemigo.has_signal("enemigo_destruido"):
			enemigo.enemigo_destruido.connect(_on_enemigo_destruido)
		else:
			printerr("¡Error! El enemigo instanciado no tiene la señal 'enemigo_destruido'.")

		enemigos_aparecidos_count += 1 # Incrementa el contador de enemigos INSTANCIADOS
		enemigos_activos_count += 1   # Incrementa el contador de enemigos ACTIVOS
		print("Enemigo instanciado. Total aparecidos: ", enemigos_aparecidos_count, ", Activos: ", enemigos_activos_count)

# Función que se ejecuta cuando un enemigo emite su señal 'enemigo_destruido'
func _on_enemigo_destruido():
	enemigos_activos_count -= 1 # Decrementa el contador de enemigos activos
	print("Un enemigo fue destruido. Enemigos activos restantes: ", enemigos_activos_count)
	
	# Verifica si se han instanciado todos los enemigos previstos Y
	# si todos los enemigos activos han sido destruidos.
	if enemigos_aparecidos_count >= max_enemigos_a_aparecer and enemigos_activos_count <= 1:
		print("Todos los enemigos del nivel han sido destruidos. ¡Nivel completado!")
		if fin_nivel_panel:
			fin_nivel_panel.visible = true
			print("Panel 'FinNivel' activado.")
		# Detener el proceso de aparición del spawner una vez que el nivel ha terminado.
		set_process(false)
