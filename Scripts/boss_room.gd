extends Node2D
class_name BossRoom

@export var enemy_scene_normal:PackedScene = preload("res://Scenes/Entities/Enemies/regular_enemy.tscn")
@export var enemy_scene_ghost:PackedScene = preload("res://Scenes/Entities/Enemies/ghost_enemy.tscn")
@export var enemy_scene_homing:PackedScene = preload("res://Scenes/Entities/Enemies/homing_enemy.tscn")



@onready var self_management = $SelfManagement
@onready var bullet_manager = $BulletManager
@onready var sound_manager: SoundManager = $SoundManager
@onready var spawners:Node2D = $EnemySpawners
@onready var timer:Timer = $Timer

var enemyQueue: Array[Enums.EnemyType]

func _ready():
	Managers.bullet_manager = bullet_manager
	Managers.self_management = self_management
	Managers.sound_manager = sound_manager
	Managers.self_management.player.connect("died",Managers.self_management.boss.reset)
	Managers.self_management.player.camera_2d.enabled = true

func spawnAd(num:int,type:Enums.EnemyType) -> void:
	if num == 1:
		spawn_enemy(type)
	else:
		for i in num:
			enemyQueue.append(type)
		timer.start(0.2)


func _on_timer_timeout() -> void:
	if !enemyQueue.is_empty():
		spawn_enemy(enemyQueue.pop_front())
	else:
		timer.stop()

func spawn_enemy(type: Enums.EnemyType = Enums.EnemyType.NORMAL):
	var marker:Marker2D = spawners.get_children().pick_random()
	var enemy:Enemy
	if type == Enums.EnemyType.NORMAL:
		enemy = enemy_scene_normal.instantiate()
	if type == Enums.EnemyType.GHOST:
		enemy = enemy_scene_ghost.instantiate()
	if type == Enums.EnemyType.HOMING:
		enemy = enemy_scene_homing.instantiate()
	enemy.global_position = marker.global_position
	enemy.target = self_management.player
	self_management.add_child(enemy)
