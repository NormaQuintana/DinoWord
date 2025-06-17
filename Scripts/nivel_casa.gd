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

var current_correct_answer_text: String = ""

# --- Variables para la funcionalidad de Frases ---
@onready var frases_panel = $Preguntas/frases
@onready var frases_pregunta_label = $Preguntas/frases/VBoxContainer/PreguntaLabel
@onready var frases_opciones_container = $Preguntas/frases/VBoxContainer/OpcionesContainer
@onready var frases_mensaje_label = $Preguntas/frases/VBoxContainer/MensajeLabel

var current_frases_correct_answer_text: String = ""

# --- Nuevas variables para la funcionalidad de Ordenar ---
@onready var ordenar_panel = $Preguntas/ordenar
@onready var ordenar_pregunta_label = $Preguntas/ordenar/VBoxContainer/PreguntaLabel
@onready var ordenar_opciones_container = $Preguntas/ordenar/VBoxContainer/OpcionesContainer
@onready var ordenar_seleccionadas_container = $Preguntas/ordenar/VBoxContainer/SeleccionadasContainer
@onready var ordenar_mensaje_label = $Preguntas/ordenar/VBoxContainer/MensajeLabel

var current_ordenar_correct_order: Array[String] = []
var current_ordenar_selected_order: Array[String] = []

# --- Variable para saber qué quiz se activó desde "Voz" ---
var current_quiz_from_voz: String = ""

# --- Nueva variable para mantener el panel activo actualmente ---
var active_quiz_panel: Control = null

# --- Variables para el Sistema de Puntuación ---
var score: int = 0
@onready var score_value_label: Label = $"HBoxContainer/ScoreValue" 

# --- Variables para la funcionalidad de Vozs ---
var palabra_voz:String

# === VARS PARA EL PANEL FIN NIVEL ===
@onready var fin_nivel_panel: Control = $"FinNivel" # Asegúrate de que esta ruta sea correcta
@onready var mensaje_felicidades_label: Label = $"FinNivel/FelicidadesLabel" # Asegúrate de que esta ruta sea correcta

# === NUEVAS VARS PARA EL GAME OVER Y HUEVOS ===
@onready var game_over_panel: Control = $"GameOver" # Ruta al panel GameOver
@onready var game_over_label: Label = $"GameOver/GameOverLabel" # Ruta al Label "Game Over"
@onready var try_again_button: Button = $"GameOver/Try_again" # Ruta al botón "Try_again"
@onready var exit_to_map_button: Button = $"GameOver/Salir_Mapa" # Si tienes un botón para salir al mapa, ajusta la ruta

# Referencias a los nodos de los huevos en tu escena, usando los nombres que mencionaste
@onready var huevo1: CharacterBody2D = $"Huevo1" # Ajusta si "Huevito 1" está anidado (ej. $"Huevos/Huevito 1")
@onready var huevo2: CharacterBody2D = $"Huevo2"
@onready var huevo3: CharacterBody2D = $"Huevo3"
@onready var huevo4: CharacterBody2D = $"Huevo4"

var huevos_restantes: int = 0

func _ready():
    # Inicializa la puntuación en el Label al inicio
    _update_score_display()
    
    # Asegúrate de que el panel FinNivel esté oculto al inicio
    if fin_nivel_panel:
        fin_nivel_panel.visible = false
    else:
        printerr("Error: El panel 'FinNivel' no se encontró. Revisa la ruta.")

      
       
        

    # === Conectar señales de los huevos y contar inicial ===
    # Puedes poner los huevos en un arreglo para facilitar la iteración
    var todos_los_huevos = [huevo1, huevo2, huevo3, huevo4]
    
    huevos_restantes = 0
    for huevo in todos_los_huevos:
        if huevo and is_instance_valid(huevo): # Verifica que el nodo existe y es válido
            huevo.egg_destroyed.connect(_on_egg_destroyed)
            huevos_restantes += 1 # Contar solo los huevos que existen al inicio
        else:
            printerr("Advertencia: No se encontró el nodo de huevo o es inválido para la ruta: ", huevo.get_path() if huevo else "null")
    
    print("Huevos iniciales en el nivel: ", huevos_restantes)


# --- Resto de tus funciones _input, _hide_active_quiz_panel, etc. ---

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
    #_check_level_completion() # Comentar o descomentar según la lógica de fin de nivel.

func _display_new_vocabulario_question():
    var vocabulario_data = GlobalData.data.casa.vocabulario
    if vocabulario_data.is_empty():
        vocabulario_pregunta_label.text = "No hay preguntas de vocabulario disponibles para 'casa'."
        return

    for child in vocabulario_opciones_container.get_children():
        child.queue_free()

    var keys = vocabulario_data.keys()
    var random_key = keys[randi() % keys.size()]
    var question_data = vocabulario_data[random_key]

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
    #_check_level_completion() # Comentar o descomentar según la lógica de fin de nivel.

