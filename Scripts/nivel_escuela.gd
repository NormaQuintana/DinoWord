extends Node2D

@onready var dinosaurio_manager = $DinosaurioManager

var dinosaurio1: PackedScene = preload("res://Escenas/Dinosaurios/dinosaurio.tscn")
var dinosaurio2: PackedScene = preload("res://Escenas/Dinosaurios/dinosaurio_2.tscn")
var dinosaurio3: PackedScene = preload("res://Escenas/Dinosaurios/dinosaurio_3.tscn")
var dinosaurio4: PackedScene = preload("res://Escenas/Dinosaurios/dinosaurio_4.tscn")

# --- Variables para la funcionalidad de Vocabulario ---
@onready var vocabulario_panel = $Preguntas/vocabulario
@onready var vocabulario_pregunta_label = $Preguntas/vocabulario/VBoxContainer/PreguntaLabel
@onready var vocabulario_opciones_container = $Preguntas/vocabulario/VBoxContainer/OpcionesContainer
@onready var vocabulario_mensaje_label = $Preguntas/vocabulario/VBoxContainer/MensajeLabel

var vocabulario_data_escuela: Dictionary = {}
var current_correct_answer_text: String = ""

# --- Variables para la funcionalidad de Frases ---
@onready var frases_panel = $Preguntas/frases
@onready var frases_pregunta_label = $Preguntas/frases/VBoxContainer/PreguntaLabel
@onready var frases_opciones_container = $Preguntas/frases/VBoxContainer/OpcionesContainer
@onready var frases_mensaje_label = $Preguntas/frases/VBoxContainer/MensajeLabel

var frases_data_escuela: Dictionary = {}
var current_frases_correct_answer_text: String = ""

# --- Nuevas variables para la funcionalidad de Ordenar ---
@onready var ordenar_panel = $Preguntas/ordenar
@onready var ordenar_pregunta_label = $Preguntas/ordenar/VBoxContainer/PreguntaLabel
@onready var ordenar_opciones_container = $Preguntas/ordenar/VBoxContainer/OpcionesContainer
@onready var ordenar_seleccionadas_container = $Preguntas/ordenar/VBoxContainer/SeleccionadasContainer
@onready var ordenar_mensaje_label = $Preguntas/ordenar/VBoxContainer/MensajeLabel

var ordenar_data_escuela: Dictionary = {}
var current_ordenar_correct_order: Array[String] = []
var current_ordenar_selected_order: Array[String] = []

# --- Variable para saber qué quiz se activó desde "Voz" ---
var current_quiz_from_voz: String = ""

# --- Nueva variable para mantener el panel activo actualmente ---
var active_quiz_panel: Control = null

# --- Variables para el Sistema de Puntuación ---
var score: int = 0
@onready var score_value_label: Label = $"HBoxContainer/ScoreValue" # <--- ¡IMPORTANTE! Ajusta esta ruta a tu ScoreValue Label

