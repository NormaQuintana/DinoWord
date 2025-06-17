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

var vocabulario_data_casa: Dictionary = {}
var current_correct_answer_text: String = ""

# --- Variables para la funcionalidad de Frases ---
@onready var frases_panel = $Preguntas/frases
@onready var frases_pregunta_label = $Preguntas/frases/VBoxContainer/PreguntaLabel
@onready var frases_opciones_container = $Preguntas/frases/VBoxContainer/OpcionesContainer
@onready var frases_mensaje_label = $Preguntas/frases/VBoxContainer/MensajeLabel

var frases_data_casa: Dictionary = {}
var current_frases_correct_answer_text: String = ""

# --- Nuevas variables para la funcionalidad de Ordenar ---
@onready var ordenar_panel = $Preguntas/ordenar
@onready var ordenar_pregunta_label = $Preguntas/ordenar/VBoxContainer/PreguntaLabel
@onready var ordenar_opciones_container = $Preguntas/ordenar/VBoxContainer/OpcionesContainer
@onready var ordenar_seleccionadas_container = $Preguntas/ordenar/VBoxContainer/SeleccionadasContainer
@onready var ordenar_mensaje_label = $Preguntas/ordenar/VBoxContainer/MensajeLabel

var ordenar_data_casa: Dictionary = {}
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

	var json_string_casa = """
	{
		"frases": {
			"01": { "1": "Yes, I can", "2": "I wanna a cup of tea", "p": "Can you switch the light off?" },
			"02": { "1": "Thanks, I’m coming!", "2": "I’m going to the gym", "p": "Breakfast is ready!" },
			"03": { "1": "Okay, I’m getting up", "2": "I’m going to sleep now", "p": "Wake up, sleepyhead!" },
			"04": { "1": "Here’s your coffee", "2": "Let’s go for a run", "p": "Ugh, I need coffee to function." },
			"05": { "1": "I feel like eating pancakes", "2": "I’m watching TV", "p": "What are you craving?" },
			"06": { "1": "Oops, sorry!", "2": "Let’s take a nap", "p": "Hands off! That’s mine!" },
			"07": { "1": "Sure, here’s some space", "2": "I like chocolate", "p": "Can you scoot over?" },
			"08": { "1": "Okay, you had it first", "2": "I’ll go make the bed", "p": "I call dibs on the remote!" },
			"09": { "1": "Me neither, mornings are hard", "2": "I’m brushing my dog", "p": "Ugh, I’m not a morning person." },
			"10": { "1": "Let’s relax for a bit", "2": "I’ll do the dishes now", "p": "This couch is calling my name." }
		},
		"vocabulario": {
			"01": { "1": "Chair", "2": "Table", "3": "Computer", "4": "Blanket", "p": "Silla" },
			"02": { "1": "Table", "2": "Phone", "3": "Lamp", "4": "Sofa", "p": "Mesa" },
			"03": { "1": "Glasses", "2": "Couch", "3": "Television", "4": "Closet", "p": "Vasos" },
			"04": { "1": "Dishes", "2": "Sofa", "3": "Blanket", "4": "Bathtub", "p": "Platos" },
			"05": { "1": "Fridge", "2": "Closet", "3": "Night table", "4": "Deodorant", "p": "Refrigerador" },
			"06": { "1": "Couch", "2": "Lamp", "3": "Chair", "4": "Bedspread", "p": "Sofá" },
			"07": { "1": "Cushion", "2": "Fridge", "3": "Dishes", "4": "Lotion", "p": "Almohadón" },
			"08": { "1": "Furniture", "2": "Bathtub", "3": "Blanket", "4": "Table", "p": "Muebles" },
			"09": { "1": "Sofa", "2": "Computer", "3": "Lotion", "4": "Closet", "p": "Sofá" },
			"10": { "1": "Television", "2": "Bedspread", "3": "Glasses", "4": "Cushion", "p": "Televisor" },
			"11": { "1": "Bedspread", "2": "Cushion", "3": "Cold water", "4": "Furniture", "p": "Cubre cama" },
			"12": { "1": "Blanket", "2": "Chair", "3": "Hot water", "4": "Lamp", "p": "Cobija" },
			"13": { "1": "Closet", "2": "Table", "3": "Couch", "4": "Lotion", "p": "Clóset" },
			"14": { "1": "Lamp", "2": "Sofa", "3": "Deodorant", "4": "Fridge", "p": "Lámpara" },
			"15": { "1": "Night table", "2": "Fridge", "3": "Television", "4": "Bathtub", "p": "Mesa de noche" },
			"16": { "1": "Bathtub", "2": "Closet", "3": "Cushion", "4": "Chair", "p": "Bañera" },
			"17": { "1": "Cold water", "2": "Lamp", "3": "Blanket", "4": "Sofa", "p": "Agua fría" },
			"18": { "1": "Deodorant", "2": "Dishes", "3": "Table", "4": "Couch", "p": "Desodorante" },
			"19": { "1": "Hot water", "2": "Bedspread", "3": "Furniture", "4": "Glasses", "p": "Agua caliente" },
			"20": { "1": "Lotion", "2": "Night table", "3": "Sofa", "4": "Computer", "p": "Loción" }
		},
		"ordenar": {
			"01": { "1": "What", "2": "is", "3": "for", "4": "[Product]", "p": "¿Qué hay para...?" },
			"02": { "1": "Where", "2": "is", "3": "the", "4": "remote", "p": "¿Dónde está el control?" },
			"03": { "1": "Can", "2": "you", "3": "pass", "4": "the salt", "p": "¿Puedes pasarme la sal?" },
			"04": { "1": "Where", "2": "are", "3": "the", "4": "[IProducts]", "p": "¿Dónde están los [Products]?" },
			"05": { "1": "Who", "2": "is", "3": "in", "4": "the kitchen", "p": "¿Quién está en la cocina?" },
			"06": { "1": "Can", "2": "you", "3": "help", "4": "me with the table", "p": "¿Me ayudas con la mesa?" },
			"07": { "1": "Is", "2": "dinner", "3": "ready", "4": "yet", "p": "¿Ya está lista la cena?" },
			"08": { "1": "Where", "2": "do", "3": "I", "4": "put this", "p": "¿Dónde pongo esto?" },
			"09": { "1": "What", "2": "are", "3": "you", "4": "cooking", "p": "¿Qué estás cocinando?" },
			"10": { "1": "Do", "2": "you", "3": "want", "4": "to watch a movie", "p": "¿Quieres ver una película?" }
		}
	}
	"""
	var parse_result = JSON.parse_string(json_string_casa)
	if parse_result is Dictionary:
		if "vocabulario" in parse_result:
			vocabulario_data_casa = parse_result.vocabulario
			print("Vocabulario de 'casa' cargado correctamente.")
		else:
			printerr("La clave 'vocabulario' no se encontró en los datos de 'casa'.")

		if "frases" in parse_result:
			frases_data_casa = parse_result.frases
			print("Frases de 'casa' cargadas correctamente.")
		else:
			printerr("La clave 'frases' no se encontró en los datos de 'casa'.")

		if "ordenar" in parse_result:
			ordenar_data_casa = parse_result.ordenar
			print("Ordenar de 'casa' cargado correctamente.")
		else:
			printerr("La clave 'ordenar' no se encontró en los datos de 'casa'.")
	else:
		printerr("Error al parsear el JSON de 'casa':", parse_result)

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
	if vocabulario_data_casa.is_empty():
		vocabulario_pregunta_label.text = "No hay preguntas de vocabulario disponibles para 'casa'."
		return

	for child in vocabulario_opciones_container.get_children():
		child.queue_free()

	var keys = vocabulario_data_casa.keys()
	var random_key = keys[randi() % keys.size()]
	var question_data = vocabulario_data_casa[random_key]

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
	if ordenar_data_casa.is_empty():
		ordenar_pregunta_label.text = "No hay preguntas de ordenar disponibles para 'casa'."
		return

	for child in ordenar_opciones_container.get_children():
		child.queue_free()
	for child in ordenar_seleccionadas_container.get_children():
		child.queue_free()

	current_ordenar_selected_order.clear()

	var keys = ordenar_data_casa.keys()
	var random_key = keys[randi() % keys.size()]
	var question_data = ordenar_data_casa[random_key]

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
	if frases_data_casa.is_empty():
		frases_pregunta_label.text = "No hay preguntas de frases disponibles para 'casa'."
		return

	for child in frases_opciones_container.get_children():
		child.queue_free()

	var keys = frases_data_casa.keys()
	var random_key = keys[randi() % keys.size()]
	var question_data = frases_data_casa[random_key]

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
