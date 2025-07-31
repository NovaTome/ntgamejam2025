#basic player class
class_name Player
extends CharacterBody2D

var movement_direction: Vector2 = Vector2.ZERO
@export var speed: int = 250
@onready var command_node: CommandNode = $CommandNode

# used to determine if next life tick should record fire
var _unrecorded_fire: bool = false

func _process(delta: float) -> void:
	_process_actions()

func _physics_process(delta):
	self.velocity = movement_direction * speed
	move_and_slide()

	#Cursor rotation
	look_at(get_global_mouse_position())

func _process_actions():
	
	var actions:Array[String] = []
	
	#Basic Movement
	if Input.is_action_pressed("up"):
		actions.append("up")
	if Input.is_action_pressed("down"):
		actions.append("down")
	if Input.is_action_pressed("left"):
		actions.append("left")
	if Input.is_action_pressed("right"):
		actions.append("right")
	
	command_node.processMovement(actions)
	
	# Actions
	if Input.is_action_just_pressed("fire"):
		command_node.processCommand("fire")
	
# used for SelfManagement to record the fire action
# sets to false after recorded
func record_fire() -> bool:
	var ret = _unrecorded_fire
	_unrecorded_fire = false
	return ret
	
