extends BulletSource

@onready var cooldown = $Cooldown
@onready var burst = $Burst

@export var cooldown_time: float
@export var burst_time: float
@export var burst_amount: int
@export var spread: float
var burst_left=0

func _ready():
	cooldown.wait_time = cooldown_time
	burst.wait_time = burst_time

func fire():
	if cooldown.is_stopped():
		burst_left = burst_amount
		inner_fire()
		burst.start()
		cooldown.start()

func inner_fire():
	# randomly move the direaction for spread
	var rand = randf_range(-spread, spread)
	rotation_degrees = rand
	super.fire()
	rotation_degrees = 0

func _on_burst_timeout():
	if burst_left == 0:
		return
	else:
		burst_left -= 1
		inner_fire()
		burst.start()
