extends CharacterBody2D
class_name Enemy

@onready var aggro_range: Area2D = $AggroRange
@onready var attack_range: Area2D = $AttackRange
@onready var attack_timer: Timer = $AttackTimer
@onready var bullet_source = $BulletSource
@onready var sprite:AnimatedSprite2D = $Sprite2D
@onready var no_texture: Sprite2D = $NoTexture

var target:CharacterBody2D

var movement_direction: Vector2 = Vector2.ZERO
@export var speed: int = 125
@export var projectileType:Projectile.TYPES = Projectile.TYPES.REGULAR

func _ready() -> void:
	Managers.self_management.gui.updateEnemyLabel()
	if Managers.map_manager.bitchMode:
		sprite.hide()
		no_texture.show()


func _process(delta: float) -> void:
	movement_direction = Vector2.ZERO
	if target != null and not attack_range.get_overlapping_bodies().has(target):
		movement_direction = global_position.direction_to(target.global_position).normalized()
	elif target != null and attack_range.get_overlapping_bodies().has(target) and attack_timer.is_stopped():
		look_at(target.global_position)
		Managers.sound_manager.playSound(SoundManager.SOUNDS.FIRE,global_position)
		bullet_source.fire()
		attack_timer.start()
	if not Managers.map_manager.bitchMode:
		if movement_direction != Vector2.ZERO and sprite.animation != "walk":
			sprite.play("walk")
		elif movement_direction == Vector2.ZERO and sprite.animation == "walk":
			sprite.play("default")
	
func _physics_process(delta: float) -> void:
	self.velocity = movement_direction * speed
	move_and_slide()

func canTargetBody(body: Node2D) -> bool:
	return body is Player

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if canTargetBody(body):
		if target == null:
			target = body


func _on_attack_range_body_entered(body: Node2D) -> void:
	if canTargetBody(body) and target == body:
		pass


func _on_tree_exited() -> void:
	Managers.self_management.gui.updateEnemyLabel()
