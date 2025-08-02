extends StaticBody2D
class_name BossCrystal

signal destroyed()

@onready var sprite:AnimatedSprite2D = $Sprite2D

@export var health:float = 10:set=_set_health

func gotHit(proj:Projectile) -> void:
	health-= 1 if proj.type == Projectile.TYPES.ENEMY else 0.5

func _set_health(_health:float) -> void:
	health = _health
	var crackState = roundi(health/3)
	sprite.frame = clampi(2 - crackState,0,2)
	if health <= 0:
		destroyed.emit()
		queue_free()
