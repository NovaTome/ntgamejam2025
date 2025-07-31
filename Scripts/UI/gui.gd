extends CanvasLayer
class_name GUI
@onready var progress_bar: ProgressBar = $ProgressBar

signal timerUp()

func _on_timer_timeout() -> void:
	progress_bar.value+=0.2
	if progress_bar.value == 60:
		timerUp.emit()
		resetProgress()

func resetProgress() -> void:
	progress_bar.value = 0
