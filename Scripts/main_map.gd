extends Node2D
class_name MainMap

@export var enemy_scene_normal:PackedScene = preload("res://Scenes/Entities/Enemies/regular_enemy.tscn")
@export var enemy_scene_ghost:PackedScene = preload("res://Scenes/Entities/Enemies/ghost_enemy.tscn")
@export var enemy_scene_homing:PackedScene = preload("res://Scenes/Entities/Enemies/homing_enemy.tscn")

var enemyQueue:Array[Dictionary] = []
@export var canProgress:bool = false
@export var bitchMode:bool = false

enum DIRECTION {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT
}

@onready var enemy_spawners: Node2D = $EnemySpawners
@onready var timer:Timer = $SpawnTimer
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var boss_marker:Marker2D = $BossMarker
@onready var player_marker:Marker2D = $PlayerBossMarker

var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	if get_parent() is not MainGame:
		printerr("Main map needs to be a child of a MainGame node!")

func _process(delta: float) -> void:
	if canProgress:
		if Managers.self_management.get_children().filter(func(a): return a is Enemy).is_empty():
			get_parent().state+=1
			canProgress = false

func resetEnemies() -> void:
	if get_parent().state == MainGame.STATE.BOSS: return
	animation_player.stop()
	for e:Enemy in Managers.self_management.get_children().filter(func(a): return a is Enemy):
		e.queue_free()
	for p:Projectile in Managers.bullet_manager.get_children():
		p.queue_free()
	
	animation_player.play("stage_"+str(get_parent().state))

func setUpBossPhase() -> void:
	Managers.self_management.player.global_position = player_marker.global_position
	Managers.self_management.playerStartingLocation = player_marker.global_position
	Managers.self_management.boss.global_position = boss_marker.global_position
	Managers.self_management.clearEverything()
	Managers.self_management.player.connect("died",Managers.self_management.boss.reset)
	for n:Node2D in Managers.self_management.get_children().filter(func(a): return a is Enemy or a is Ghost):
		n.queue_free()
	for p:Projectile in Managers.bullet_manager.get_children():
		p.queue_free()
	Managers.self_management.boss.reset()

func spawn_enemy(spawnPoint:Marker2D, type: Enums.EnemyType = Enums.EnemyType.NORMAL):
	var enemy:Enemy
	if type == Enums.EnemyType.NORMAL:
		enemy = enemy_scene_normal.instantiate()
	if type == Enums.EnemyType.GHOST:
		enemy = enemy_scene_ghost.instantiate()
	if type == Enums.EnemyType.HOMING:
		enemy = enemy_scene_homing.instantiate()
	enemy.global_position = spawnPoint.global_position
	enemy.target = Managers.self_management.player
	Managers.self_management.add_child(enemy)

func spawnAd(num:int,type:Enums.EnemyType,spawnDir:DIRECTION) -> void:
	if num == 1:
		spawn_enemy(getEnemySpawner(spawnDir),type)
	else:
		for i in num:
			enemyQueue.append({"type":type, "spawnPoint": getEnemySpawner(spawnDir)})
		timer.start(0.2)

func getRandomEnemySpawner() -> Marker2D:
	var allMarkers:Array = enemy_spawners.get_children().filter(func(a): return a is Marker2D)
	return allMarkers.get(rng.randi_range(0,allMarkers.size()-1))

func getEnemySpawner(dir:DIRECTION) -> Marker2D:
	var allMarkers:Array= enemy_spawners.get_children().filter(func(a): return a is Marker2D)
	return allMarkers.get(dir)

func getBulletSource(dir:DIRECTION) -> BulletSource:
	return get_node("Bullet_"+str(dir))


func _on_spawn_timer_timeout() -> void:
	var toSpawn:Dictionary = enemyQueue.pop_front()
	spawn_enemy(toSpawn.spawnPoint,toSpawn.type)
	if enemyQueue.is_empty(): timer.stop()
