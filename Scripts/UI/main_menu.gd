extends CanvasLayer
class_name MainMenu

signal game_started()

func _on_start_button_pressed() -> void:
	game_started.emit()

func _on_quit_button_pressed():
	get_tree().quit()
