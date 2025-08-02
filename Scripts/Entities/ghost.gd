class_name Ghost
extends CharacterBody2D

signal died()

var movement_direction: Vector2 = Vector2.ZERO
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@export var speed: int = 250
@export var minLifeTime:int = 3
@onready var command_node: CommandNode = $CommandNode
@onready var death_timer: Timer = $DeathTimer
@onready var bullet_source = $BulletSource
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var startingLocation:Vector2

var manager:SelfManagement

#List of commands for the Ghost to use
var commands:Array[Command]
var oldCommands:Array[Command] = []

#Ticks from start of life
var currentTicks:int = 0
var secondsAlive:int = 0

var active: bool = true:
	get:
		return active
	set(value):
		visible = value
		active = value
		var deferred_set_collision = func():
			collision_shape_2d.disabled = !value
		deferred_set_collision.call_deferred()
		

func _ready() -> void:
	active = true
	startingLocation = global_position
	command_node.bullet_source = bullet_source
	sprite_2d.self_modulate.a = 0.5 #Make ghost transparent :3
	if commands.size() == 0:
		printerr("Ghost has no commands!")
		queue_free()
		return

func _process(delta: float) -> void:
	movement_direction = Vector2.ZERO
	if not death_timer.is_stopped(): return
	if not active: return
	if commands.size() == 0 and oldCommands.size() == 0: #Idk why this is happening
		died.emit()
		queue_free()
		return

	var currentCommand:Command = commands.front()
	if currentCommand == null: return

	if currentTicks < currentCommand.endTick: #Check if the top command should still be running
		command_node.processCommand(currentCommand)
		
		var validRotations:Array[Dictionary] = currentCommand.rotations.filter(func(a): return a.tick == currentTicks)
		if validRotations.size() != 0:
			rotation = validRotations.pop_front().rotation
			if (rotation_degrees < 0 and rotation_degrees < -180) or (rotation_degrees > 90 and rotation_degrees < 180):
				sprite_2d.flip_v = true
			else: sprite_2d.flip_v = false
			
		
	else: #If top command is expired, move to next command
		oldCommands.append(commands.pop_front())
		if commands.size() == 0: #Kill ghost when it has nothing to do
			death_timer.start(clampi(minLifeTime-secondsAlive,0.1,minLifeTime))
			return
	currentTicks+=1

func reload() -> void:
	global_position = startingLocation
	commands.append_array(oldCommands.duplicate(false))
	commands.sort_custom(func(a,b): return b.startTick > a.startTick)
	oldCommands.clear()
	currentTicks = 0
	secondsAlive = 0
	active = true
	for c:Command in commands.filter(func(a:Command): return a.singleUse):
		c.singleUse = false

func _physics_process(delta: float) -> void:
	self.velocity = movement_direction * speed
	move_and_slide()


func _on_death_timer_timeout() -> void:
	#reload()
	active = false


func _on_life_timer_timeout() -> void:
	secondsAlive+=1
