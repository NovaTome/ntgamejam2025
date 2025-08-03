class_name HeldProjectile
extends Projectile

var held: bool = true

func _physics_process(delta):
	if (!held):
		super._physics_process(delta)
		if velocity == Vector2.ZERO: queue_free()

func release():
	held = false
