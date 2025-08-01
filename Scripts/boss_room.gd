extends Node2D
class_name BossRoom

@onready var self_management = $SelfManagement
@onready var bullet_manager = $BulletManager
@onready var sound_manager: SoundManager = $SoundManager
@onready var spawners:Node2D = $EnemySpawners

func _ready():
	Managers.bullet_manager = bullet_manager
	Managers.self_management = self_management
	Managers.sound_manager = sound_manager
	Managers.self_management.player.connect("died",Managers.self_management.boss.reset)
