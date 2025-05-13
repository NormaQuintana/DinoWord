extends Control

@onready var button = $"."  # Botón de opciones
@onready var options_menu = $Window
@onready var music_slider = $Window/VBoxContainer/ContinerVolumenMusic/SliderMusic
@onready var sfx_slider = $Window/VBoxContainer/ContinerVolumenFX/SliderFX

# Definir los nombres de los buses de audio
const MUSIC_BUS_NAME = "Music"
const SFX_BUS_NAME = "FXs"

var music_bus_index: int
var sfx_bus_index: int

func _ready():
	# Obtener los índices de los buses de audio
	music_bus_index = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	sfx_bus_index = AudioServer.get_bus_index(SFX_BUS_NAME)
	
	# Inicializar sliders con el volumen actual de los buses
	var music_volume = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	var sfx_volume = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))
	
	# Multiplicar por 100 para ajustar al rango del slider (0-100)
	music_slider.value = music_volume * 100
	sfx_slider.value = sfx_volume * 100
	
	# Conectar las señales de los sliders
	button.pressed.connect(_on_button_pressed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _on_button_pressed():
	options_menu.visible = !options_menu.visible  # Alternar visibilidad

func _on_music_volume_changed(value):
	# Dividir por 100 para convertir de 0-100 a 0-1
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value / 100))
	print("Volumen de la música:", value)

func _on_sfx_volume_changed(value):
	# Dividir por 100 para convertir de 0-100 a 0-1
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value / 100))
	print("Volumen de efectos:", value)
