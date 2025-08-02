extends HeldLineAttack

func release_bullet(bullet: HeldProjectile):
	target = Managers.self_management.player
	bullet.look_at(target.global_position)
	bullet.direction = bullet.global_position.direction_to(target.global_position)
	bullet.release()
