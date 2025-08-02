extends Node2D
class_name HomingAttack

const radius = 5
@onready var bullet_source: BulletSource = $BulletSource

@export var projectile_scene:PackedScene = preload("res://Scenes/Entities/Projectiles/square_projectile.tscn")
@export var bullet_source_scene:PackedScene = preload("res://Scenes/Entities/Projectiles/Source/bullet_source.tscn")

var timesFired:int = 0
var target

func _process(delta: float) -> void:
	if target == null: target = Managers.self_management.player

func moveBulletSource(x:float, y:float) -> void:
	bullet_source.global_position.x+=x
	bullet_source.global_position.y+=y

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
