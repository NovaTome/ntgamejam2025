#basic player class
class_name Player
extends CharacterBody2D

signal died()
signal ring_ability()

var movement_direction: Vector2 = Vector2.ZERO
@export var speed: int = 250
@onready var command_node: CommandNode = $CommandNode
@onready var ak_47_source: BulletSource = $AK47Source
@onready var death_gap: Timer = $DeathGap
@onready var camera_2d: Camera2D = $Camera2D
@onready var sprite:AnimatedSprite2D = $Sprite2D
@onready var hell_sprite:AnimatedSprite2D = $HellCircle

var deaths:int = 0
var dead:bool = false
var ringed: bool = false
var rings: int = 0

func _ready() -> void:
	command_node.bullet_source = ak_47_source

# used to determine if next life tick should record fire
var _unrecorded_fire: bool = false

func _process(delta: float) -> void:
	_process_actions()


func _physics_process(delta):
	self.velocity = movement_direction * speed
	move_and_slide()
	
	var mousePos:Vector2 = get_global_mouse_position()
	#Cursor rotation
	look_at(mousePos)
	if mousePos.x < global_position.x:
		flip(true)
	else:
		flip(false)

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
	if Input.is_action_pressed("ring"):
		if rings > 0:
			ring_ability.emit()
			ringer_on()
	
	# Actions
	if Input.is_action_just_pressed("fire"):
		command.inputs.append("fire")
		#command.pos = get_global_mouse_position()
		
	command_node.processCommand(command)

func killSelf() -> void:
	Managers.self_management.process_mode = Node.PROCESS_MODE_DISABLED
	hell_sprite.show()
	hell_sprite.play("default")

func die(cause: Enums.DeathType = Enums.DeathType.UNKNOWN) -> void:
	if ringed && cause == Enums.DeathType.ATTACK:
		return
	elif ringed and cause == Enums.DeathType.TIME:
		killSelf()
		return
	if not dead:
		dead = true
		Managers.sound_manager.playSound(SoundManager.SOUNDS.DEATH,global_position)
		died.emit()

func flip(on: bool):
	sprite.flip_v = on
	if (on):
		ak_47_source.position.y = -abs(ak_47_source.position.y)
	else:
		ak_47_source.position.y = abs(ak_47_source.position.y)
	

func ringer_on() -> void:
	rings -= 1
	ringed = true
	modulate = Color.YELLOW
	
func ringer_off() -> void:
	ringed = false
	modulate = Color.WHITE

func _on_death_gap_timeout() -> void:
	dead = false


func _on_hell_circle_animation_finished() -> void:
	Managers.self_management.process_mode = Node.PROCESS_MODE_INHERIT
	hell_sprite.hide()
	die(Enums.DeathType.UNKNOWN)