func _ready():
	# Inicializa la puntuación en el Label al inicio
	_update_score_display()

	var json_string_escuela = """
	{
		"frases": {
			"01": { "p": "Where is your classroom?", "1": "It’s on the second floor.", "2": "It’s in the kitchen." },
			"02": { "p": "Who is your English teacher?", "1": "Mr. Smith is my English teacher.", "2": "My dog is my English teacher." },
			"03": { "p": "Do you have your homework?", "1": "Yes, I have it in my backpack.", "2": "No, I ate it this morning." },
			"04": { "p": "What subject do you like?", "1": "I like math.", "2": "I like sleeping." },
			"05": { "p": "What do you do in science class?", "1": "We do experiments.", "2": "We cook spaghetti." },
			"06": { "p": "What do you need for math class?", "1": "I need a calculator and a notebook.", "2": "I need a spoon and a plate." },
			"07": { "p": "What time does school start?", "1": "School starts at 8 a.m.", "2": "School starts at midnight." },
			"08": { "p": "What do you do in computer class?", "1": "I learn to use a computer.", "2": "I play football." },
			"09": { "p": "What do you eat at lunch?", "1": "I eat a sandwich and fruit.", "2": "I eat paper and glue." },
			"10": { "p": "What is your favorite subject?", "1": "My favorite subject is English.", "2": "My favorite subject is sleeping." }
		},
		"vocabulario": {
			"01": { "1": "teacher", "2": "student", "3": "principal", "4": "librarian", "p": "maestro" },
			"02": { "1": "notebook", "2": "folder", "3": "paper", "4": "book", "p": "cuaderno" },
			"03": { "1": "desk", "2": "chair", "3": "table", "4": "board", "p": "escritorio" },
			"04": { "1": "backpack", "2": "pencil case", "3": "bag", "4": "coat", "p": "mochila" },
			"05": { "1": "board", "2": "screen", "3": "wall", "4": "marker", "p": "pizarra" },
			"06": { "1": "pencil", "2": "pen", "3": "ruler", "4": "brush", "p": "lápiz" },
			"07": { "1": "student", "2": "teacher", "3": "classmate", "4": "assistant", "p": "alumno" },
			"08": { "1": "classroom", "2": "hallway", "3": "office", "4": "gym", "p": "salón" },
			"09": { "1": "homework", "2": "exam", "3": "project", "4": "lesson", "p": "tarea" },
			"10": { "1": "book", "2": "magazine", "3": "notebook", "4": "newspaper", "p": "libro" }
		},
		"ordenar": {
			"01": { "1": "Where", "2": "is", "3": "your", "4": "classroom", "5": "?", "p": "¿Dónde está tu salón?" },
			"02": { "1": "Work", "2": "quietly", "3": ".", "p": "Trabaja en silencio." },
			"03": { "1": "Look", "2": "at", "3": "the", "4": "board", "5": ".", "p": "Mira la pizarra." },
			"04": { "1": "Do", "2": "you", "3": "like", "4": "English", "5": "class", "6": "?", "p": "¿Te gusta la clase de inglés?" },
			"05": { "1": "Do", "2": "you", "3": "have", "4": "homework", "5": "today", "6": "?", "p": "¿Tienes tarea hoy?" },
			"06": { "1": "What", "2": "is", "3": "your", "4": "favorite", "5": "subject", "6": "?", "p": "¿Cuál es tu materia favorita?" },
			"07": { "1": "What", "2": "time", "3": "does", "4": "school", "5": "start", "6": "?", "p": "¿A qué hora empieza la escuela?" },
			"08": { "1": "Can", "2": "you", "3": "repeat", "4": "that", "5": "please", "6": "?", "p": "¿Puedes repetir, por favor?" },
			"09": { "1": "Open", "2": "your", "3": "book", "4": "please", "5": ".", "p": "Abre tu libro, por favor." },
			"10": { "1": "Listen", "2": "to", "3": "the", "4": "teacher", "5": ".", "p": "Escucha al maestro." }
		}
	}
	"""
	var parse_result = JSON.parse_string(json_string_escuela)
	if parse_result is Dictionary:
		if "vocabulario" in parse_result:
			vocabulario_data_escuela = parse_result.vocabulario
			print("Vocabulario de 'escuela' cargado correctamente.")
		else:
			printerr("La clave 'vocabulario' no se encontró en los datos de 'escuela'.")

		if "frases" in parse_result:
			frases_data_escuela = parse_result.frases
			print("Frases de 'escuela' cargadas correctamente.")
		else:
			printerr("La clave 'frases' no se encontró en los datos de 'escuela'.")

		if "ordenar" in parse_result:
			ordenar_data_escuela = parse_result.ordenar
			print("Ordenar de 'escuela' cargado correctamente.")
		else:
			printerr("La clave 'ordenar' no se encontró en los datos de 'escuela'.")
	else:
		printerr("Error al parsear el JSON de 'escuela':", parse_result)

# --- Nueva función para detectar clics ---
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if active_quiz_panel and active_quiz_panel.visible:
			var mouse_pos = get_global_mouse_position()
			# Comprueba si el clic fue fuera del rectángulo del panel activo
			if not active_quiz_panel.get_global_rect().has_point(mouse_pos):
				_hide_active_quiz_panel()

func _hide_active_quiz_panel() -> void:
	if active_quiz_panel:
		active_quiz_panel.visible = false
		active_quiz_panel = null
		current_quiz_from_voz = ""
		print("Panel de quiz cerrado por clic fuera.")

# --- Funciones para el quiz de Vocabulario ---

func _on_vocabulario_pressed() -> void:
	vocabulario_panel.visible = true
	vocabulario_mensaje_label.text = ""
	vocabulario_mensaje_label.modulate = Color.WHITE
	_display_new_vocabulario_question()
	active_quiz_panel = vocabulario_panel

func _on_vocabulario_option_selected(selected_answer_text: String) -> void:
	if selected_answer_text == current_correct_answer_text:
		vocabulario_mensaje_label.text = "¡Correcto!"
		vocabulario_mensaje_label.modulate = Color.GREEN
		_add_score(100) # Suma 100 puntos por vocabulario
		if current_quiz_from_voz == "vocabulario":
			_on_prueba_voz_pressed()
			current_quiz_from_voz = ""
		else:
			_on_prueba_vocabulario_pressed()
	else:
		vocabulario_mensaje_label.text = "¡Incorrecto!"
		vocabulario_mensaje_label.modulate = Color.RED
	await get_tree().create_timer(1.0).timeout
	vocabulario_panel.visible = false
	active_quiz_panel = null

