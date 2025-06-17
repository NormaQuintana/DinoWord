# vista_potenciador.gd
extends Node2D

var dinosaurio1_scene: PackedScene = preload("res://Escenas/Dinosaurios/dinosaurio.tscn")
var dinosaurio2_scene: PackedScene = preload("res://Escenas/Dinosaurios/dinosaurio_2.tscn")
var dinosaurio3_scene: PackedScene = preload("res://Escenas/Dinosaurios/dinosaurio_3.tscn")
var dinosaurio4_scene: PackedScene = preload("res://Escenas/Dinosaurios/dinosaurio_4.tscn")


var dinosaurio_nombres: Array[String] = [
	"Carbón",
	"Joss",
	"Momo",
	"Chipotle"
]

@onready var dinosaurio_display_container: Node2D = $"Dinosaurio"
@onready var boton_izquierda: Button = $"BotonIzquierda"
@onready var boton_derecha: Button = $"BotonDerecha"
@onready var nombre_dinosaurio_label: Label = $"Panel/Panel/NombreDinosaurioLabel"

var all_dinosaurio_scenes: Array[PackedScene]
var current_dinosaurio_index = 0
var current_dinosaurio_instance: CharacterBody2D = null

# --- Variables para los huevitos y estadísticas ---
# Estas variables son temporales para esta escena, sus valores maestros están en PlayerData.
var huevitos_count: int
var current_life: int
var current_attack: int

# Las constantes se mantienen
const DEFAULT_LIFE_VALUE: int = 100
const DEFAULT_ATTACK_VALUE: int = 50
const UPGRADE_INCREMENT: int = 50
const EGG_COST_PER_UPGRADE: int = 1


@onready var cantidad_huevitos_label: Label = $"CantidadHuevitos"
@onready var life_bar: TextureProgressBar = $"Panel/LifeBar"
@onready var btn_agregar_vida: Button = $"Panel/LifeBar/Agregar"
@onready var btn_eliminar_vida: Button = $"Panel/LifeBar/Eliminar"
@onready var attack_bar: TextureProgressBar = $"Panel/AttackBar"
@onready var btn_agregar_ataque: Button = $"Panel/AttackBar/Agregar2"
@onready var btn_eliminar_ataque: Button = $"Panel/AttackBar/Eliminar2"


func _ready():
	# Cargar los valores guardados de PlayerData al iniciar la vista del potenciador
	_load_player_data()
	_update_stats_display() # Asegura que la UI refleje los valores cargados

	# Poblar el array con las escenas precargadas
	all_dinosaurio_scenes.append(dinosaurio1_scene)
	all_dinosaurio_scenes.append(dinosaurio2_scene)
	all_dinosaurio_scenes.append(dinosaurio3_scene)
	all_dinosaurio_scenes.append(dinosaurio4_scene)

	# Conectar los botones de navegación de dinosaurios
	# <--- AÑADIR ESTAS CONEXIONES AQUI, ESTABAN FALTANDO EN TU CODIGO PEGADO
	if boton_izquierda:
		boton_izquierda.pressed.connect(_on_boton_izquierda_pressed)
	else:
		printerr("ERROR: BotonIzquierda no encontrado en la ruta esperada.")

	if boton_derecha:
		boton_derecha.pressed.connect(_on_boton_derecha_pressed)
	else:
		printerr("ERROR: BotonDerecha no encontrado en la ruta esperada.")
	# FIN DE LAS CONEXIONES FALTANTES

	# Conectar botones de vida y ataque
	if btn_agregar_vida:
		btn_agregar_vida.pressed.connect(_on_agregar_vida_pressed)
	else:
		printerr("ERROR: Botón 'Agregar' (Vida) no encontrado.")
	if btn_eliminar_vida:
		btn_eliminar_vida.pressed.connect(_on_eliminar_vida_pressed)
	else:
		printerr("ERROR: Botón 'Eliminar' (Vida) no encontrado.")
	if btn_agregar_ataque:
		btn_agregar_ataque.pressed.connect(_on_agregar_ataque_pressed)
	else:
		printerr("ERROR: Botón 'Agregar2' (Ataque) no encontrado.")
	if btn_eliminar_ataque:
		btn_eliminar_ataque.pressed.connect(_on_eliminar_ataque_pressed)
	else:
		printerr("ERROR: Botón 'Eliminar2' (Ataque) no encontrado.")


	_display_dinosaurio() # Esto debería ir después de las conexiones de los botones de navegación

	if dinosaurio_display_container: print("DinosaurioDisplayContainer encontrado.")
	if nombre_dinosaurio_label: print("NombreDinosaurioLa encontrado.")


