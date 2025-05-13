extends Control

var db_ref = Firebase.Database.get_database_reference("vocabulario", {})

@onready var anima=$AnimationPlayer
@onready var tiempo=$Timer
func _ready():
	anima.play("new_animation")
	tiempo.start()
	load_game_data()

# Función para obtener datos desde Firebase
func load_game_data():
	db_ref.new_data_update.connect(new_data_updated)
	db_ref.patch_data_update.connect(patch_data_updated)

func new_data_updated(data):
	print("new data")
	print(data)

	# Accede directamente a las propiedades sin hacer cast
	if data.key != null and data.data != null:
		GlobalData.hospital_data[data.key] = data.data
		#print("Datos actualizados en GlobalData:", GlobalData.hospital_data)

func patch_data_updated(data):
	print("patch data")
	print(data)

	# Accede directamente a las propiedades
	if data.key != null and data.data != null:
		GlobalData.hospital_data[data.key] = data.data
		#print("Datos actualizados en GlobalData:", GlobalData.hospital_data)

func _on_timer_timeout():
	get_tree().change_scene_to_file("res://Mundo.tscn")
	pass # Replace with function body.
