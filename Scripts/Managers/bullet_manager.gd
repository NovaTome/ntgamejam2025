class_name BulletManager
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.bullet_fired.connect(fire_bullet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fire_bullet(bullet: Projectile, pos: Vector2, dir: Vector2):
	bullet.global_position = pos
	bullet.set_direction(dir)
	add_child(bullet)
