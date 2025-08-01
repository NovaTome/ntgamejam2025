extends Node2D
class_name SwirlAttack

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var bullet_source: BulletSource = $Path2D/PathFollow2D/BulletSource


func _on_timer_timeout() -> void:
	bullet_source.fire()
	path_follow_2d.progress_ratio+=0.01
