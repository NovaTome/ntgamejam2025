class_name SelfManagement
extends Node2D

@onready var player: Player = $Player
@onready var player_path: Path2D = $PlayerPath

@export var ghost_scene: PackedScene 

var life_ticks_passed: int = 0
var previous_player_pos: Vector2

# Reference of all player moves
# I could see the size of this getting out of hand
var biography: Dictionary[int, HistoryPoint] = {}

# This should probably be in process later
func _on_life_tick_timeout():
	life_ticks_passed += 1
	if (previous_player_pos != player.position):
		player_path.curve.add_point(player.position)
	previous_player_pos = player.position
	record_to_biography(life_ticks_passed)
	progress_ghosts(life_ticks_passed)

# updates the biography of all player moves
func record_to_biography(tick: int):
	biography[tick] = HistoryPoint.new(
		player_path.curve.get_baked_length(),
		player.rotation,
		player.record_fire())

# ticks the ghost further on their own replication of the biography
func progress_ghosts(tick: int):
	var path_children = player_path.get_children()
	for child in path_children:
		if child.has_method("progress_life"):
			child.progress_life(tick)

# Gives a unqiue copy so new moves aren't added to the ghost 
# We should consider setting cut off indexs for memory
func clone_biograhy() -> Dictionary[int, HistoryPoint]:
	return biography.duplicate(false)

# Spawns a ghost with clone biography
func spawn_ghost():
	var new_ghost:Ghost = ghost_scene.instantiate()
	new_ghost.initalize(life_ticks_passed, clone_biograhy())
	player_path.add_child(new_ghost)

# Debug method for creating ghosts
func _unhandled_input(event):
	if event.is_action_pressed("spawn"):
		spawn_ghost()
