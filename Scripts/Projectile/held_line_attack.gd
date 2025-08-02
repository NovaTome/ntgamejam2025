class_name HeldLineAttack
extends Node2D

var attack_progress: float = 0
@export var speed = 1 

@onready var moving_bullet_pattern: PathFollow2D = $Path2D/MovingBulletPattern
@onready var bullet_source:BulletSource = $Path2D/MovingBulletPattern/BulletSource

var held_bullets: Array[Projectile]
var target: Node2D


func _ready():
	moving_bullet_pattern.rotates = false

func _process(delta):
	attack_progress += delta * speed
	if attack_progress < 1:
		moving_bullet_pattern.progress_ratio = attack_progress
	else:
		for bullet in held_bullets:
			if is_instance_valid(bullet) && bullet is HeldProjectile:
				release_bullet(bullet)
		queue_free()

func release_bullet(bullet: HeldProjectile):
	bullet.release()

func _on_fire_timer_timeout():
	held_bullets.append(bullet_source.fire())
