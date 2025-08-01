extends StaticBody2D
class_name BossCrystal

signal destroyed()

@export var health:float = 10:set=_set_health

func gotHit(proj:Projectile) -> void:
	health-= 1 if proj.type == Projectile.TYPES.ENEMY else 0.5

func _set_health(_health:float) -> void:
	health = _health
	if health <= 0:
		destroyed.emit()
		queue_free()
