# FirebaseManager.gd (Autoload)
extends Node

# Diccionario para almacenar los datos de los niveles recibidos desde Firebase
# La clave será el nombre del nivel (ej. "JoselineExpress", "cafeteria")
# El valor será otro diccionario con "frases", "ordenar", "vocabulario"
var level_data: Dictionary = {}

# Diccionario para almacenar las traducciones de los errores de firebase
var firebase_errores = {
	"EMAIL_NOT_FOUND": "El correo no está registrado.",
	"INVALID_PASSWORD": "La contraseña es incorrecta.",
	"USER_DISABLED": "La cuenta ha sido deshabilitada.",
	"EMAIL_EXISTS": "El correo ya está registrado.",
	"INVALID_EMAIL": "El formato del correo no es válido.",
	"WEAK_PASSWORD": "La contraseña es demasiado débil.",
	"TOO_MANY_ATTEMPTS_TRY_LATER": "Demasiados intentos, inténtalo más tarde.",
	"OPERATION_NOT_ALLOWED": "Esta operación no está permitida.",
	"CREDENTIAL_ALREADY_IN_USE": "Estas credenciales ya están en uso.",
	"INVALID_VERIFICATION_CODE": "El código de verificación no es válido.",
	"INVALID_ID_TOKEN": "El token de sesión es inválido o ha expirado.",
	"NETWORK_REQUEST_FAILED": "Error de conexión. Revisa tu conexión a Internet.",
	"WEAK_PASSWORD : Password should be at least 6 characters" : "La contraseña debe tener al menos 6 caracteres."
}

# Señal para emitir cuando los datos de un nivel se han cargado
signal level_data_loaded(level_name)
signal firebase_error(error_code_or_message)

# Referencia a la clase Firebase de tu plugin
# Asume que ya tienes el plugin Firebase configurado y el nodo principal Firebase agregado a tu escena principal
@onready var firebase_node = get_node("/root/Firebase") # Ajusta la ruta si es diferente

func _ready():
	if firebase_node:
		print("[FirebaseManager] Firebase node found.")
		firebase_node.authenticated.connect(_on_firebase_authenticated)
		firebase_node.auth_failed.connect(_on_firebase_auth_failed)
		# Solo conectaremos la señal de data_received de la referencia específica de la base de datos
		# firebase_node.request_completed.connect(_on_firebase_request_completed) # Esta ya no es tan útil aquí
		firebase_node.error_received.connect(_on_firebase_error_received)
	else:
		printerr("[FirebaseManager] ERROR: Firebase node not found at /root/Firebase. Make sure the plugin is enabled and the node is in your scene tree.")

func _on_firebase_authenticated(user_id):
	print("FirebaseManager: Login exitoso para el usuario: ", user_id)
	# Puedes cargar datos iniciales aquí o en tu escena de login/inicio

func _on_firebase_auth_failed(error_message):
	printerr("FirebaseManager: Error de autenticación: ", error_message)
	var translated_error = firebase_errores.get(error_message, "Error desconocido de autenticación: " + error_message)
	firebase_error.emit(translated_error)

func _on_firebase_error_received(request_id, error_message, error_code):
	printerr("FirebaseManager: Error de Firebase (ID: ", request_id, ", Código: ", error_code, ", Mensaje: ", error_message, ")")
	var translated_error = firebase_errores.get(error_message, "Error inesperado: " + error_message)
	firebase_error.emit(translated_error)

# --- Métodos públicos para solicitar y acceder a los datos de los niveles ---

# Función para cargar los datos de un nivel específico desde Firebase
func load_level_data(level_name: String):
	if firebase_node and firebase_node.database:
		print("[FirebaseManager] Solicitando datos para el nivel: ", level_name)
		
		# Usamos get_once_database_reference para obtener los datos una sola vez
		# La ruta en Firebase debe ser el nombre de tu nodo principal de niveles,
		# seguido del nombre del nivel. Por ejemplo: "niveles/casa"
		# Ajusta "levels/" si tu estructura es diferente.
		var db_ref = firebase_node.database.get_once_database_reference("levels/" + level_name)
		
		# Conectamos la señal data_snapshot_received para manejar los datos cuando lleguen
		db_ref.data_snapshot_received.connect(func(snapshot):
			_on_level_data_snapshot_received(level_name, snapshot)
		)
		# Conectamos la señal error_received de la referencia específica
		db_ref.error_received.connect(func(request_id, error_message_ref, error_code_ref):
			_on_firebase_error_received(request_id, error_message_ref, error_code_ref)
		)
		
		# No necesitas llamar a .get_data() en la referencia porque get_once_database_reference ya inicia la petición.
		# Solo asegúrate de que el método get_once_database_reference del plugin
		# se encarga de hacer la petición HTTP GET.
		
	else:
		printerr("[FirebaseManager] No se puede cargar datos, el nodo Firebase o su base de datos no está disponible.")
		firebase_error.emit("Firebase no inicializado correctamente.")

func _on_level_data_snapshot_received(level_name: String, snapshot):
	# 'snapshot.value' contendrá los datos del nodo Firebase.
	# Si el nodo no existe, snapshot.value será 'null'.
	if snapshot.value != null and snapshot.value is Dictionary:
		print("FirebaseManager: Datos recibidos para nivel '", level_name, "': ", snapshot.value)
		level_data[level_name] = snapshot.value
		print("[FirebaseManager] Datos del nivel '", level_name, "' almacenados.")
		level_data_loaded.emit(level_name) # Emitir señal para avisar que los datos están listos
	elif snapshot.value == null:
		printerr("FirebaseManager: No se encontraron datos para el nivel '", level_name, "'. Verifica la ruta en Firebase.")
		firebase_error.emit("No hay datos para el nivel '" + level_name + "'.")
	else:
		printerr("FirebaseManager: Datos recibidos para nivel '", level_name, "' no son un diccionario o tienen un formato inesperado: ", snapshot.value)
		firebase_error.emit("Formato de datos inesperado para el nivel '" + level_name + "'.")

# Función para obtener los datos de un nivel ya cargado
func get_level_data(level_name: String) -> Dictionary:
	if level_data.has(level_name):
		return level_data[level_name]
	printerr("[FirebaseManager] Datos del nivel '", level_name, "' no cargados.")
	return {}

# Función para obtener solo las frases de un nivel
func get_level_frases(level_name: String) -> Dictionary:
	var data = get_level_data(level_name)
	if data.has("frases") and data["frases"] is Dictionary:
		return data["frases"]
	return {}

# Función para obtener solo las palabras a ordenar de un nivel
func get_level_ordenar(level_name: String) -> Dictionary:
	var data = get_level_data(level_name)
	if data.has("ordenar") and data["ordenar"] is Dictionary:
		return data["ordenar"]
	return {}

# Función para obtener solo el vocabulario de un nivel
func get_level_vocabulario(level_name: String) -> Dictionary:
	var data = get_level_data(level_name)
	if data.has("vocabulario") and data["vocabulario"] is Dictionary:
		return data["vocabulario"]
	return {}
