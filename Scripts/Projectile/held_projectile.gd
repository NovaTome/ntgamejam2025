class_name HeldProjectile
extends Projectile

var held: bool = true

func _process(delta):
	if (!held):
		super._process(delta)

func release():
	held = false
