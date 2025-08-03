extends CanvasLayer
class_name MainMenu

signal game_started()

@onready var main_menu = $MainMenuVBoxContainer
@onready var settings_menu = $SettingsMenuVBoxContainer

@onready var ghost_1 = $Ghost1
@onready var winner_ghost = $WinnerGhost
@onready var winner_text = $WinnerText

const WINNER_TEXT = "You won with %d ghosts!\nLet us know how you did in the comments"

func _ready():
	if Managers.game_won:
		ghost_1.hide()
		winner_ghost.show()
		winner_text.text = WINNER_TEXT % Managers.game_won_ghosts
		winner_text.show()

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
