extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func finishGame() -> void:
	Globals.addPoints(Globals.lives)
	$Player.stopPlayer()
	Globals.setStopGame()	
	$Control.position = $Player.position
	$Control.show()
#	if await Globals.ShouldAddScoreSilentWolf() == false:
#		$Control/Label.hide()
#		$Control/Label2.hide()
#		$Control/Yes.hide()
#		$Control/No.hide()
#		fillScores()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.lives == 0:
		finishGame()
	else:
		$Player/Control/Live.text = "Lives: " + str(Globals.lives)
		$Player/Control/Velocity.text = "Velocity: " + str(Globals.velocity).pad_decimals(2) + " m/s"
		$Player/Control/Points.text = "Points: " + str(Globals.points)
	pass

func _on_yes_pressed() -> void:
	print( "Yes")
	Globals.goto_Restart()
	pass # Replace with function body.

func _on_no_pressed() -> void:	
	#$Control/OnscreenKeyboard.show()
	# if should be add scores 
	if await Globals.ShouldAddScoreSilentWolf() == true:
		$Control/TextEdit.show()
		$Control/Yes.hide()
		$Control/No.hide()
		$Control/Label2.text = "Enter name max 3 digits"
		$Control/TextEdit.grab_focus()
	else:
		$Control/Yes.hide()
		$Control/No.hide()
		$Control/Label.hide()
		$Control/Label2.hide()
		fillScores()
	pass # Replace with function body.

func _input(event):
	if $Control/TextEdit.has_focus():
		if event is InputEventKey and event.is_pressed():
			var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			if OS.get_keycode_string(keycode) == "Enter" or event.keycode == 4194309 or OS.get_keycode_string(keycode) == "Kp Enter":
				$Control.grab_focus()
				#$Control/OnscreenKeyboard.hide()
				$Control/Label.hide()
				$Control/Label2.hide()
				$Control/Yes.hide()
				$Control/No.hide()
				$Control/TextEdit.hide()
				await SilentWolf.Scores.save_score($Control/TextEdit.text, Globals.points, "main")
				fillScores()
			print(OS.get_keycode_string(keycode))

func _on_text_edit_text_changed() -> void:
	if $Control/TextEdit.text.length() >=3 :
		$Control/TextEdit.text = $Control/TextEdit.text.substr(0,3)
		pass
	pass # Replace with function body.


func fillScores() -> void:
	$Control/Continue.show()
	$Control/WaitScores.show()
	$Control/Scores.clear()
	$Control/Scores.add_item("Name")
	$Control/Scores.add_item("Points")
	var records = await Globals.GetRecordsFromSilentWolf()
	for record in records:
		$Control/Scores.add_item(record["name"])
		$Control/Scores.add_item(str(record["score"]).pad_decimals(0))
		print(record)
	$Control/WaitScores.hide()
	$Control/Scores.show()		

func _on_continue_pressed() -> void:
	Globals.goto_Restart()
	pass # Replace with function body.

func _on_duration_game_timeout() -> void:
	finishGame()
	pass # Replace with function body.
