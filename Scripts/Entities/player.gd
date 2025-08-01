#basic player class
class_name Player
extends CharacterBody2D

signal died()

var movement_direction: Vector2 = Vector2.ZERO
@export var speed: int = 250
@onready var command_node: CommandNode = $CommandNode
@onready var bullet_source = $BulletSource

func _ready() -> void:
	command_node.bullet_source = bullet_source

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
	
	var command:Command = Command.new()
	
	#Basic Movement
	if Input.is_action_pressed("up"):
		command.inputs.append("up")
	if Input.is_action_pressed("down"):
		command.inputs.append("down")
	if Input.is_action_pressed("left"):
		command.inputs.append("left")
	if Input.is_action_pressed("right"):
		command.inputs.append("right")
	
	# Actions
	if Input.is_action_just_pressed("fire"):
		command.inputs.append("fire")
		#command.pos = get_global_mouse_position()
		
	command_node.processCommand(command)

func die() -> void:
	global_position = Vector2(0,0)
	died.emit()
