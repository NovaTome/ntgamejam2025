extends CanvasLayer
class_name MainGame

enum STATE {
	TUTORIAL,
	REG_ENEMY,
	GHOST_ENEMY,
	HOMING_ENEMY,
	BOSS
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gui: GUI = $SelfManagement/GUI
@onready var camera_2d: Camera2D = $Camera2D
@onready var map:MainMap = $MainMap

@export var DEBUG_MODE:bool = true
@export var state:STATE = STATE.TUTORIAL:set=_set_state

func toggleUI(show:bool) -> void:
	if show: gui.showAll()
	else: gui.hideAll()

func _set_state(s:STATE) -> void:
	state = s
	match state:
		STATE.BOSS:
			animation_player.play("boss")
		_:
			map.animation_player.play("stage_"+str(state))
