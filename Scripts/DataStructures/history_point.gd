# A point of player actions
class_name HistoryPoint
extends Object

# The length of the player path in pixels
var curve_progress: float
# The rotation of the player
var rotation: float 
# If the player had fired
var fire: bool

func _init(
	p_curve_progress: float,
	p_rotation: float,
	p_fire: bool):
		curve_progress = p_curve_progress
		rotation = p_rotation
		p_fire = fire
