extends Node2D
class_name SwirlAttack

@onready var bullet_source: BulletSource = $BulletSource
@onready var bullet_source2: BulletSource = $BulletSource2

func _on_timer_timeout() -> void:
	bullet_source.global_rotation = wrapf(bullet_source.global_rotation+PI/16,0,PI)
	bullet_source2.global_rotation = wrapf(bullet_source2.global_rotation+PI/16,0,PI)
	# I would like to make this so that it goes back and forth instead of snapping back to the top
	if randf() >= 0.5: bullet_source.fire()
	else: bullet_source2.fire()
