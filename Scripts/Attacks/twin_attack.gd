extends Node2D

@onready var moving_bullet_pattern = $Path2D/MovingBulletPattern
@onready var moving_bullet_pattern_2 = $Path2D/MovingBulletPattern2

@export var speed_curve: Curve 

var speed = 1
var normal_progress = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	normal_progress += delta * speed
	if moving_bullet_pattern.progress_ratio + delta * speed >= 1 ||\
		moving_bullet_pattern.progress_ratio + delta * speed <= 0:
		speed = -speed 
	moving_bullet_pattern.progress_ratio = speed_curve.sample(normal_progress)
	moving_bullet_pattern_2.progress_ratio = speed_curve.sample(1 - normal_progress)
