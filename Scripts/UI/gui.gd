extends CanvasLayer
class_name GUI

# Clock textures
@onready var clock_face: TextureRect = $ClockFaceTextureRect
@onready var clock_hand: TextureRect = $ClockFaceTextureRect/ClockHandTextureRect

@onready var death_hint: Label = $DeathHint
@onready var hint_timer: Timer = $HintTimer
@onready var jump_scare: TextureRect = $JumpScare
@onready var ghost_label: Label = $LabelBox/GhostLabel
@onready var ringer_label: Label = $LabelBox/RingerLabel
@onready var enemy_label: Label = $LabelBox/EnemyLabel
@onready var ringer_clock:AnimatedSprite2D = $RingerClock
@onready var ringer_hint = $RingerHint
@onready var crystal_hint = $CrystalHint

signal timerUp()
signal ringer_unlocked()

const CLOCK_MAX: int = 300
const CLOCK_TICK_COUNT = 12;
const CLOCK_TICK_INTERVAL: int = CLOCK_MAX / CLOCK_TICK_COUNT;

const PHASE_ONE_RINGER_UNLOCK: float = CLOCK_MAX / 4
const PHASE_TWO_RINGER_UNLOCK: float = CLOCK_MAX / 2
const PHASE_THREE_RINGER_UNLOCK:float = CLOCK_MAX * (3/4)
var ringer_unlock: Array[float] = [CLOCK_TICK_INTERVAL, PHASE_ONE_RINGER_UNLOCK]

const DEADRINGER_HINT_1: String = "Press 'R' to embrace The Deadringer"
const DEADRINGER_HINT_2: String = "You have five seconds to create an eternal loop."

var player_rings: int = 0:
	set(value):
		player_rings = value	
		ringer_label.text = "Ringer Remaining " + str(value)
		update_ringer_hint()

var clock_progress: int = 0
var ringer_clock_on: bool = false:
	set(value):
		if (value):
			ringer_clock.show()
			clock_face.hide()
			ringer_clock.play("default")
			set_ring_timer()
		else:
			ringer_clock.hide()
			clock_face.show()
		ringer_clock_on = value
		update_ringer_hint()

func _ready():
	SignalBus.phase_change.connect(_handle_phase_change)
	ghost_label.text = "Ghosts Remaining: " + str(GameConstants.STARTING_MAX_GHOSTS)

func hideAll() -> void:
	for n in get_children():
		if n is Control: n.hide()

func showAll() -> void:
	var hiddenElements:Array = [death_hint,jump_scare,ringer_clock, ringer_hint, crystal_hint]
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
	
	if !ringer_unlock.is_empty() \
 		&& ringer_clock_on == false \
		&& clock_progress >= ringer_unlock.front():
			ringer_unlock.pop_front()
			ringer_unlocked.emit()
	
	# At the end of the clock, time's up
	if clock_progress == CLOCK_MAX:
		timerUp.emit()
		resetProgress()

func resetProgress() -> void:
	clock_progress = 0

func startJumpScare(str:String) -> void:
	jump_scare.self_modulate.a = 0.5
	jump_scare.show()
	death_hint.text = str
	death_hint.show()
	var tween = get_tree().create_tween()
	var fullColor:Color = jump_scare.self_modulate
	fullColor.a = 1
	tween.tween_property(jump_scare,"self_modulate",fullColor,3)
	tween.tween_callback(jump_scare.hide)
	tween.tween_callback(death_hint.hide)

func updateEnemyLabel() -> void:
	var enemySize:int = Managers.self_management.get_children().filter(func(a): return a is Enemy).size()
	enemy_label.text = "Enemies remaining: " + str(enemySize)

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
	Managers.self_management.check_for_held_actions()
	if Managers.self_management.boss != null: Managers.self_management.boss.reset()
	

func _on_ringer_clock_animation_finished() -> void:
	ringer_clock_on = false

func _handle_phase_change(phase: int):
	if phase == 1:
		ringer_unlock.append(PHASE_ONE_RINGER_UNLOCK)
	if phase == 2:
		ringer_unlock.append(PHASE_TWO_RINGER_UNLOCK)
	if phase == 3:
		ringer_unlock.append(PHASE_THREE_RINGER_UNLOCK)

func update_ringer_hint():
	if ringer_clock_on:
		ringer_hint.text = DEADRINGER_HINT_2
		ringer_hint.show()
		return
	
	if player_rings > 0:
		ringer_hint.text = DEADRINGER_HINT_1
		ringer_hint.show()
		return
	
	ringer_hint.hide()
