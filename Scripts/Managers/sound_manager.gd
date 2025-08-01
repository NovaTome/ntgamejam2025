extends Node
class_name SoundManager

enum SOUNDS {
	RUMBLING,
	EXPLOSION
}


var currentMusic:AudioStreamPlayer = null

func playSound(s:SOUNDS, source:Vector2) -> AudioStreamPlayer2D:
	var stream:AudioStream = getSound(s)
	if stream == null:
		printerr("SOUND NOT FOUND")
		return
	var instance = AudioStreamPlayer2D.new()
	instance.stream = stream
	instance.global_position = source
	instance.finished.connect(finishSound.bind(instance))
	add_child(instance)
	instance.play()
	return instance

func getSound(s:SOUNDS) -> AudioStream:
	match s:
		SOUNDS.RUMBLING:
			return load("res://Assets/Sounds/rumbling.ogg")
		SOUNDS.EXPLOSION:
			return load("res://Assets/Sounds/explosion.ogg")
	return null

func finishSound(instance:AudioStreamPlayer2D) -> void:
	instance.queue_free()

func playMusic() -> void:
	pass

func setCurrentMusic(newMusic:AudioStreamPlayer) -> void:
	print("here")
	currentMusic = newMusic
