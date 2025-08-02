extends Node2D
class_name WaveAttack

signal finished()

const radius = 5000
@export var projectile_scene:PackedScene = preload("res://Scenes/Entities/Projectiles/square_projectile.tscn")
@export var bullet_source_scene:PackedScene = preload("res://Scenes/Entities/Projectiles/Source/bullet_source.tscn")
@export var DEBUG_MODE:bool = true
var allProjects:Array[Projectile] = []

func _ready() -> void:
	fire()

func fire() -> void:
	var rotate = (PI/2)
	while rotate < 3*PI/2:
		var proj:BulletSource = bullet_source_scene.instantiate()
		proj.projectile = projectile_scene
		rotate += PI/16
		proj.projectile_type = Projectile.TYPES.REGULAR
		proj.group = "WaveAttack"
		proj.connect("ready",handleProjectileReady.bind(proj,rotate))
		call_deferred("add_child",proj)

func handleProjectileReady(proj:BulletSource, rotate:float) -> void:
	proj.origin.global_position = global_position
	proj.direction.global_position = Vector2(radius,0).rotated(rotate)
	var projectile:Projectile = proj.fire()
	allProjects.append(projectile)

func _process(delta: float) -> void:
	for p:Projectile in Managers.bullet_manager.get_children().filter(func(a:Node2D): return a.is_in_group("WaveAttack")):
		if p.get_overlapping_areas().filter(func(a): return a.is_in_group("WaveAttack")).size() == 0:
			p.scale = Vector2(p.scale.x,p.scale.y+0.05)
	var allValidProjectiles:Array = allProjects.filter(func(a): return a != null)
	if DEBUG_MODE and allValidProjectiles.size() == 0:
		fire()
	elif allValidProjectiles.size() == 0:
		finished.emit()
		queue_free()
