extends CanvasLayer
class_name MainMenu

signal game_started()

func _on_start_button_pressed() -> void:
	game_started.emit()
