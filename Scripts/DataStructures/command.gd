extends Resource
class_name Command

@export var startTick:int = 0 #The tick from start of life in which the collection of inputs started
@export var endTick:int = 0 #The last tick in which this collection of inputs were processed
@export var inputs:Array[String] = [] #What inputs were being pressed at this time
@export var rotations:Array[Dictionary] = [] # Tracks "rotation" - rotation value; "tick" - What tick the rotation was set at
#var pos:Vector2 = Vector2.ZERO # Used when dealing with commands that need a position (shooting only right now)
var singleUse:bool = false # Used to prevent multiple usages of an input that should only be used once

func _init(start:int = 0, end:int = 0, _inputs:Array[String] = [], _rotations:Array[Dictionary] = []) -> void:
	startTick = start
	endTick = end
	inputs = _inputs
	rotations = _rotations

func hasMovementCommands() -> bool:
	var inputTypes:Array[String] = ["left","up","down","right"]
	for i:String in inputs:
		if inputTypes.has(i): return true
	return false
