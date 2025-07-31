class_name Ghost
extends CharacterBody2D

var movement_direction: Vector2 = Vector2.ZERO
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var speed: int = 250
@onready var command_node: CommandNode = $CommandNode

#List of commands for the Ghost to use
var commands:Array[Command]

#Ticks from start of life
var currentTicks:int = 0

func _ready() -> void:
	sprite_2d.self_modulate.a = 0.5 #Make ghost transparent :3
	if commands.size() == 0:
		printerr("Ghost has no commands!")
		queue_free()

func _process(delta: float) -> void:
	movement_direction = Vector2.ZERO
	var currentCommand:Command = commands.front()
	if currentTicks < currentCommand.endTick: #Check if the top command should still be running
		if currentCommand.hasMovementCommands(): command_node.processMovement(currentCommand.inputs) #Handle all movement
		else:
			for i:String in currentCommand.inputs:
				command_node.processCommand(i) #Run through all inputs pressed at this time
		
		var validRotations:Array[Dictionary] = currentCommand.rotations.filter(func(a): return a.tick == currentTicks)
		if validRotations.size() != 0:
			rotation = validRotations.pop_front().rotation
		
	else: #If top command is expired, move to next command
		commands.pop_front()
		if commands.size() == 0: #Kill ghost when it has nothing to do
			queue_free()
			return
	currentTicks+=1

func _physics_process(delta: float) -> void:
	self.velocity = movement_direction * speed
	move_and_slide()
