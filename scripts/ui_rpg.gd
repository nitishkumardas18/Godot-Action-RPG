extends Control

var player_dead = false
var all_enemies_dead = false

func _ready():
	if all_enemies_dead:
		show_playagain()
	elif player_dead:
		show_tryagain()
	else:
		show_start()

func show_start():
	$MarginContainer/VBoxContainer.visible = true
	$MarginContainer/VBoxContainer2.visible = false
	$MarginContainer/VBoxContainer3.visible = false

func show_tryagain():
	$MarginContainer/VBoxContainer.visible = false
	$MarginContainer/VBoxContainer2.visible = true
	$MarginContainer/VBoxContainer3.visible = false

func show_playagain():
	$MarginContainer/VBoxContainer.visible = false
	$MarginContainer/VBoxContainer2.visible = false
	$MarginContainer/VBoxContainer3.visible = true

func _on_start_pressed():
	player_dead = false
	all_enemies_dead = false
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_tryagain_pressed():
	player_dead = false
	all_enemies_dead = false
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_playagain_pressed():
	player_dead = false
	all_enemies_dead = false
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func on_player_health_depleted():
	player_dead = true
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func on_all_enemies_defeated():
	all_enemies_dead = true
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
