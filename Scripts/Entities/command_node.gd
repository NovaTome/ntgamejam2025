extends Node
class_name CommandNode

signal firedShot(who:CharacterBody2D,pos:Vector2)

@export var character:CharacterBody2D
var bullet_source: BulletSource

func _ready() -> void:
	if character == null:
		if get_parent() is CharacterBody2D: character = get_parent()
		else: printerr("No CharacterBody assigned to Command Node!")

func processCommand(cmd:Command) -> void:
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
				if not cmd.singleUse && bullet_source != null: bullet_source.fire()
	character.movement_direction = character.movement_direction.normalized()
	if character.movement_direction == Vector2.ZERO and character.sprite.animation == "walk":
		character.sprite.play("default")
	elif character.movement_direction != Vector2.ZERO and character.sprite.animation != "walk":
		character.sprite.play("walk")
	cmd.singleUse = true
