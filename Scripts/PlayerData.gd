# PlayerData.gd
extends Node

var saved_life: int = 100
var saved_attack: int = 50
var huevitos_total: int = 1 

func reset_player_stats():
	saved_life = 100
	saved_attack = 50
	# No resetees huevitos_total aquí si quieres que persistan entre niveles completados
	# Si quisieras que los huevitos también se reinicien al inicio de cada nivel,
	# entonces sí, lo pondrías aquí: huevitos_total = 0 o 1
	print("Player stats reseteados a valores por defecto: Vida ", saved_life, ", Ataque ", saved_attack)