func _display_new_vocabulario_question():
	if vocabulario_data_escuela.is_empty():
		vocabulario_pregunta_label.text = "No hay preguntas de vocabulario disponibles para 'escuela'."
		return

	for child in vocabulario_opciones_container.get_children():
		child.queue_free()

	var keys = vocabulario_data_escuela.keys()
	var random_key = keys[randi() % keys.size()]
	var question_data = vocabulario_data_escuela[random_key]

	vocabulario_pregunta_label.text = question_data.p

	current_correct_answer_text = question_data["1"]

	var options_list = []
	options_list.append(question_data["1"])
	options_list.append(question_data["2"])
	options_list.append(question_data["3"])
	options_list.append(question_data["4"])
	options_list.shuffle()

	var button_min_width_vocab = 150
	var button_min_height_vocab = 80

	for i in range(options_list.size()):
		var button = Button.new()
		button.text = options_list[i]
		button.custom_minimum_size = Vector2(button_min_width_vocab, button_min_height_vocab)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.pressed.connect(Callable(self, "_on_vocabulario_option_selected").bind(button.text))
		vocabulario_opciones_container.add_child(button)

# --- Funciones para el quiz de Ordenar ---

func _on_ordenar_pressed() -> void:
	ordenar_panel.visible = true
	ordenar_mensaje_label.text = ""
	ordenar_mensaje_label.modulate = Color.WHITE
	current_ordenar_selected_order.clear()
	_display_new_ordenar_question()
	active_quiz_panel = ordenar_panel

func _on_ordenar_word_selected(button: Button, word: String) -> void:
	current_ordenar_selected_order.append(word)
	ordenar_opciones_container.remove_child(button)
	ordenar_seleccionadas_container.add_child(button)
	button.pressed.disconnect(Callable(self, "_on_ordenar_word_selected"))

func _on_ordenar_check_pressed() -> void:
	if current_ordenar_selected_order.size() != current_ordenar_correct_order.size():
		ordenar_mensaje_label.text = "¡Faltan palabras o hay de más! Selecciona todas las palabras."
		ordenar_mensaje_label.modulate = Color.YELLOW
		return

	var is_correct = true
	for i in range(current_ordenar_correct_order.size()):
		if current_ordenar_selected_order[i] != current_ordenar_correct_order[i]:
			is_correct = false
			break

	if is_correct:
		ordenar_mensaje_label.text = "¡Correcto!"
		ordenar_mensaje_label.modulate = Color.GREEN
		_add_score(200) # Suma 200 puntos por ordenar
		if current_quiz_from_voz == "ordenar":
			_on_prueba_voz_pressed()
			current_quiz_from_voz = ""
		else:
			_on_prueba_ordenar_pressed()
	else:
		ordenar_mensaje_label.text = "¡Incorrecto! Intenta de nuevo."
		ordenar_mensaje_label.modulate = Color.RED

	await get_tree().create_timer(1.0).timeout
	ordenar_panel.visible = false
	active_quiz_panel = null

func _display_new_ordenar_question():
	if ordenar_data_escuela.is_empty():
		ordenar_pregunta_label.text = "No hay preguntas de ordenar disponibles para 'escuela'."
		return

	for child in ordenar_opciones_container.get_children():
		child.queue_free()
	for child in ordenar_seleccionadas_container.get_children():
		child.queue_free()

	current_ordenar_selected_order.clear()

	var keys = ordenar_data_escuela.keys()
	var random_key = keys[randi() % keys.size()]
	var question_data = ordenar_data_escuela[random_key]

	ordenar_pregunta_label.text = question_data.p

	current_ordenar_correct_order.clear()
	var unsorted_words: Array[String] = []

	for i in range(1, 11):
		var key_word = str(i)
		if question_data.has(key_word):
			current_ordenar_correct_order.append(question_data[key_word])
			unsorted_words.append(question_data[key_word])
		else:
			break

	unsorted_words.shuffle()

	var button_min_width_ordenar = 100
	var button_min_height_ordenar = 60

	for word in unsorted_words:
		var button = Button.new()
		button.text = word
		button.custom_minimum_size = Vector2(button_min_width_ordenar, button_min_height_ordenar)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.pressed.connect(Callable(self, "_on_ordenar_word_selected").bind(button, word))
		ordenar_opciones_container.add_child(button)

	var check_button = Button.new()
	check_button.text = "Comprobar"
	check_button.custom_minimum_size = Vector2(button_min_width_ordenar * 1.5, button_min_height_ordenar)
	check_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	check_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	check_button.pressed.connect(Callable(self, "_on_ordenar_check_pressed"))
	ordenar_opciones_container.add_child(check_button)

