extends Node
class_name CommandNode

signal firedShot(who:CharacterBody2D,pos:Vector2)

@export var character:CharacterBody2D

func _ready() -> void:
	if character == null:
		if get_parent() is CharacterBody2D: character = get_parent()
		else: printerr("No CharacterBody assigned to Command Node!")

func processCommand(cmd:Command) -> void:
	var manager:SelfManagement = character.manager
	character.movement_direction = Vector2.ZERO
	for i:String in cmd.inputs:
		match i:
			"up":
				character.movement_direction.y = -1
			"down":
				character.movement_direction.y = 1
			"left":
				character.movement_direction.x = -1
			"right":
				character.movement_direction.x = 1
			"fire":
				if not cmd.singleUse: manager.fire_shot(character,cmd.pos,Projectile.TYPES.ENEMY if character is Player else Projectile.TYPES.ENEMY_GHOST)
	character.movement_direction = character.movement_direction.normalized()
	cmd.singleUse = true