func _on_boton_izquierda_pressed():
	current_dinosaurio_index -= 1
	if current_dinosaurio_index < 0:
		current_dinosaurio_index = all_dinosaurio_scenes.size() - 1
	_display_dinosaurio()

func _on_boton_derecha_pressed():
	current_dinosaurio_index += 1
	if current_dinosaurio_index >= all_dinosaurio_scenes.size():
		current_dinosaurio_index = 0
	_display_dinosaurio()

func _display_dinosaurio():
	if all_dinosaurio_scenes.is_empty():
		printerr("No hay escenas de dinosaurios asignadas o precargadas.")
		_clear_display()
		return

	if current_dinosaurio_instance and is_instance_valid(current_dinosaurio_instance):
		current_dinosaurio_instance.queue_free()
		current_dinosaurio_instance = null

	# Instanciar el nuevo dinosaurio
	var dino_scene_pack = all_dinosaurio_scenes[current_dinosaurio_index]
	if dino_scene_pack:
		current_dinosaurio_instance = dino_scene_pack.instantiate() as CharacterBody2D

		# Añadir al contenedor de visualización
		if dinosaurio_display_container:
			dinosaurio_display_container.add_child(current_dinosaurio_instance)
			current_dinosaurio_instance.position = Vector2(0, 0) # Posición por defecto
			current_dinosaurio_instance.set_physics_process(false)
			current_dinosaurio_instance.set_process(false)
			if current_dinosaurio_instance.has_node("CollisionShape2D"):
				(current_dinosaurio_instance.get_node("CollisionShape2D") as CollisionShape2D).disabled = true
		else:
			printerr("DinosaurioDisplayContainer (nodo 'Dinosaurio') no encontrado.")

		# Actualizar el nombre del dinosaurio usando el array de nombres
		if nombre_dinosaurio_label:
			if current_dinosaurio_index < dinosaurio_nombres.size():
				nombre_dinosaurio_label.text = dinosaurio_nombres[current_dinosaurio_index]
			else:
				nombre_dinosaurio_label.text = current_dinosaurio_instance.name # Fallback
		else:
			printerr("NombreDinosaurioLa no encontrado.")

	else:
		printerr("Escena de dinosaurio no encontrada en el índice:", current_dinosaurio_index)
		_clear_display()

func _clear_display():
	if current_dinosaurio_instance and is_instance_valid(current_dinosaurio_instance):
		current_dinosaurio_instance.queue_free()
		current_dinosaurio_instance = null
	if nombre_dinosaurio_label:
		nombre_dinosaurio_label.text = "N/A"

func get_selected_dinosaurio_scene() -> PackedScene:
	if not all_dinosaurio_scenes.is_empty():
		return all_dinosaurio_scenes[current_dinosaurio_index]
	return null

func get_selected_dinosaurio_name() -> String:
	if current_dinosaurio_index < dinosaurio_nombres.size():
		return dinosaurio_nombres[current_dinosaurio_index]
	elif current_dinosaurio_instance:
		return current_dinosaurio_instance.name
	return "N/A"

# --- Funciones de inicialización y actualización de estadísticas ---
func _load_player_data() -> void:
	current_life = PlayerData.saved_life
	current_attack = PlayerData.saved_attack
	huevitos_count = PlayerData.huevitos_total # <--- CORRECCIÓN CLAVE: Cargar huevitos de PlayerData
	print("Potenciador cargado con: Vida ", current_life, ", Ataque ", current_attack, ", Huevitos ", huevitos_count)

func _save_player_data() -> void:
	PlayerData.saved_life = current_life
	PlayerData.saved_attack = current_attack
	PlayerData.huevitos_total = huevitos_count # <--- CORRECCIÓN CLAVE: Guardar huevitos en PlayerData
	print("Potenciador guardado: Vida ", current_life, ", Ataque ", current_attack, ", Huevitos ", huevitos_count)


func _update_stats_display() -> void:
	if cantidad_huevitos_label:
		cantidad_huevitos_label.text = str(huevitos_count)
	if life_bar:
		life_bar.value = current_life
		life_bar.max_value = 200 # Considera un valor máximo real para la barra
	if attack_bar:
		attack_bar.value = current_attack
		attack_bar.max_value = 200 # Considera un valor máximo real para la barra

