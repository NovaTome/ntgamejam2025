extends CanvasLayer
class_name GUI

# Clock textures
@onready var clock_face: TextureRect = $ClockFaceTextureRect
@onready var clock_hand: TextureRect = $ClockFaceTextureRect/ClockHandTextureRect

@onready var death_hint: Label = $DeathHint
@onready var hint_timer: Timer = $HintTimer
@onready var jump_scare: TextureRect = $JumpScare
@onready var ghost_label: Label = $GhostLabel
@onready var ringer_label: Label = $RingerLabel
@onready var ringer_clock:AnimatedSprite2D = $RingerClock

signal timerUp()
signal ringer_unlocked()

const CLOCK_MAX: int = 300
const CLOCK_TICK_COUNT = 12;
const CLOCK_TICK_INTERVAL: int = CLOCK_MAX / CLOCK_TICK_COUNT;

const default_ringer_unlock = [CLOCK_TICK_INTERVAL, CLOCK_MAX / 2, CLOCK_MAX]
var ringer_unlock = default_ringer_unlock.duplicate()

var clock_progress: int = 0

func _ready():
	ghost_label.text = "Ghosts Remaining: " + str(GameConstants.STARTING_MAX_GHOSTS)

func hideAll() -> void:
	for n in get_children():
		if n is Control: n.hide()

func showAll() -> void:
	var hiddenElements:Array = [death_hint,jump_scare,ringer_clock]
	for n in get_children():
		if n is Control and not hiddenElements.has(n): n.show()

# Fires every time the Timer node triggers
func _on_timer_timeout() -> void:
	if not hint_timer.is_stopped(): return
	
	# Advance internal progress and rotate the clock hand
	clock_progress += 1
	clock_hand.set_rotation_degrees(360 * (clock_progress / float(CLOCK_MAX)))
	
	# If we hit a tick mark on the clock, render the next clock face
	if clock_progress % CLOCK_TICK_INTERVAL == 0:
		var clock_face_asset_index = 1 + clock_progress / CLOCK_TICK_INTERVAL
		clock_face.texture = load("res://Assets/Clock/TheClock-%02d.png" % clock_face_asset_index)
	
	if !ringer_unlock.is_empty() && clock_progress >= ringer_unlock.front():
		ringer_unlock.pop_front()
		ringer_unlocked.emit()
	
	# At the end of the clock, time's up
	if clock_progress == CLOCK_MAX:
		timerUp.emit()
		resetProgress()

func resetProgress() -> void:
	clock_progress = 0

func startJumpScare() -> void:
	jump_scare.show()
	var tween = get_tree().create_tween()
	var fullColor:Color = jump_scare.self_modulate
	fullColor.a = 1
	tween.tween_property(jump_scare,"self_modulate",fullColor,3)
	tween.tween_callback(jump_scare.hide)

func set_ring_timer() -> void:
	clock_progress = floor(CLOCK_MAX * 0.90);

func _on_hint_timer_timeout() -> void:
	death_hint.hide()
	Managers.self_management.spawn_ghost()
	Managers.self_management.clearEverything()
	Managers.self_management.player.death_gap.start()
	Managers.self_management.player.global_position = Managers.self_management.playerStartingLocation
	Managers.self_management.player.show()
	Managers.self_management.player.set_process(true)
	if Managers.self_management.boss != null: Managers.self_management.boss.reset()
	


func _on_ringer_clock_animation_finished() -> void:
	ringer_clock.hide()
	clock_face.show()
