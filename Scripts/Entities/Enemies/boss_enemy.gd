extends CharacterBody2D
class_name BossEnemy

signal resetting()

@export var waveAttack:PackedScene = preload("res://Scenes/Entities/Attacks/wave_attack.tscn")
@export var twinAttack:PackedScene = preload("res://Scenes/Entities/Attacks/twin_attack.tscn")
@export var explosionAttack:PackedScene = preload("res://Scenes/Entities/Attacks/ground_explosion.tscn")
@export var swirlAttack:PackedScene = preload("res://Scenes/Entities/Attacks/swirl_attack.tscn")
@export var crystalScene:PackedScene = preload("res://Scenes/Entities/Enemies/boss_crystal.tscn")
@export var homingAttack:PackedScene = preload("res://Scenes/Entities/Attacks/homing_attack.tscn")
@export var heldLineAttack:PackedScene = preload("res://Scenes/Entities/Attacks/held_line_attack.tscn")
@export var facingLineAttack:PackedScene = preload("res://Scenes/Entities/Attacks/held_facing_attack.tscn")

@export var endGameDoor:PackedScene = preload("res://Scenes/Entities/World/end_game_door.tscn")

@onready var bullet_source: BulletSource = $BulletSource
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var phase:int = 0:set=_phase_changed
@export var health:int = 3
@export var DEBUG_MODE:bool = true

var target:Player:get=_get_target

var currentTwinAttack:Node2D
var currentSwirlAttack:SwirlAttack

func _ready() -> void:
	animation_player.play("phase_"+str(phase))

func reset() -> void:
	resetting.emit()
	health = 3
	animation_player.play("RESET")
	for c:BossCrystal in Managers.self_management.get_children().filter(func(a): return a is BossCrystal):
		c.queue_free()
	stopAllAttacks()
	show()
	if DEBUG_MODE and phase == 0:
		phase = 1
	animation_player.play("phase_"+str(phase))

func die() -> void:
	var door:Door = endGameDoor.instantiate()
	door.global_position = global_position
	Managers.map_manager.add_child(door)
	queue_free()

func fireWaveAttack() -> WaveAttack:
	var wave:WaveAttack = waveAttack.instantiate()
	wave.global_position = bullet_source.origin.global_position
	get_parent().add_child(wave)
	return wave

func fireSwirlAttack() -> SwirlAttack:
	var swirl:SwirlAttack = swirlAttack.instantiate()
	swirl.global_position = bullet_source.origin.global_position
	get_parent().add_child(swirl)
	currentSwirlAttack = swirl
	return swirl

func fireTwinAttack() -> Node2D:
	var twin:Node2D = twinAttack.instantiate()
	twin.global_position = bullet_source.origin.global_position
	twin.rotation_degrees = 180
	get_parent().add_child(twin)
	currentTwinAttack = twin
	return twin

func fireGroundAttack() -> GroundExplosion:
	var groundAttack:GroundExplosion = explosionAttack.instantiate()
	groundAttack.global_position = target.global_position
	connect("resetting",groundAttack.queue_free)
	get_parent().add_child(groundAttack)
	return groundAttack

func fireHomingAttack() -> HomingAttack:
	var homing:HomingAttack = homingAttack.instantiate()
	homing.global_position = Managers.map_manager.getBulletSource(MainMap.DIRECTION.values().pick_random()).origin.global_position
	get_parent().add_child(homing)
	return homing

func fireBoxAttack() -> void:
	var up:Vector2 = Vector2(target.global_position.x,target.global_position.y-500)
	var down:Vector2 = Vector2(target.global_position.x,target.global_position.y+500)
	var left:Vector2 = Vector2(target.global_position.x-500,target.global_position.y)
	var right:Vector2 = Vector2(target.global_position.x+500,target.global_position.y)
	var vectors:Array[Vector2] = [up,right,down,left]
	var rot:float = 0
	for v:Vector2 in vectors:
		var lineAttack:HeldLineAttack = heldLineAttack.instantiate()
		lineAttack.global_position = v
		lineAttack.global_rotation_degrees = rot
		rot = wrapf(rot + 90, -180, 180)
		get_parent().call_deferred("add_child",lineAttack)

func fireFacingLineAttack() -> void:
	var fLA:FacingLineAttack = facingLineAttack.instantiate()
	fLA.global_position = global_position
	fLA.global_rotation_degrees = wrapf(fLA.global_rotation_degrees+180, -180, 180)
	get_parent().add_child(fLA)

func spawnCrystal() -> void:
	var crystal:BossCrystal = crystalScene.instantiate()
	var randomLocation:Vector2 = Vector2(global_position.x-randf_range(200,300),global_position.y+randf_range(0,200))
	crystal.global_position = randomLocation
	crystal.destroyed.connect(crystalDestroyed)
	Managers.self_management.add_child(crystal)

func spawnEnemy(num:int) -> void:
	var room = Managers.self_management.get_parent()
	var type:Enums.EnemyType= Enums.EnemyType.NORMAL
	if phase == 2 and randf() > 0.5: type = Enums.EnemyType.GHOST
	if room is MainGame:
		room.map.spawnAd(num,type,MainMap.DIRECTION.values().pick_random())
	elif room is BossRoom:
		room.spawnAd(num,type)

func stopAllAttacks() -> void:
	stopTwinAttack(false)
	#stopWaveAttack()
	stopSwirlAttack(false)
	#stopBoxAttack()
	for e:Enemy in Managers.self_management.get_children().filter(func(n): return n is Enemy):
		e.queue_free()
	for p:Projectile in Managers.bullet_manager.get_children():
		p.queue_free()

func stopSwirlAttack(hardStop:bool=false) -> void:
	if hardStop: 
		for p:Projectile in Managers.bullet_manager.get_children().filter(func(a:Projectile): return a.is_in_group("SwirlAttack")):
			p.queue_free()
	if currentSwirlAttack != null:
		currentSwirlAttack.queue_free()

func stopTwinAttack(hardStop:bool=false) -> void:
	if hardStop: 
		for p:Projectile in Managers.bullet_manager.get_children().filter(func(a:Projectile): return a.is_in_group("TwinAttack")):
			p.queue_free()
	if currentTwinAttack != null:
		currentTwinAttack.queue_free()

func stopWaveAttack() -> void:
	for p:Projectile in Managers.bullet_manager.get_children().filter(func(a:Projectile): return a.is_in_group("WaveAttack")):
		p.queue_free()

func stopBoxAttack() -> void:
	for p:Projectile in Managers.bullet_manager.get_children().filter(func(a:Projectile): return a.is_in_group("BoxAttack")):
		p.queue_free()

func connectTutorialWave() -> void:
	target = Managers.self_management.player
	Managers.sound_manager.playSound(SoundManager.SOUNDS.EXPLOSION, global_position)
	fireWaveAttack().connect("finished",Managers.self_management.handleWaveEnd)

func hitByProjectile(p:Projectile) -> void:
	pass

func crystalDestroyed() -> void:
	health-=1
	if health==0:
		phase+=1
		Managers.self_management.gui.resetProgress()
		if phase > 3:
			stopAllAttacks()
			animation_player.play("die")
		else: reset()

func _phase_changed(_phase:int) -> void:
	phase = _phase
	SignalBus.phase_change.emit(_phase)

func _get_target() -> Player:
	if target == null:
		target = Managers.self_management.player
	return target
