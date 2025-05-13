extends Node

@export var dinosaurios: Array[CharacterBody2D]

func registrar_dinosaurio(dinosaurio_nodo: CharacterBody2D):
	if dinosaurio_nodo not in dinosaurios:
		dinosaurios.append(dinosaurio_nodo)

func desregistrar_dinosaurio(dinosaurio_nodo: CharacterBody2D):
	if dinosaurio_nodo in dinosaurios:
		dinosaurios.erase(dinosaurio_nodo)

func obtener_dinosaurios():
	return dinosaurios
