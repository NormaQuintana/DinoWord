extends Control

func _ready():
	# Conexion con api de firebase
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)

func _on_b_ingresar_pressed() -> void:
	var correo = %Correo.text
	var contraseña = %"Contraseña".text
	Firebase.Auth.login_with_email_and_password(correo, contraseña)

func _on_b_cuenta_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/RegistrarCuenta.tscn")

func on_login_succeeded(auth):
	print(auth)
	print("login correcto")
	get_tree().change_scene_to_file("res://Escenas/loading_bar.tscn")

func on_login_failed(error_code, massage):
	print(error_code)
	print(massage)
	%Errores.text=traducir_error(massage)
	%Errores.visible=true

func traducir_error(error_code):
	if firebase_errores.has(error_code):
		return firebase_errores[error_code]
	return "Ocurrió un error desconocido. Inténtalo de nuevo."

# Diccionario para traducir errores
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
	"INVALID_LOGIN_CREDENTIALS":"Correo o contraseña invalidos.",
	"WEAK_PASSWORD : Password should be at least 6 characters" : "La contraseña debe tener al menos 6 caracteres."
}
