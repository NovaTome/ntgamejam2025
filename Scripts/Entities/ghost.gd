class_name Ghost
extends CharacterBody2D

var movement_direction: Vector2 = Vector2.ZERO
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var speed: int = 250
@onready var command_node: CommandNode = $CommandNode
@onready var bullet_source = $BulletSource


var manager:SelfManagement

#List of commands for the Ghost to use
var commands:Array[Command]
var oldCommands:Array[Command] = []

#Ticks from start of life
var currentTicks:int = 0

func _ready() -> void:
	command_node.bullet_source = bullet_source
	sprite_2d.self_modulate.a = 0.5 #Make ghost transparent :3
	if commands.size() == 0:
		printerr("Ghost has no commands!")
		queue_free()
		return

func _process(delta: float) -> void:
	movement_direction = Vector2.ZERO
	var currentCommand:Command = commands.front()
	if currentTicks < currentCommand.endTick: #Check if the top command should still be running
		command_node.processCommand(currentCommand)
		
		var validRotations:Array[Dictionary] = currentCommand.rotations.filter(func(a): return a.tick == currentTicks)
		if validRotations.size() != 0:
			rotation = validRotations.pop_front().rotation
		
	else: #If top command is expired, move to next command
		oldCommands.append(commands.pop_front())
		if commands.size() == 0: #Kill ghost when it has nothing to do
			reload()
			return
	currentTicks+=1

func reload() -> void:
	global_position = Vector2(0,0)
	commands = oldCommands.duplicate(false)
	oldCommands.clear()
	currentTicks = 0
	for c:Command in commands.filter(func(a:Command): return a.singleUse):
		c.singleUse = false

func _physics_process(delta: float) -> void:
	self.velocity = movement_direction * speed
	move_and_slide()
