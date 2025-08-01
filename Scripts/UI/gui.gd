extends CanvasLayer
class_name GUI
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var death_hint: Label = $DeathHint
@onready var hint_timer: Timer = $HintTimer

signal timerUp()

func _on_timer_timeout() -> void:
	if not hint_timer.is_stopped(): return
	progress_bar.value+=0.2
	if progress_bar.value == 60:
		timerUp.emit()
		resetProgress()

func resetProgress() -> void:
	progress_bar.value = 0


func _on_hint_timer_timeout() -> void:
	death_hint.queue_free()
	Managers.self_management.spawn_ghost()
	Managers.self_management.clearEverything()
	Managers.self_management.player.death_gap.start()
	Managers.self_management.player.global_position = Managers.self_management.playerStartingLocation
	Managers.self_management.player.show()
	Managers.self_management.player.set_process(true)
	Managers.self_management.boss.reset()
	
