extends Node2D
class_name WaveAttack

const radius = 50
@export var projectile_scene:PackedScene = preload("res://Scenes/Entities/projectile.tscn")
var timesShot = 0


func _on_timer_timeout() -> void:
	var proj:Projectile = projectile_scene.instantiate()
	proj.shooter = CharacterBody2D.new()
	proj.destination = Vector2(radius,0).rotated((PI/8)*timesShot)
	proj.type = Projectile.TYPES.REGULAR
	add_child(proj)
	timesShot+=1
