extends CharacterBody2D
class_name BossEnemy

signal resetting()

@export var waveAttack:PackedScene = preload("res://Scenes/Entities/Attacks/wave_attack.tscn")
@export var twinAttack:PackedScene = preload("res://Scenes/Entities/Attacks/twin_attack.tscn")
@export var explosionAttack:PackedScene = preload("res://Scenes/Entities/Attacks/ground_explosion.tscn")
@export var crystalScene:PackedScene = preload("res://Scenes/Entities/Enemies/boss_crystal.tscn")

@onready var bullet_source: BulletSource = $BulletSource
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var phase:int = 0:set=_phase_changed
@export var health:int = 3
@export var DEBUG_MODE:bool = true

var target:Player:get=_get_target

var currentTwinAttack:Node2D

func _ready() -> void:
	animation_player.play("phase_"+str(phase))

func reset() -> void:
	if phase > 0 and Managers.self_management.get_parent() is not BossRoom:
		return
	resetting.emit()
	animation_player.play("RESET")
	stopAllAttacks()
	show()
	if DEBUG_MODE and phase == 0:
		phase = 1
	animation_player.play("phase_"+str(phase))

func fireWaveAttack() -> WaveAttack:
	var wave:WaveAttack = waveAttack.instantiate()
	wave.global_position = bullet_source.origin.global_position
	get_parent().add_child(wave)
	return wave

func fireTwinAttack() -> Node2D:
	var twin:Node2D = twinAttack.instantiate()
	twin.global_position = bullet_source.origin.global_position
	twin.rotation_degrees = 90
	get_parent().add_child(twin)
	currentTwinAttack = twin
	return twin

func fireGroundAttack() -> GroundExplosion:
	var groundAttack:GroundExplosion = explosionAttack.instantiate()
	groundAttack.global_position = target.global_position
	connect("resetting",groundAttack.queue_free)
	get_parent().add_child(groundAttack)
	return groundAttack

func spawnCrystal() -> void:
	var crystal:BossCrystal = crystalScene.instantiate()
	var randomLocation:Vector2 = Vector2(global_position.x-randf_range(200,300),global_position.y+randf_range(-200,200))
	crystal.global_position = randomLocation
	crystal.destroyed.connect(crystalDestroyed)
	Managers.self_management.add_child(crystal)

func stopAllAttacks() -> void:
	stopTwinAttack(true)
	

func stopTwinAttack(hardStop:bool=false) -> void:
	if hardStop: 
		for p:Projectile in Managers.bullet_manager.get_children().filter(func(a:Projectile): return a.is_in_group("TwinAttack")):
			p.queue_free()
	if currentTwinAttack != null:
		currentTwinAttack.queue_free()

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
		if phase > 3: queue_free() # TODO: Handle boss death
		else: reset()

func _phase_changed(_phase:int) -> void:
	phase = _phase

func _get_target() -> Player:
	if target == null:
		target = Managers.self_management.player
	return target
