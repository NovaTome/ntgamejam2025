extends Node2D
class_name WaveAttack

const radius = 5000
@export var projectile_scene:PackedScene = preload("res://Scenes/Entities/square_projectile.tscn")
@export var DEBUG_MODE:bool = true
var allProjects:Array[Projectile] = []

func _ready() -> void:
	fire()

func fire() -> void:
	var rotate = (PI/2)
	while rotate < 3*PI/2:
		var proj:Projectile = projectile_scene.instantiate()
		rotate += PI/16
		proj.shooter = CharacterBody2D.new()
		proj.global_position = global_position
		proj.destination = Vector2(radius,0).rotated(rotate)
		proj.type = Projectile.TYPES.REGULAR
		allProjects.append(proj)
		get_parent().call_deferred("add_child",proj)

func _process(delta: float) -> void:
	for p:Projectile in get_parent().get_children().filter(func(c): return c is Projectile):
		if p.get_overlapping_areas().size() == 0:
			p.scale = Vector2(p.scale.x,p.scale.y+0.05)
	if DEBUG_MODE and allProjects.filter(func(a): return a != null).size() == 0:
		fire()
