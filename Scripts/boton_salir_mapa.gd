extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var confirmacion_popup = $"ConfirmacionPopup"

func _on_pressed():
	confirmacion_popup.popup_centered()
