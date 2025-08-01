extends CanvasLayer
class_name GUI
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var death_hint: Label = $DeathHint
@onready var hint_timer: Timer = $HintTimer
@onready var jump_scare: Sprite2D = $JumpScare

signal timerUp()

func _on_timer_timeout() -> void:
	if not hint_timer.is_stopped(): return
	progress_bar.value+=0.2
	if progress_bar.value == 60:
		timerUp.emit()
		resetProgress()

func resetProgress() -> void:
	progress_bar.value = 0

func startJumpScare() -> void:
	jump_scare.show()
	var tween = get_tree().create_tween()
	var fullColor:Color = jump_scare.self_modulate
	fullColor.a = 1
	tween.tween_property(jump_scare,"self_modulate",fullColor,3)
	tween.tween_callback(jump_scare.hide)

func _on_hint_timer_timeout() -> void:
	death_hint.queue_free()
	Managers.self_management.spawn_ghost()
	Managers.self_management.clearEverything()
	Managers.self_management.player.death_gap.start()
	Managers.self_management.player.global_position = Managers.self_management.playerStartingLocation
	Managers.self_management.player.show()
	Managers.self_management.player.set_process(true)
	if Managers.self_management.boss != null: Managers.self_management.boss.reset()
	
