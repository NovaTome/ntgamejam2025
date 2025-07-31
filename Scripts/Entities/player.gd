#basic player class
class_name Player
extends CharacterBody2D

var movement_direction: Vector2 = Vector2.ZERO
@export var speed: int = 250

# used to determine if next life tick should record fire
var _unrecorded_fire: bool = false

func _physics_process(delta):
	_process_actions()

func _process_actions():
	movement_direction = Vector2.ZERO
	
	#Basic Movement
	if Input.is_action_pressed("up"):
		movement_direction.y = -1
	if Input.is_action_pressed("down"):
		movement_direction.y = 1
	if Input.is_action_pressed("left"):
		movement_direction.x = -1
	if Input.is_action_pressed("right"):
		movement_direction.x = 1
	movement_direction = movement_direction.normalized()
	self.velocity = movement_direction * speed
	move_and_slide()

	#Cursor rotation
	look_at(get_global_mouse_position())
	
	# Actions
	if Input.is_action_just_pressed("fire"):
		_unrecorded_fire = true
	
# used for SelfManagement to record the fire action
# sets to false after recorded
func record_fire() -> bool:
	var ret = _unrecorded_fire
	_unrecorded_fire = false
	return ret
	
