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

var destination:Vector2 = Vector2.ZERO
var lastChange:Vector2 = Vector2.ZERO
var shooter:CharacterBody2D

@export var speed:float = 4.0
@export var type:TYPES = TYPES.REGULAR
var velocity

func _ready() -> void:
	if destination == Vector2.ZERO:
		queue_free()
		return
	velocity = global_position.direction_to(destination).normalized() * speed
	look_at(destination)

func _process(delta: float) -> void:
	global_position += velocity
	if lastChangeIsZero(velocity):
		#print(velocity)
		queue_free()
	else: lastChange = velocity

func lastChangeIsZero(change:Vector2) -> bool:
	var deltaX = abs(lastChange.x + change.x)
	var deltaY = abs(lastChange.y + change.y)
	return deltaX < 0.01 && deltaY < 0.01

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
