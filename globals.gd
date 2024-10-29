extends Node

var lives   : int
var points  : int
var velocity : float
var collisions : int 

var gameisPlaying = false
var giroscope = false

var current_scene = "res://ski/Test.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SilentWolf.configure(
	{
	"api_key": "{idkeysilenwolf}",
	"game_id": "{gameid}",
	"log_level": 1
 	 })

	SilentWolf.configure_scores({
	"open_scene_on_close": "res://ski/Test.tscn"
  	})
	pass # Replace with function body.

func startGame() -> void:
	lives = 5
	points = 0
	velocity = 0.0
	collisions = 0
	gameisPlaying = true

func setStopGame() -> void:
	gameisPlaying = false
	
func removeLive() -> void:
	lives = lives - 1
func addLive() -> void:
	lives = lives + 1

func updateVelocity(velo: float) -> void:
	velocity = velo

func addPoints(point: int) -> void:
	points = points + point
# Called every frame. 'delta' is the elapsed time since the previous frame.
func addCollisions() ->  void:
	collisions = collisions +1
	if collisions >= 1:
		lives = lives -1
		collisions = 0
		
func _process(delta: float) -> void:
	pass

func goto_Main():
	Globals.goto_scene("res://ski/Test.tscn")
	pass
		
func goto_Restart():
	Globals.goto_scene("res://ski/restartGame.tscn")
	pass
			
func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)
	
func _deferred_goto_scene(path):
	if is_instance_valid(current_scene):
		current_scene.free()
	
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)		


func GetRecordsFromSilentWolf():
	var sw_result = await SilentWolf.Scores.get_scores(0, "main").sw_get_scores_complete
	var scores = sw_result.scores
	var new_game = []
	var i = 0
	for score in scores:
		var gameRecord = {
			"score": score["score"],
			"name": score["player_name"]
		}
		if i < 5:
			new_game.append(gameRecord)
		i = i+1

	return new_game

func ShouldAddScoreSilentWolf() -> bool:
	var scores = await GetRecordsFromSilentWolf()
	if scores.size() >= 5:
		if str(scores[4]["score"]).to_int() >= str(points).to_int():
			print(str(points)+ " No add")
			return false
		else:
			return true
	else:
		return true	
