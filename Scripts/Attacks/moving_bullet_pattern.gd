extends PathFollow2D

@onready var bullet_source = $BulletSource

func _on_fire_timer_timeout():
	bullet_source.fire()
