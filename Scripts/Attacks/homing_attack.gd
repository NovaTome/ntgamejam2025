extends Node2D
class_name HomingAttack

const radius = 5

@export var projectile_scene:PackedScene = preload("res://Scenes/Entities/square_projectile.tscn")
@export var bullet_source_scene:PackedScene = preload("res://Scenes/Entities/Attacks/bullet_source.tscn")

var timesFired:int = 0
var target

func _on_timer_timeout() -> void:
	if timesFired == 4:
		return
	if target == null:
		target = Managers.self_management.player
	timesFired+=1
	var proj:BulletSource = bullet_source_scene.instantiate()
	proj.projectile = projectile_scene
	proj.projectile_type = Projectile.TYPES.PLAYER
	proj.group = "HomingAttack"
	proj.connect("ready",handleProjectileReady.bind(proj))
	call_deferred("add_child",proj)
	

func handleProjectileReady(proj:BulletSource) -> void:
	proj.origin.global_position = Vector2(global_position.x,global_position.y)
	proj.direction.global_position = Vector2(radius,0)
	var projectile:Projectile = proj.fire()

func _process(delta: float) -> void:
	if timesFired == 4 and Managers.bullet_manager.get_children().filter(func(a:Node2D): return a.is_in_group("HomingAttack")).is_empty(): queue_free()