# --- Funciones para el quiz de Voz ---

func _on_voz_pressed() -> void:
	var quizzes = ["vocabulario", "frases", "ordenar"]
	var chosen_quiz = quizzes[randi() % quizzes.size()]
	
	current_quiz_from_voz = chosen_quiz
	
	print("El carril de Voz ha activado el quiz: ", chosen_quiz)

	match chosen_quiz:
		"vocabulario":
			_on_vocabulario_pressed()
		"frases":
			_on_frases_pressed()
		"ordenar":
			_on_ordenar_pressed()

# --- Funciones para el quiz de Frases ---

func _on_frases_pressed() -> void:
	frases_panel.visible = true
	frases_mensaje_label.text = ""
	frases_mensaje_label.modulate = Color.WHITE
	_display_new_frases_question()
	active_quiz_panel = frases_panel

func _on_frases_option_selected(selected_answer_text: String) -> void:
	if selected_answer_text == current_frases_correct_answer_text:
		frases_mensaje_label.text = "¡Correcto!"
		frases_mensaje_label.modulate = Color.GREEN
		_add_score(150) # Suma 150 puntos por frases
		if current_quiz_from_voz == "frases":
			_on_prueba_voz_pressed()
			current_quiz_from_voz = ""
		else:
			_on_prueba_frases_pressed()
	else:
		frases_mensaje_label.text = "¡Incorrecto!"
		frases_mensaje_label.modulate = Color.RED
	await get_tree().create_timer(1.0).timeout
	frases_panel.visible = false
	active_quiz_panel = null

func _display_new_frases_question():
	if frases_data_escuela.is_empty():
		frases_pregunta_label.text = "No hay preguntas de frases disponibles para 'escuela'."
		return

	for child in frases_opciones_container.get_children():
		child.queue_free()

	var keys = frases_data_escuela.keys()
	var random_key = keys[randi() % keys.size()]
	var question_data = frases_data_escuela[random_key]

	frases_pregunta_label.text = question_data.p

	current_frases_correct_answer_text = question_data["1"]

	var options_list = []
	options_list.append(question_data["1"])
	options_list.append(question_data["2"])
	if question_data.has("3"): options_list.append(question_data["3"])
	if question_data.has("4"): options_list.append(question_data["4"])
	options_list.shuffle()

	var button_min_width_frases = 300
	var button_min_height_frases = 100

	for i in range(options_list.size()):
		var button = Button.new()
		button.text = options_list[i]
		button.custom_minimum_size = Vector2(button_min_width_frases, button_min_height_frases)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.pressed.connect(Callable(self, "_on_frases_option_selected").bind(button.text))
		frases_opciones_container.add_child(button)

# --- Funciones para instanciar dinosaurios ---

func _on_prueba_vocabulario_pressed() -> void:
	var nuevo_dinosaurio = dinosaurio1.instantiate()
	nuevo_dinosaurio.position = Vector2(128, 152)
	add_child(nuevo_dinosaurio)
	dinosaurio_manager.registrar_dinosaurio(nuevo_dinosaurio)

func _on_prueba_ordenar_pressed() -> void:
	var nuevo_dinosaurio = dinosaurio2.instantiate()
	nuevo_dinosaurio.position = Vector2(128, 256)
	add_child(nuevo_dinosaurio)
	dinosaurio_manager.registrar_dinosaurio(nuevo_dinosaurio)

func _on_prueba_voz_pressed() -> void:
	var nuevo_dinosaurio = dinosaurio3.instantiate()
	nuevo_dinosaurio.position = Vector2(128, 369)
	add_child(nuevo_dinosaurio)
	dinosaurio_manager.registrar_dinosaurio(nuevo_dinosaurio)

func _on_prueba_frases_pressed() -> void:
	var nuevo_dinosaurio = dinosaurio4.instantiate()
	nuevo_dinosaurio.position = Vector2(128, 481)
	add_child(nuevo_dinosaurio)
	dinosaurio_manager.registrar_dinosaurio(nuevo_dinosaurio)

# --- Nueva función para añadir puntuación y actualizar el display ---
func _add_score(points: int) -> void:
	score += points
	_update_score_display()
	print("Puntuación actual: ", score)

func _update_score_display() -> void:
	if score_value_label:
		score_value_label.text = str(score)
	else:
		printerr("ERROR: ScoreValueLabel no encontrado para actualizar la puntuación.")
