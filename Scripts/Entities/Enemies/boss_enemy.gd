extends CharacterBody2D
class_name BossEnemy

@export var waveAttack:PackedScene = preload("res://Scenes/Entities/Attacks/wave_attack.tscn")

@onready var bullet_source: BulletSource = $BulletSource
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var phase:int = 0

func reset() -> void:
	show()
	animation_player.play("phase_"+str(phase))

func fireWaveAttack() -> void:
	var wave:WaveAttack = waveAttack.instantiate()
	wave.global_position = bullet_source.origin.global_position
	get_parent().add_child(wave)
