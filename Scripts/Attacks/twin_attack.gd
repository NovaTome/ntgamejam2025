extends Node2D

@onready var moving_bullet_pattern = $Path2D/MovingBulletPattern
@onready var moving_bullet_pattern_2 = $Path2D/MovingBulletPattern2
@onready var bullet_source = $Path2D/MovingBulletPattern/BulletSource
@onready var bullet_source_2 = $Path2D/MovingBulletPattern2/BulletSource

@export var speed_curve: Curve 

var speed = .2
var normal_progress = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	normal_progress += delta * speed
	if moving_bullet_pattern.progress_ratio + delta * speed >= 1 ||\
		moving_bullet_pattern.progress_ratio + delta * speed <= 0:
		speed = -speed 
	moving_bullet_pattern.progress_ratio = speed_curve.sample(normal_progress)
	moving_bullet_pattern_2.progress_ratio = speed_curve.sample(1 - normal_progress)

func _on_fire_timer_timeout():
	bullet_source.fire()
	bullet_source_2.fire()
