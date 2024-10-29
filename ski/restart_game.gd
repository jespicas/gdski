extends Node2D

var current_scene = "res://ski/restartGame.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.startGame()
	Globals.goto_Main()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	
