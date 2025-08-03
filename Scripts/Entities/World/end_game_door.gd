extends Area2D
class_name Door

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var mainGame:MainGame = Managers.map_manager.get_parent()
		mainGame.animation_player.play("end")
