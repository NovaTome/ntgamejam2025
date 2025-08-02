extends CanvasLayer
class_name MainGame

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gui: GUI = $SelfManagement/GUI
@onready var camera_2d: Camera2D = $Camera2D

@export var DEBUG_MODE:bool = true
