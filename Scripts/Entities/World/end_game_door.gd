extends Area2D
class_name Door



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		pass #TODO: Process end of game
