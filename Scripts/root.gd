extends Node2D

@onready var self_management = $SelfManagement
@onready var bullet_manager = $BulletManager

# Called when the node enters the scene tree for the first time.
func _ready():
	Managers.bullet_manager = bullet_manager
	Managers.self_management = self_management
