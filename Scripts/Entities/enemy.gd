extends CharacterBody2D
class_name Enemy

var manager:SelfManagement

@export var canTargetPlayer:bool = true
@export var canTargetGhosts:bool = true

@onready var aggro_range: Area2D = $AggroRange
@onready var attack_range: Area2D = $AttackRange
@onready var attack_timer: Timer = $AttackTimer

var target:CharacterBody2D

var movement_direction: Vector2 = Vector2.ZERO
@export var speed: int = 125
@export var projectileType:Projectile.TYPES = Projectile.TYPES.REGULAR

func _ready() -> void:
	if get_parent() is SelfManagement:
		manager = get_parent()
	else:
		printerr("Enemy has no manager!")
		queue_free()
		return

func _process(delta: float) -> void:
	movement_direction = Vector2.ZERO
	if target != null and not attack_range.get_overlapping_bodies().has(target):
		movement_direction = global_position.direction_to(target.global_position).normalized()
	elif target != null and attack_range.get_overlapping_bodies().has(target) and attack_timer.is_stopped():
		manager.fire_shot(self,target.global_position,projectileType)
		attack_timer.start()
	
func _physics_process(delta: float) -> void:
	self.velocity = movement_direction * speed
	move_and_slide()

func canTargetBody(body: Node2D) -> bool:
	return (body is Ghost and canTargetGhosts) or (body is Player and canTargetPlayer)

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if canTargetBody(body):
		print("Bastard is in my sights")
		if target == null:
			target = body


func _on_attack_range_body_entered(body: Node2D) -> void:
	if canTargetBody(body) and target == body:
		print("Chat shoot this guy")


func _on_aggro_range_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
