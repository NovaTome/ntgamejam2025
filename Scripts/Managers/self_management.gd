class_name SelfManagement
extends Node2D

@onready var player: Player = $Player
@onready var boss:BossEnemy = $BossEnemy
@onready var playerStartingLocation:Vector2 = Vector2($Player.global_position)
@onready var gui:GUI = $GUI

@export var ghost_scene: PackedScene = preload("res://Scenes/Entities/ghost.tscn")
@export var ringer_ghost: PackedScene = preload("res://Scenes/Entities/ringer_ghost.tscn")
@export var projectile_scene:PackedScene = preload("res://Scenes/Entities/projectile.tscn")

var bio:Array[Command] = []

var currentTicks:int = 0 #Current tick from start of the program
var inputTickStart:int = 0 #Tick from when current set of inputs has been running
var inputs:Array[String] = [] #List of inputs currently pressed

var rotations:Array[Dictionary] = [] #Array of rotations with what tick they apply to
var currentRotation:float = 0:set=_set_current_rotation #Player's current rotation

var tutorialWaves:int = 0
var ghostsRemaining:int = GameConstants.STARTING_MAX_GHOSTS:set=_set_ghost_count

var ringer_activated = false
var ringer_position: Vector2

func _ready() -> void:
	currentRotation = player.rotation #Probably redundant but eh
	player.connect("died",handlePlayerDeath)
	player.connect("ring_ability", handle_ring_ability)

func _process(delta: float) -> void:
	currentTicks+=1
	currentRotation = player.rotation

#On input, log what is happening to "bio"
func _input(event: InputEvent) -> void:
	if not gui.hint_timer.is_stopped(): return
	var inputTypes:Array[String] = ["left","up","down","right","fire"]
	if event is InputEventKey or event is InputEventMouseButton:
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
	if bio.is_empty(): return
	if ghostsRemaining == 0: # If you have more than starting_max_ghosts ghosts, it will remove the oldest one
		var firstGhost:Ghost = get_children().filter(func(a): return a is Ghost).front()
		if firstGhost != null: firstGhost.queue_free()
	else: ghostsRemaining-=1
	var new_ghost:Ghost = ghost_scene.instantiate()
	new_ghost.commands = clone_bio()
	new_ghost.global_position = playerStartingLocation
	new_ghost.connect("died",handleGhostDeath)
	call_deferred("add_child",new_ghost)

func spawn_ringer_ghost():
	if bio.is_empty(): return
	if ghostsRemaining == 0: # If you have more than starting_max_ghosts ghosts, it will remove the oldest one
		var firstGhost:Ghost = get_children().filter(func(a): return a is Ghost).front()
		if firstGhost != null: firstGhost.queue_free()
	else: ghostsRemaining-=1
	var new_ghost:Ghost = ringer_ghost.instantiate()
	new_ghost.commands = clone_bio()
	new_ghost.global_position = ringer_position
	new_ghost.connect("died",handleGhostDeath)
	call_deferred("add_child",new_ghost)

func handleGhostDeath() -> void:
	pass

# Clear all data for the next ghost
func clearEverything() -> void:
	gui.resetProgress()
	bio.clear()
	currentTicks = 0
	inputTickStart = 0
	rotations.clear()

# Handle player death
func handlePlayerDeath() -> void:
	logCommand()
	if player.deaths == 0 and get_parent() is not BossRoom: # If it is their first death, give the tutorial
		gui.resetProgress()
		gui.startJumpScare()
		gui.death_hint.show()
		gui.hint_timer.start(3)
		player.hide()
		player.set_process(false)
		player.deaths+=1
		return
	
	player.deaths+=1
	var allGhosts = get_children().filter(func(a): return a is Ghost)
	ghostsRemaining = clampi(GameConstants.STARTING_MAX_GHOSTS-allGhosts.size(),0,GameConstants.STARTING_MAX_GHOSTS)
	for c in allGhosts:
		if c is Ghost:
			c.reload()
	if player.ringed:
		spawn_ringer_ghost()
	else:
		spawn_ghost()
	clearEverything()	
	
	player.global_position = playerStartingLocation
	player.death_gap.start()
	player.ringer_off()

# Only handles the tutorial wave to track if the person kept dying over and over again
func handleWaveEnd() -> void:
	tutorialWaves+=1
	if boss.phase != 0 and get_parent() is BossRoom:
		player.connect("died",boss.reset)
	if tutorialWaves <= player.deaths and tutorialWaves != 1:
		boss.reset()
		tutorialWaves = player.deaths
	elif tutorialWaves != 1:
		player.camera_2d.enabled = true
		boss.phase = 1
		if get_parent() is MainGame and get_parent().DEBUG_MODE: get_tree().change_scene_to_file("res://Scenes/boss_room.tscn")

func handle_ring_ability() -> void:
	clearEverything() 
	gui.set_ring_timer()
	gui.ringer_label.text = "Ringer Remaining " + str(player.rings)
	ringer_position = player.global_position

# Debug method for creating ghosts
func _unhandled_input(event):
	if event.is_action_pressed("spawn"):
		player.die(Enums.DeathType.DEBUG)

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
	player.die(Enums.DeathType.TIME)

func _on_gui_ringer_unlocked():
	player.rings += 1
	gui.ringer_label.text = "Ringer Remaining " + str(player.rings)