func _display_new_ordenar_question():
    var ordenar_data = GlobalData.data.casa.ordenar
    if ordenar_data.is_empty():
        ordenar_pregunta_label.text = "No hay preguntas de ordenar disponibles para 'casa'."
        return

    for child in ordenar_opciones_container.get_children():
        child.queue_free()
    for child in ordenar_seleccionadas_container.get_children():
        child.queue_free()

    current_ordenar_selected_order.clear()

    var keys = ordenar_data.keys()
    var random_key = keys[randi() % keys.size()]
    var question_data = ordenar_data[random_key]

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
    #_check_level_completion() # Comentar o descomentar según la lógica de fin de nivel.

func _display_new_frases_question():
    var frases_data = GlobalData.data.casa.frases
    if frases_data.is_empty():
        frases_pregunta_label.text = "No hay preguntas de frases disponibles para 'casa'."
        return

    for child in frases_opciones_container.get_children():
        child.queue_free()

    var keys = frases_data.keys()
    var random_key = keys[randi() % keys.size()]
    var question_data = frases_data[random_key]

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

# ---------- Funciones para el quiz de Voz -----------

func _on_voz_pressed() -> void:
    var panel = $Preguntas/voz
    panel.visible = true
    var vocabulario = GlobalData.data.casa.vocabulario
    print(vocabulario)
    var id_aleatorio = vocabulario.keys().pick_random()
    var pregunta = vocabulario[id_aleatorio]
    print(pregunta)
    palabra_voz = pregunta["p"]
    #$Preguntas/voz/Label.text = palabra_voz # Si tienes un label que muestre la pregunta en español
    $Preguntas/voz/palabra1.text = pregunta["1"]
    $Preguntas/voz/palabra2.text = pregunta["2"]
    $Preguntas/voz/palabra3.text = pregunta["3"]
    $Preguntas/voz/palabra4.text = pregunta["4"]

func _on_prueba_voz_pressed() -> void:
    _add_score(200)
    var nuevo_dinosaurio = dinosaurio3.instantiate()
    nuevo_dinosaurio.position = Vector2(128, 369)
    add_child(nuevo_dinosaurio)
    dinosaurio_manager.registrar_dinosaurio(nuevo_dinosaurio)
    var panel = $Preguntas/voz
    panel.visible = false

func _on_audio_pressed() -> void:
    var texto_a_reproducir = palabra_voz
    if not texto_a_reproducir.is_empty():
        var voces_disponibles = DisplayServer.tts_get_voices()
        print("--- Voces TTS Disponibles ---")
        if voces_disponibles.is_empty():
            print("¡No se encontró ninguna voz TTS en el sistema!")
        else:
            for voz in voces_disponibles:
                print("ID: %s, Nombre: %s, Idioma: %s" % [voz["id"], voz["name"], voz["language"]])
        print("----------------------------")
        print("Intentando reproducir: ", texto_a_reproducir)
        DisplayServer.tts_speak(texto_a_reproducir, "es-MX")
    else:
        print("No hay texto que reproducir en la etiqueta de voz.")

# === FUNCIÓN PARA GESTIONAR EL FINAL DEL NIVEL (VICTORIA) ===
func _check_level_completion() -> void:
    if fin_nivel_panel:
        fin_nivel_panel.visible = true
    
    if score >= 1500: # La condición para ganar el huevito es 1500 o más
        if mensaje_felicidades_label:
            mensaje_felicidades_label.text = "¡Felicidades! ¡Has ganado un huevito extra!"
            PlayerData.huevitos_total += 1
            print("¡Huevito extra ganado! Total de huevitos: ", PlayerData.huevitos_total)
            PlayerData.save_game_data()
        else:
            printerr("Error: El Label 'FelicidadesLabel' no se encontró en el panel FinNivel.")
    else: # Si el score es MENOR a 1500
        if mensaje_felicidades_label:
            mensaje_felicidades_label.text = "¡Buen intento! Necesitas al menos 1500 puntos para un huevito extra."
        else:
            printerr("Error: El Label 'FelicidadesLabel' no se encontró en el panel FinNivel.")
    
    get_tree().paused = true

func _on_egg_destroyed() -> void:
    huevos_restantes -= 1
    print("Un huevo fue destruido. Huevos restantes: ", huevos_restantes)
    
    if huevos_restantes <= 0:
        _game_over()

func _game_over() -> void:
    print("¡GAME OVER! Todos los huevos destruidos. Cambiando a escena de fin de juego.")
    get_tree().paused = false # Despausa el juego ANTES de cambiar de escena
    # Aquí es donde cambias a tu nueva escena "finjuego.tscn"
    get_tree().change_scene_to_file("res://Escenas/finjuego.tscn")
