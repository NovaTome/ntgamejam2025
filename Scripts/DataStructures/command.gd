extends Resource
class_name Command

var executor:CharacterBody2D
@export var startTick:int = 0 #The tick from start of life in which the collection of inputs started
@export var endTick:int = 0 #The last tick in which this collection of inputs were processed
@export var inputs:Array[String] = [] #What inputs were being pressed at this time
@export var rotations:Array[Dictionary] = []
var pos:Vector2 = Vector2.ZERO
var singleUse:bool = false

func _init(_executor:CharacterBody2D, start:int = 0, end:int = 0, _inputs:Array[String] = [], _rotations:Array[Dictionary] = []) -> void:
	executor = _executor
	startTick = start
	endTick = end
	inputs = _inputs
	rotations = _rotations

func hasMovementCommands() -> bool:
	var inputTypes:Array[String] = ["left","up","down","right"]
	for i:String in inputs:
		if inputTypes.has(i): return true
	return false
