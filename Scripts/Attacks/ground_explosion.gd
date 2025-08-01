extends Node2D
class_name GroundExplosion
@onready var area_2d: Area2D = $Area2D

func hitEveryoneInRadius() -> void:
	for b:Node2D in area_2d.get_overlapping_bodies():
		if b is Player:
			b.die()
		elif b is Ghost:
			b.reload()
