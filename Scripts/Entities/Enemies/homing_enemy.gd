extends Enemy
class_name HomingEnemy

func _process(delta: float) -> void:
	movement_direction = Vector2.ZERO
	look_at(target.global_position)
	if attack_range.get_overlapping_bodies().has(target):
		var dir:Vector2 = global_position.direction_to(target.global_position)*-1
		movement_direction = dir.normalized()


func _on_attack_timer_timeout() -> void:
	bullet_source.fire()
