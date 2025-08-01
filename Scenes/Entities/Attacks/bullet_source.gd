class_name BulletSource
extends Node2D

@export var projectile: PackedScene 
@export var projectile_type: Projectile.TYPES

@onready var origin: Marker2D = $Origin
@onready var direction: Marker2D = $Direction

func fire():
	if projectile == null:
		print("NO PROJECTILE DEFINED!")
		return
	
	var bullet_instance: Projectile = projectile.instantiate()
	var bullet_direction = (direction.global_position - origin.global_position).normalized()
	if bullet_instance.type != projectile_type:
		bullet_instance.type = projectile_type
	bullet_instance.shooter = get_parent()
	SignalBus.bullet_fired.emit(bullet_instance, origin.global_position, bullet_direction)
