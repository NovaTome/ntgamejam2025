extends Area2D
class_name Projectile

enum TYPES {
	REGULAR, #No homing, ghosts can block
	GHOST, # No homing, ghosts can't block
	PLAYER,  # Homing, ghosts need to block
	ENEMY, # Player projectile, can't hit ghost enemies, homing enemies can only be hit by players
	ENEMY_GHOST #Ghost projectile, can't hit homing enemies, ghost enemies can only be hit by ghosts
}

signal hit(target)
@onready var sprite_2d: Sprite2D = $Sprite2D

var direction:Vector2 = Vector2.ZERO
var shooter:Node2D

@export var speed:float = 4.0
@export var type:TYPES = TYPES.REGULAR
var velocity

func _ready() -> void:
	if type == TYPES.PLAYER:
		speed/=4

func _process(delta: float) -> void:
	if type == TYPES.PLAYER:
		direction = global_position.direction_to(shooter.target.global_position).normalized()
	velocity = direction * speed
	global_position += velocity

func set_direction(dir: Vector2) -> void:
	direction = dir
	rotation += dir.angle()
	if type == TYPES.PLAYER: #TODO: Make it so that homing missles actually rotate towards the person instead of using square projectiles
		global_rotation = global_position.angle_to(shooter.target.global_position)

func canHitBody(body:CharacterBody2D) -> bool:
	return body is Player or (body is Ghost and type != TYPES.GHOST) or (body is Enemy and (type == TYPES.ENEMY or type == TYPES.ENEMY_GHOST))

func _on_body_entered(body: Node2D) -> void:
	if body != shooter and canHitBody(body):
		hit.emit(body)
		if body is Player:
			body.die()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
