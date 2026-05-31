extends Control

func _ready():
	if global.player_dead:
		show_tryagain()
	else:
		show_start()


func show_start():
	$MarginContainer/VBoxContainer.visible = true
	$MarginContainer/VBoxContainer2.visible = false
	$MarginContainer/VBoxContainer3.visible = false
	
	if global.level > 1 or global.score > 0:
		# Add a Continue Button dynamically if it doesn't exist
		if not $MarginContainer/VBoxContainer.has_node("ContinueButton"):
			var btn = Button.new()
			btn.name = "ContinueButton"
			btn.text = "Continue (Level " + str(global.level) + ")"
			btn.add_theme_font_size_override("font_size", 40)
			btn.connect("pressed", Callable(self, "_on_continue_pressed"))
			$MarginContainer/VBoxContainer.add_child(btn)

func _on_continue_pressed():
	global.player_dead = false
	# Keep existing global stats
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func show_tryagain():
	$MarginContainer/VBoxContainer.visible = false
	$MarginContainer/VBoxContainer2.visible = true
	$MarginContainer/VBoxContainer3.visible = false
	
	if global.score > global.high_score:
		global.high_score = global.score
		global.save_game()
		
	var oops_label = $MarginContainer/VBoxContainer2/oops
	oops_label.text = "Oops! You Died.\nScore: " + str(global.score) + "\nHigh Score: " + str(global.high_score)

func show_playagain():
	$MarginContainer/VBoxContainer.visible = false
	$MarginContainer/VBoxContainer2.visible = false
	$MarginContainer/VBoxContainer3.visible = true

func _on_start_pressed():
	global.player_dead = false
	global.score = 0
	global.gold = 0
	global.level = 1
	global.current_xp = 0
	global.max_xp = 100
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_tryagain_pressed():
	global.player_dead = false
	global.score = 0
	global.gold = 0
	global.level = 1
	global.current_xp = 0
	global.max_xp = 100
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_playagain_pressed():
	global.player_dead = false
	global.score = 0
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func on_all_enemies_defeated():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
