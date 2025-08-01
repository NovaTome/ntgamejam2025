class_name SelfManagement
extends Node2D

@onready var player: Player = $Player
@onready var playerStartingLocation:Vector2 = Vector2($Player.global_position)
@onready var gui:GUI = $GUI

@export var ghost_scene: PackedScene = preload("res://Scenes/Entities/ghost.tscn")
@export var projectile_scene:PackedScene = preload("res://Scenes/Entities/projectile.tscn")

var bio:Array[Command] = []

var currentTicks:int = 0 #Current tick from start of the program
var inputTickStart:int = 0 #Tick from when current set of inputs has been running
var inputs:Array[String] = [] #List of inputs currently pressed

var rotations:Array[Dictionary] = [] #Array of rotations with what tick they apply to
var currentRotation:float = 0:set=_set_current_rotation #Player's current rotation

func _ready() -> void:
	currentRotation = player.rotation #Probably redundant but eh
	player.connect("died",handlePlayerDeath)

func _process(delta: float) -> void:
	currentTicks+=1
	currentRotation = player.rotation

#On input, log what is happening to "bio"
func _input(event: InputEvent) -> void:
	var inputTypes:Array[String] = ["left","up","down","right","fire"]
	if event is InputEventKey:
		for it:String in inputTypes:
			if event.is_action_pressed(it):
				addToInputArray(it)
			elif event.is_action_released(it):
				removeFromInputArray(it)

func logCommand() -> void:
	var newCommand:Command = Command.new(inputTickStart,currentTicks,inputs.duplicate(false),rotations.duplicate(false))
	if newCommand.inputs.has("fire"): newCommand.pos = get_global_mouse_position()
	bio.append(newCommand)
	rotations.clear()

#Adds to the input array and logs it as a new command
func addToInputArray(str:String) -> void:
	if not inputs.has(str):
		logCommand()
		inputs.append(str)
		inputTickStart = currentTicks

#Removes from the input array and logs it as a new command
func removeFromInputArray(str:String) -> void:
	if inputs.has(str):
		logCommand()
		inputs.remove_at(inputs.find(str))
		inputTickStart = currentTicks

# Clones the list of commands
func clone_bio() -> Array[Command]:
	return bio.duplicate(false)

# Spawns a ghost with clone biography
func spawn_ghost():
	var new_ghost:Ghost = ghost_scene.instantiate()
	new_ghost.commands = clone_bio()
	new_ghost.global_position = playerStartingLocation
	call_deferred("add_child",new_ghost)

func fire_shot(executor:CharacterBody2D, pos: Vector2, type:Projectile.TYPES) -> void:
	var proj:Projectile = projectile_scene.instantiate()
	proj.shooter = executor
	proj.global_position = executor.global_position
	proj.destination = pos
	proj.type = type
	add_child(proj)

func handlePlayerDeath() -> void:
	logCommand()
	inputTickStart = currentTicks
	spawn_ghost()
	gui.resetProgress()
	bio.clear()
	currentTicks = 0
	inputTickStart = 0
	inputs.clear()
	rotations.clear()

# Debug method for creating ghosts
func _unhandled_input(event):
	if event.is_action_pressed("spawn"):
		player.die()

# Logs any change in rotation to the rotation log
func _set_current_rotation(_rotation:float) -> void:
	if _rotation != currentRotation:
		rotations.append({"rotation":_rotation,"tick":currentTicks})
	currentRotation = _rotation


func _on_gui_timer_up() -> void:
	player.die()
