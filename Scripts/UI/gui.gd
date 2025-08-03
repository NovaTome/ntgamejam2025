extends CanvasLayer
class_name GUI

# Clock textures
@onready var clock_face: TextureRect = $ClockFaceTextureRect
@onready var clock_hand: TextureRect = $ClockFaceTextureRect/ClockHandTextureRect

@onready var death_hint: Label = $DeathHint
@onready var hint_timer: Timer = $HintTimer
@onready var jump_scare: TextureRect = $JumpScare
@onready var ghost_label: Label = $LabelBox/GhostLabel
@onready var enemy_label: Label = $LabelBox/EnemyLabel
@onready var ringer_clock:AnimatedSprite2D = $RingerClock
@onready var ringer_hint: Label = $TopHints/RingerHint
@onready var crystal_hint: Label = $TopHints/CrystalHint

var clockTickingSound:AudioStreamPlayer2D

@onready var ring_1 = $Rings/Ring1
@onready var ring_2 = $Rings/Ring2
@onready var ring_3 = $Rings/Ring3
@onready var ring_4 = $Rings/Ring4
@onready var rings = $Rings
@onready var unlock_1 = $ClockFaceTextureRect/Unlock1
@onready var unlock_2 = $ClockFaceTextureRect/Unlock2
@onready var unlock_3 = $ClockFaceTextureRect/Unlock3


signal timerUp()
signal ringer_unlocked()

const CLOCK_MAX: int = 300
const CLOCK_TICK_COUNT = 12;
const CLOCK_TICK_INTERVAL: int = CLOCK_MAX / CLOCK_TICK_COUNT;

const RINGER_ONE_UNLOCK: float = CLOCK_MAX / 4
const RINGER_THREE_UNLOCK:float = CLOCK_MAX * 3/4
var ring_1_unlocks = 0
var ring_3_unlocks = 0


const DEADRINGER_HINT_1: String = "Press 'R' to embrace The Deadringer"
const DEADRINGER_HINT_2: String = "You have five seconds to create an eternal loop."

var time_crystal_acknowledged:bool = false

var player_rings: int = 0:
	set(value):
		player_rings = value
		ring_1.hide()
		ring_2.hide()
		ring_3.hide()
		ring_4.hide()
		if value >= 1:
			ring_1.show()
		if value >= 2:
			ring_2.show()
		if value >= 3:
			ring_3.show()
		if value >= 4:
			ring_4.show()
			
		update_ringer_hint()

var clock_progress: int = 0:set=_set_clock_progress
var ringer_clock_on: bool = false:
	set(value):
		if (value):
			ringer_clock.show()
			clock_face.hide()
			rings.hide()
			ringer_clock.play("default")
			set_ring_timer()
		else:
			ringer_clock.hide()
			clock_face.show()
			rings.show()
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
	
	if ringer_clock_on == false:
		if ring_1_unlocks >= 1 && clock_progress >= RINGER_ONE_UNLOCK:
			ring_1_unlocks -= 1
			ringer_unlocked.emit()
			if ring_1_unlocks <= 0:
				unlock_1.hide()
		if ring_3_unlocks >= 1 && clock_progress >= RINGER_THREE_UNLOCK:
			ring_3_unlocks -= 1
			ringer_unlocked.emit()
			if ring_3_unlocks <= 0:
				unlock_3.hide()

	# At the end of the clock, time's up
	if clock_progress == CLOCK_MAX:
		timerUp.emit()
		resetProgress()

func resetProgress() -> void:
	clock_progress = 0
	crystal_hint.hide()
	clock_face.texture = load("res://Assets/Clock/TheClock-01.png")

func startJumpScare(str:String) -> void:
	Managers.sound_manager.playSound(SoundManager.SOUNDS.JUMPSCARE,Managers.self_management.player.global_position)
	jump_scare.self_modulate.a = 0.5
	jump_scare.show()
	death_hint.text = str
	death_hint.show()
	var tween = get_tree().create_tween()
	var fullColor:Color = jump_scare.self_modulate
	fullColor.a = 1
	tween.tween_property(jump_scare,"modulate",fullColor,3)
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
	unlock()

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

func handle_crystal_spawned():
	if not time_crystal_acknowledged:
		crystal_hint.show()

func hide_crystal_hint():
	if crystal_hint.visible:
		crystal_hint.hide()
	time_crystal_acknowledged = true

func _set_clock_progress(i:int) -> void:
	clock_progress = i
	var currentSecs:int = roundi(clock_progress/5)
	var secsRemaining:int = 60 - currentSecs
	print(secsRemaining)
	if secsRemaining <= 5 and secsRemaining > 0 and clockTickingSound == null:
		clockTickingSound = Managers.sound_manager.playSound(SoundManager.SOUNDS.CLOCK,Managers.self_management.player.global_position)
	elif secsRemaining > 5 and clockTickingSound != null:
		clockTickingSound.stop()
		clockTickingSound.queue_free()

func setup_clock_for_boss():
	unlock_1.show()
	unlock_3.show()
	ring_1_unlocks = 1
	ring_3_unlocks = 1
	resetProgress()

func unlock():
	unlock_1.show()
	unlock_3.show()
	ring_1_unlocks += 1
	ring_3_unlocks += 1
