#extends Control
#
#@onready var welcome_label = $Panel/MarginContainer/VBoxContainer/welcome
#@onready var start_button = $Panel/MarginContainer/VBoxContainer/start
#@onready var oops_label = $Panel/MarginContainer/VBoxContainer2/oops
#@onready var tryagain_button = $Panel/MarginContainer/VBoxContainer2/tryagain
#@onready var welldone_label = $Panel/MarginContainer/VBoxContainer3/welldone
#@onready var playagain_button = $Panel/MarginContainer/VBoxContainer3/playagain
#
#@onready var game_scene = preload("res://scenes/main_menu.tscn") as PackedScene
#
#func _ready():
#
	#show_start_menu()
	#
	## Button signals connect करें
	#start_button.pressed.connect(on_start_pressed)
	#tryagain_button.pressed.connect(on_tryagain_pressed)
	#playagain_button.pressed.connect(on_playagain_pressed)
#
#func show_start_menu():
	## Start menu state
	#welcome_label.visible = true
	#start_button.visible = true
	#oops_label.visible = false
	#tryagain_button.visible = false
	#welldone_label.visible = false
	#playagain_button.visible = false

#func show_game_over_menu():
	## Game over state
	#welcome_label.visible = false
	#start_button.visible = false
	#oops_label.visible = true
	#tryagain_button.visible = true
	#welldone_label.visible = false
	#playagain_button.visible = false
#
#func show_victory_menu():
	## Victory state
	#welcome_label.visible = false
	#start_button.visible = false
	#oops_label.visible = false
	#tryagain_button.visible = false
	#welldone_label.visible = true
	#playagain_button.visible = true	
#
#func on_start_pressed():
	## Start button 
	#get_tree().change_scene_to_string("res://scripts/world.gd")
#
#func on_tryagain_pressed():
	## Try again 
	#get_tree().change_scene_to_string("res://scripts/world.gd")
#
#func on_playagain_pressed():
	## Play again button 
	#get_tree().change_scene_to_string("res://scripts/world.gd")
#
#func health_detacted():	
	#show_game_over_menu()
