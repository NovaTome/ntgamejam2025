class_name Ghost
extends CharacterBody2D

var movement_direction: Vector2 = Vector2.ZERO
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var speed: int = 250
@export var minLifeTime:int = 3
@onready var command_node: CommandNode = $CommandNode
@onready var death_timer: Timer = $DeathTimer

var manager:SelfManagement

#List of commands for the Ghost to use
var commands:Array[Command]
var oldCommands:Array[Command] = []

#Ticks from start of life
var currentTicks:int = 0
var secondsAlive:int = 0

func _ready() -> void:
	sprite_2d.self_modulate.a = 0.5 #Make ghost transparent :3
	if commands.size() == 0:
		printerr("Ghost has no commands!")
		queue_free()
		return
	if get_parent() is SelfManagement:
		manager = get_parent()
	else:
		printerr("Ghost has no manager!")
		queue_free()
		return

func _process(delta: float) -> void:
	movement_direction = Vector2.ZERO
	if not death_timer.is_stopped(): return
	var currentCommand:Command = commands.front()
	if currentTicks < currentCommand.endTick: #Check if the top command should still be running
		command_node.processCommand(currentCommand)
		
		var validRotations:Array[Dictionary] = currentCommand.rotations.filter(func(a): return a.tick == currentTicks)
		if validRotations.size() != 0:
			rotation = validRotations.pop_front().rotation
		
	else: #If top command is expired, move to next command
		oldCommands.append(commands.pop_front())
		if commands.size() == 0: #Kill ghost when it has nothing to do
			death_timer.start(clampi(minLifeTime-secondsAlive,0.1,minLifeTime))
			return
	currentTicks+=1

func reload() -> void:
	global_position = Vector2(0,0)
	commands = oldCommands.duplicate(false)
	oldCommands.clear()
	currentTicks = 0
	secondsAlive = 0
	for c:Command in commands.filter(func(a:Command): return a.singleUse):
		c.singleUse = false

func _physics_process(delta: float) -> void:
	self.velocity = movement_direction * speed
	move_and_slide()


func _on_death_timer_timeout() -> void:
	reload()


func _on_life_timer_timeout() -> void:
	secondsAlive+=1