# --- Funciones de los botones de Vida ---
func _on_agregar_vida_pressed() -> void:
	if huevitos_count >= EGG_COST_PER_UPGRADE:
		huevitos_count -= EGG_COST_PER_UPGRADE
		current_life += UPGRADE_INCREMENT
		# Opcional: poner un límite máximo a la vida
		# current_life = min(current_life, MAX_LIFE_VALUE) # Define MAX_LIFE_VALUE
		life_bar.value = current_life
		_update_stats_display()
		_save_player_data() # Guardar después de cada cambio
		print("Vida incrementada a: ", current_life, ". Huevitos restantes: ", huevitos_count)
	else:
		print("No hay suficientes huevitos para mejorar la vida.")

func _on_eliminar_vida_pressed() -> void:
	if current_life > DEFAULT_LIFE_VALUE:
		current_life -= UPGRADE_INCREMENT
		huevitos_count += EGG_COST_PER_UPGRADE
		current_life = max(DEFAULT_LIFE_VALUE, current_life)
		life_bar.value = current_life
		_update_stats_display()
		_save_player_data() # Guardar después de cada cambio
		print("Vida disminuida a: ", current_life, ". Huevitos: ", huevitos_count)
	else:
		print("La vida ya está en su valor por defecto y no se puede disminuir más.")

# --- Funciones de los botones de Ataque ---
func _on_agregar_ataque_pressed() -> void:
	if huevitos_count >= EGG_COST_PER_UPGRADE:
		huevitos_count -= EGG_COST_PER_UPGRADE
		current_attack += UPGRADE_INCREMENT
		# Opcional: poner un límite máximo al ataque
		# current_attack = min(current_attack, MAX_ATTACK_VALUE) # Define MAX_ATTACK_VALUE
		attack_bar.value = current_attack
		_update_stats_display()
		_save_player_data() # Guardar después de cada cambio
		print("Ataque incrementado a: ", current_attack, ". Huevitos restantes: ", huevitos_count)
	else:
		print("No hay suficientes huevitos para mejorar el ataque.")

func _on_eliminar_ataque_pressed() -> void:
	if current_attack > DEFAULT_ATTACK_VALUE:
		current_attack -= UPGRADE_INCREMENT
		huevitos_count += EGG_COST_PER_UPGRADE
		current_attack = max(DEFAULT_ATTACK_VALUE, current_attack)
		attack_bar.value = current_attack
		_update_stats_display()
		_save_player_data() # Guardar después de cada cambio
		print("Ataque disminuido a: ", current_attack, ". Huevitos: ", huevitos_count)
	else:
		print("El ataque ya está en su valor por defecto y no se puede disminuir más.")

# --- Función para añadir huevitos ---
func _add_eggs(amount: int) -> void:
	huevitos_count += amount
	_update_stats_display()
	_save_player_data() # <--- CORRECCIÓN CLAVE: Guarda los huevitos después de añadirlos
	print("Huevitos añadidos. Total: ", huevitos_count)

# --- Funciones para instanciar dinosaurios (sin cambios, pero sin lógica de quiz) ---
func _on_prueba_vocabulario_pressed() -> void:
	var nuevo_dinosaurio = dinosaurio1_scene.instantiate()
	nuevo_dinosaurio.position = Vector2(128, 152)
	add_child(nuevo_dinosaurio)

func _on_prueba_ordenar_pressed() -> void:
	var nuevo_dinosaurio = dinosaurio2_scene.instantiate()
	nuevo_dinosaurio.position = Vector2(128, 256)
	add_child(nuevo_dinosaurio)

func _on_prueba_voz_pressed() -> void:
	var nuevo_dinosaurio = dinosaurio3_scene.instantiate()
	nuevo_dinosaurio.position = Vector2(128, 369)
	add_child(nuevo_dinosaurio)

func _on_prueba_frases_pressed() -> void:
	var nuevo_dinosaurio = dinosaurio4_scene.instantiate()
	nuevo_dinosaurio.position = Vector2(128, 481)
	add_child(nuevo_dinosaurio)

var score: int = 0
@onready var score_value_label: Label = $"HBoxContainer/ScoreValue"

func _add_score(points: int) -> void:
	score += points
	_update_score_display()
	print("Puntuación actual: ", score)

func _update_score_display() -> void:
	if score_value_label:
		score_value_label.text = str(score)
	else:
		printerr("ERROR: ScoreValueLabel no encontrado para actualizar la puntuación.")
