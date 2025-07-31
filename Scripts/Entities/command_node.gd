extends Node
class_name CommandNode

@export var character:CharacterBody2D

func _ready() -> void:
	if character == null:
		if get_parent() is CharacterBody2D: character = get_parent()
		else: printerr("No CharacterBody assigned to Command Node!")

func processMovement(movementInput:Array[String]) -> void:
	character.movement_direction = Vector2.ZERO
	for str:String in movementInput:
		match str:
			"up":
				character.movement_direction.y = -1
			"down":
				character.movement_direction.y = 1
			"left":
				character.movement_direction.x = -1
			"right":
				character.movement_direction.x = 1
			_:
				processCommand(str)
	character.movement_direction = character.movement_direction.normalized()

func processCommand(str:String) -> void:
	match str:
		"fire":
			pass
