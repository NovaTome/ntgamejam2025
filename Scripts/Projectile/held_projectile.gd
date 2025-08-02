class_name HeldProjectile
extends Projectile

var held: bool = true

func _process(delta):
	if (!held):
		super._process(delta)
		if velocity == Vector2.ZERO: queue_free()

func release():
	held = false
