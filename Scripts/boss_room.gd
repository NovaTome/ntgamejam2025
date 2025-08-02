extends Node2D
class_name BossRoom

@export var enemyScene:PackedScene = preload("res://Scenes/Entities/Enemies/regular_enemy.tscn")

@onready var self_management = $SelfManagement
@onready var bullet_manager = $BulletManager
@onready var sound_manager: SoundManager = $SoundManager
@onready var spawners:Node2D = $EnemySpawners
@onready var timer:Timer = $Timer

var adsToSpawn:int = -1
var adType:Projectile.TYPES = Projectile.TYPES.REGULAR

func _ready():
	Managers.bullet_manager = bullet_manager
	Managers.self_management = self_management
	Managers.sound_manager = sound_manager
	Managers.self_management.player.connect("died",Managers.self_management.boss.reset)

func spawnAd(num:int,type:Projectile.TYPES) -> void:
	if num == 1:
		var marker:Marker2D = spawners.get_children().pick_random()
		var enemy:Enemy = enemyScene.instantiate()
		enemy.global_position = marker.global_position
		enemy.projectileType = type
		enemy.target = self_management.player
		self_management.add_child(enemy)
	else:
		adsToSpawn = num
		adType = type
		timer.start(0.2)


func _on_timer_timeout() -> void:
	var marker:Marker2D = spawners.get_children().pick_random()
	var enemy:Enemy = enemyScene.instantiate()
	enemy.global_position = marker.global_position
	enemy.projectileType = adType
	enemy.target = self_management.player
	self_management.add_child(enemy)
	adsToSpawn-=1
	if adsToSpawn == 0:
		timer.stop()
