extends Node2D

@onready var mercury = $Mercury
@onready var venus = $Venus
@onready var mars = $Mars

@export var mercury_speed: float = 1
@export var venus_speed: float = 1
@export var mars_speed: float = 1

func _physics_process(delta):
	mercury.rotate(mercury_speed + delta)
	venus.rotate(venus_speed + delta)
	mars.rotate(mars_speed + delta)
