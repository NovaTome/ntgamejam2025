extends Node
class_name SoundManager

enum SOUNDS {
	RUMBLING,
	EXPLOSION,
	DEATH,
	SPIDER,
	JUMPSCARE,
	GUNSHOT,
	CRYSTAL_SPAWN,
	CRYSTAL_DEATH,
	ROAR,
	FIRE,
	CLOCK,
	RINGER
}

enum MUSIC {
	MAIN,
	BOSS
}

const RUMBLING = preload("res://Assets/Sounds/rumbling.ogg")
var soundCooldown:Array[Dictionary] = []
var cooldownTimer:Timer = Timer.new()

func _ready() -> void:
	cooldownTimer.autostart = true
	cooldownTimer.wait_time = 0.1
	cooldownTimer.connect("timeout",handleCooldown)
	add_child(cooldownTimer)

var currentMusic:AudioStreamPlayer = null

func handleCooldown() -> void:
	soundCooldown = soundCooldown.filter(func(a): return Time.get_ticks_msec() < a.time+100)

func playSound(s:SOUNDS, source:Vector2) -> AudioStreamPlayer2D:
	if soundCooldown.find_custom(func(a): return a.sound == s) != -1:
		return null
	else: soundCooldown.append({"sound":s,"time":Time.get_ticks_msec()})
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
			return RUMBLING
		SOUNDS.EXPLOSION:
			return load("res://Assets/Sounds/explosion.ogg")
		SOUNDS.DEATH:
			return load("res://Assets/Sounds/death_bell.wav")
		SOUNDS.SPIDER:
			return load("res://Assets/Sounds/spider.ogg")
		SOUNDS.JUMPSCARE:
			return load("res://Assets/Sounds/jumpscare.ogg")
		SOUNDS.GUNSHOT:
			return load("res://Assets/Sounds/gunshot.ogg")
		SOUNDS.CRYSTAL_SPAWN:
			return load("res://Assets/Sounds/crystal_spawn.ogg")
		SOUNDS.CRYSTAL_DEATH:
			return load("res://Assets/Sounds/glass_breaking.wav")
		SOUNDS.ROAR:
			return load("res://Assets/Sounds/lion_roar.ogg")
		SOUNDS.FIRE:
			return load("res://Assets/Sounds/laser.wav")
		SOUNDS.CLOCK:
			return load("res://Assets/Sounds/ticking_clock.ogg")
		SOUNDS.RINGER:
			return load("res://Assets/Sounds/ghost.ogg")
	return null

func getMusic(m:MUSIC) -> AudioStream:
	match m:
		MUSIC.MAIN:
			return load("res://Assets/Sounds/menu_song.wav")
		MUSIC.BOSS:
			return load("res://Assets/Sounds/battle_song.wav")
	return null

func finishSound(instance:AudioStreamPlayer2D) -> void:
	instance.queue_free()

func playMusic(m:MUSIC) -> void:
	if currentMusic != null:
		currentMusic.stop()
		currentMusic.queue_free()
	
	var newMusic:AudioStreamPlayer = AudioStreamPlayer.new()
	
	newMusic.stream = getMusic(m)
	newMusic.volume_db-=10
	currentMusic = newMusic
	add_child(newMusic)
	currentMusic.play()
