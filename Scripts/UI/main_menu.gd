extends CanvasLayer
class_name MainMenu

signal game_started()

@onready var main_menu = $MainMenuVBoxContainer
@onready var settings_menu = $SettingsMenuVBoxContainer

func _on_start_button_pressed():
	game_started.emit()

func _on_settings_button_pressed():
	main_menu.hide()
	settings_menu.show()

func _on_return_button_pressed():
	settings_menu.hide()
	main_menu.show()

func _on_quit_button_pressed():
	get_tree().quit()
