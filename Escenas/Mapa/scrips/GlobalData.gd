extends Node

# Diccionario para almacenar los datos recibidos desde Firebase
var hospital_data = {}

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
