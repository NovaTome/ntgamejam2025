class_name SelfManagement
extends Node2D

@onready var player: Player = $Player
@onready var boss:BossEnemy = $BossEnemy
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

var tutorialWaves:int = 0
var ghostsRemaining:int = 5:set=_set_ghost_count

func _ready() -> void:
	currentRotation = player.rotation #Probably redundant but eh
	player.connect("died",handlePlayerDeath)

func _process(delta: float) -> void:
	currentTicks+=1
	currentRotation = player.rotation

#On input, log what is happening to "bio"
func _input(event: InputEvent) -> void:
	if not gui.hint_timer.is_stopped(): return
	var inputTypes:Array[String] = ["left","up","down","right","fire"]
	if event is InputEventKey:
		for it:String in inputTypes:
			if event.is_action_pressed(it):
				addToInputArray(it)
			elif event.is_action_released(it):
				removeFromInputArray(it)

#Log current inputs and rotations to the command log
func logCommand() -> void:
	var newCommand:Command = Command.new(inputTickStart,currentTicks,inputs.duplicate(false),rotations.duplicate(false))
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
	if ghostsRemaining == 0: # If you have more than 5 ghosts, it will remove the oldest one
		var firstGhost:Ghost = get_children().filter(func(a): return a is Ghost).front()
		if firstGhost != null: firstGhost.queue_free()
	else: ghostsRemaining-=1
	var new_ghost:Ghost = ghost_scene.instantiate()
	new_ghost.commands = clone_bio()
	new_ghost.global_position = playerStartingLocation
	call_deferred("add_child",new_ghost)

# Clear all data for the next ghost
func clearEverything() -> void:
	gui.resetProgress()
	bio.clear()
	currentTicks = 0
	inputTickStart = 0
	inputs.clear()
	rotations.clear()

# Handle player death
func handlePlayerDeath() -> void:
	logCommand()
	if player.deaths == 0: # If it is their first death, give the tutorial
		gui.resetProgress()
		gui.startJumpScare()
		gui.death_hint.show()
		gui.hint_timer.start(3)
		player.hide()
		player.set_process(false)
		player.deaths+=1
		return
	player.deaths+=1
	spawn_ghost()
	clearEverything()
	player.global_position = playerStartingLocation
	player.death_gap.start()

# Only handles the tutorial wave to track if the person kept dying over and over again
func handleWaveEnd() -> void:
	tutorialWaves+=1
	if tutorialWaves <= player.deaths and tutorialWaves != 1:
		boss.reset()
		tutorialWaves = player.deaths

# Debug method for creating ghosts
func _unhandled_input(event):
	if event.is_action_pressed("spawn"):
		player.die()

# Logs any change in rotation to the rotation log
func _set_current_rotation(_rotation:float) -> void:
	if _rotation != currentRotation:
		rotations.append({"rotation":_rotation,"tick":currentTicks})
	currentRotation = _rotation

# Sets the ghost counter
func _set_ghost_count(_ghostsRemaining:int) -> void:
	ghostsRemaining = _ghostsRemaining
	gui.ghost_label.text = "Ghosts Remaining: " + str(ghostsRemaining)

func _on_gui_timer_up() -> void:
	player.die()
