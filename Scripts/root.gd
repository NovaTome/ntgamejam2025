extends Node2D

@onready var self_management = $MainGame/SelfManagement
@onready var bullet_manager = $MainGame/BulletManager
@onready var sound_manager: SoundManager = $SoundManager
@onready var main_menu: MainMenu = $MainMenu
@onready var main_game: MainGame = $MainGame

# Called when the node enters the scene tree for the first time.
func _ready():
	Managers.bullet_manager = bullet_manager
	Managers.self_management = self_management
	Managers.sound_manager = sound_manager
	Managers.map_manager = main_game.map

func _on_main_menu_game_started() -> void:
	main_menu.queue_free()
	main_game.show()
	main_game.gui.show()
	main_game.animation_player.play("tutorial")
	sound_manager.playSound(SoundManager.SOUNDS.RUMBLING,main_game.camera_2d.global_position)
	main_game.process_mode = Node.PROCESS_MODE_ALWAYS
