extends Node2D
class_name SwirlAttack

@onready var bullet_source: BulletSource = $BulletSource

func _on_timer_timeout() -> void:
	bullet_source.fire()
	bullet_source.global_rotation = wrapf(bullet_source.global_rotation-PI/16,PI/2,3*PI/2)
	# I would like to make this so that it goes back and forth instead of snapping back to the top
