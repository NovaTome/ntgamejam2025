class_name Ghost
extends PathFollow2D # path follow has to be a direct child of path2d

@onready var ghost: Node2D = $Ghost

# time created on tick
var life_tick_created: int
var biography: Dictionary[int, HistoryPoint]

# the fact that you cant init packaged scenes is so dumb
# https://www.reddit.com/r/godot/comments/180oo9c/comment/ka75aqx/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
func initalize(p_life_tick: int, p_biography: Dictionary[int, HistoryPoint]):
	rotates = false # rotates causes the node to rotate with path direction instead of our own
	life_tick_created = p_life_tick
	biography = p_biography

# copy the moves of the biography according to the time given from it's creation
func progress_life(tick: int):
	var current_tick = get_current_life_tick(tick)
	if (current_tick <= biography.size()):
		var current_life_point = biography[current_tick]
		progress = current_life_point.curve_progress
		ghost.rotation = current_life_point.rotation
		

# Calculates the tick corisponding the manager life tick to the biography
func get_current_life_tick(tick: int) -> int:
	return tick - life_tick_created
