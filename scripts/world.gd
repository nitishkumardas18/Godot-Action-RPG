extends Node

var playercurrentattack = false
var currentscene = "world"

var score_label: Label
var level_label: Label
var combo_label: Label
var gold_label: Label

var perk_ui: Panel

func _ready():
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	
	# Score Label
	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.add_theme_color_override("font_color", Color(1, 1, 1))
	score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	score_label.position = Vector2(20, 20)
	canvas.add_child(score_label)
	
	# Gold Label
	gold_label = Label.new()
	gold_label.name = "gold_label"
	gold_label.add_theme_font_size_override("font_size", 40)
	gold_label.add_theme_color_override("font_color", Color(1, 0.9, 0))
	gold_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	gold_label.position = Vector2(250, 20)
	canvas.add_child(gold_label)
	
	# Level/XP Label
	level_label = Label.new()
	level_label.add_theme_font_size_override("font_size", 30)
	level_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	level_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	level_label.position = Vector2(20, 70)
	canvas.add_child(level_label)
	
	# Combo Label
	combo_label = Label.new()
	combo_label.add_theme_font_size_override("font_size", 50)
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
	combo_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	combo_label.position = Vector2(500, 20)
	canvas.add_child(combo_label)
	
	global.connect("combo_updated", Callable(self, "_on_combo_update"))
	global.connect("player_leveled_up", Callable(self, "_on_player_level_up"))
	
	setup_perk_ui(canvas)
	setup_pause_ui(canvas)
	
	# Minimap UI
	var minimap = load("res://scripts/minimap.gd").new()
	minimap.color = Color(0, 0, 0, 0.6) # Semi-transparent black
	minimap.custom_minimum_size = Vector2(150, 150)
	minimap.position = Vector2(1000, 20) # Top right corner
	minimap.size = Vector2(150, 150)
	canvas.add_child(minimap)
	
	# Spawn Bushes
	for i in range(15):
		var bush = load("res://scripts/bush.gd").new()
		bush.global_position = Vector2(randf_range(100, 1500), randf_range(100, 1000))
		add_child(bush)
		
	# Spawn Campfires
	for i in range(2):
		var camp = load("res://scripts/campfire.gd").new()
		camp.global_position = Vector2(randf_range(300, 1300), randf_range(300, 800))
		add_child(camp)
		
	# Spawn Chests
	for i in range(5):
		var chest = load("res://scripts/chest.gd").new()
		chest.global_position = Vector2(randf_range(200, 1500), randf_range(200, 1000))
		add_child(chest)
	
	# Spawn Pet Companion
	var pet = load("res://scripts/pet.gd").new()
	pet.global_position = Vector2(150, 150)
	add_child(pet)
	
	# Spawn Merchant
	var merchant = load("res://scripts/merchant.gd").new()
	merchant.global_position = Vector2(500, 300)
	add_child(merchant)
	
	# Touch Controls
	if DisplayServer.is_touchscreen_available() or OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		setup_mobile_controls(canvas)
	
	# Canvas Modulate for Day/Night Cycle
	var cm = CanvasModulate.new()
	cm.name = "DayNightModulate"
	add_child(cm)
	
	# Dynamic Weather (Rain)
	var rain = CPUParticles2D.new()
	rain.name = "RainParticles"
	rain.amount = 500
	rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain.emission_rect_extents = Vector2(1000, 10)
	rain.direction = Vector2(-0.2, 1)
	rain.spread = 5
	rain.gravity = Vector2(0, 800)
	rain.initial_velocity_min = 400
	rain.initial_velocity_max = 600
	rain.scale_amount_min = 1.0
	rain.scale_amount_max = 3.0
	rain.color = Color(0.6, 0.8, 1.0, 0.5)
	rain.position = Vector2(500, -200) # Follows camera in _process
	rain.z_index = 100
	add_child(rain)
	
	# Fireflies (Atmospheric glowing dots)
	var fireflies = CPUParticles2D.new()
	fireflies.name = "Fireflies"
	fireflies.amount = 40
	fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fireflies.emission_rect_extents = Vector2(1000, 1000)
	fireflies.gravity = Vector2(0, -10)
	fireflies.direction = Vector2(0, -1)
	fireflies.spread = 180
	fireflies.initial_velocity_min = 10
	fireflies.initial_velocity_max = 30
	fireflies.scale_amount_min = 2.0
	fireflies.scale_amount_max = 5.0
	fireflies.color = Color(1.0, 1.0, 0.0, 0.6) # Glowing yellow
	fireflies.position = Vector2(500, 500)
	fireflies.z_index = 90
	add_child(fireflies)
	
	add_child(canvas)

var pause_ui: Panel
var stats_label: Label

func setup_pause_ui(canvas):
	pause_ui = Panel.new()
	pause_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_ui.size = Vector2(500, 400)
	pause_ui.position = Vector2(1152/2 - 250, 648/2 - 200)
	pause_ui.visible = false
	
	var title = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 40)
	title.position = Vector2(160, 20)
	pause_ui.add_child(title)
	
	stats_label = Label.new()
	stats_label.text = "Stats"
	stats_label.add_theme_font_size_override("font_size", 20)
	stats_label.position = Vector2(50, 100)
	pause_ui.add_child(stats_label)
	
	var btn_resume = Button.new()
	btn_resume.text = "Resume Game"
	btn_resume.size = Vector2(200, 50)
	btn_resume.position = Vector2(150, 250)
	btn_resume.connect("pressed", Callable(self, "_resume_game"))
	pause_ui.add_child(btn_resume)
	
	var btn_quit = Button.new()
	btn_quit.text = "Quit to Menu"
	btn_quit.size = Vector2(200, 50)
	btn_quit.position = Vector2(150, 320)
	btn_quit.connect("pressed", Callable(self, "_quit_game"))
	pause_ui.add_child(btn_quit)
	
	canvas.add_child(pause_ui)

func _resume_game():
	pause_ui.visible = false
	get_tree().paused = false

func _quit_game():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func setup_perk_ui(canvas):
	perk_ui = Panel.new()
	perk_ui.process_mode = Node.PROCESS_MODE_ALWAYS # Still works when paused
	perk_ui.size = Vector2(600, 400)
	perk_ui.position = Vector2(1152/2 - 300, 648/2 - 200)
	perk_ui.visible = false
	
	var title = Label.new()
	title.text = "LEVEL UP! CHOOSE A PERK"
	title.add_theme_font_size_override("font_size", 35)
	title.add_theme_color_override("font_color", Color(0, 1, 0))
	title.position = Vector2(80, 20)
	perk_ui.add_child(title)
	
	var btn1 = Button.new()
	btn1.text = "Vampire: Heal to Full"
	btn1.position = Vector2(150, 100)
	btn1.size = Vector2(300, 60)
	btn1.connect("pressed", Callable(self, "_select_perk").bind("heal"))
	perk_ui.add_child(btn1)
	
	var btn2 = Button.new()
	btn2.text = "Ninja: +20 Speed"
	btn2.position = Vector2(150, 180)
	btn2.size = Vector2(300, 60)
	btn2.connect("pressed", Callable(self, "_select_perk").bind("speed"))
	perk_ui.add_child(btn2)
	
	var btn3 = Button.new()
	btn3.text = "Rich: +150 Gold"
	btn3.position = Vector2(150, 260)
	btn3.size = Vector2(300, 60)
	btn3.connect("pressed", Callable(self, "_select_perk").bind("gold"))
	perk_ui.add_child(btn3)
	
	canvas.add_child(perk_ui)

func _on_player_level_up():
	get_tree().paused = true
	perk_ui.visible = true

func _select_perk(type):
	var p = get_node_or_null("player")
	if type == "heal" and p:
		p.health = 100
	elif type == "speed" and p:
		p.speed += 20
	elif type == "gold":
		global.gold += 150
		
	perk_ui.visible = false
	get_tree().paused = false

var time_passed = 0.0

func setup_mobile_controls(canvas: CanvasLayer):
	# Up
	var btn_up = TouchScreenButton.new()
	btn_up.action = "ui_up"
	btn_up.position = Vector2(100, 380)
	setup_touch_btn_shape(btn_up, 40)
	canvas.add_child(btn_up)
	
	# Down
	var btn_down = TouchScreenButton.new()
	btn_down.action = "ui_down"
	btn_down.position = Vector2(100, 520)
	setup_touch_btn_shape(btn_down, 40)
	canvas.add_child(btn_down)
	
	# Left
	var btn_left = TouchScreenButton.new()
	btn_left.action = "ui_left"
	btn_left.position = Vector2(30, 450)
	setup_touch_btn_shape(btn_left, 40)
	canvas.add_child(btn_left)
	
	# Right
	var btn_right = TouchScreenButton.new()
	btn_right.action = "ui_right"
	btn_right.position = Vector2(170, 450)
	setup_touch_btn_shape(btn_right, 40)
	canvas.add_child(btn_right)
	
	# Attack
	var btn_attack = TouchScreenButton.new()
	btn_attack.action = "attack"
	btn_attack.position = Vector2(950, 450)
	setup_touch_btn_shape(btn_attack, 60)
	canvas.add_child(btn_attack)
	
	# Dash
	var btn_dash = TouchScreenButton.new()
	btn_dash.action = "dash"
	btn_dash.position = Vector2(800, 500)
	setup_touch_btn_shape(btn_dash, 40)
	canvas.add_child(btn_dash)
	
	# Magic
	var btn_magic = TouchScreenButton.new()
	btn_magic.action = "magic"
	btn_magic.position = Vector2(800, 400)
	setup_touch_btn_shape(btn_magic, 40)
	canvas.add_child(btn_magic)
	
	# Shuriken
	var btn_shuriken = TouchScreenButton.new()
	btn_shuriken.action = "shuriken"
	btn_shuriken.position = Vector2(900, 350)
	setup_touch_btn_shape(btn_shuriken, 40)
	canvas.add_child(btn_shuriken)
	
func setup_touch_btn_shape(btn: TouchScreenButton, radius: float):
	var shape = CircleShape2D.new()
	shape.radius = radius
	btn.shape = shape
	
	var grad = Gradient.new()
	grad.add_point(0.0, Color(1, 1, 1, 0.4))
	grad.add_point(1.0, Color(1, 1, 1, 0.0))
	
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.width = int(radius * 2)
	tex.height = int(radius * 2)
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	
	btn.texture_normal = tex
	# Offset to center the texture properly
	# TouchScreenButton position is the top-left of the texture if centered is false, but let's just leave it default
	btn.position -= Vector2(radius, radius)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not perk_ui.visible:
		if get_tree().paused:
			_resume_game()
		else:
			get_tree().paused = true
			pause_ui.visible = true
			var p = get_node_or_null("player")
			var p_speed = p.speed if p else 150
			var p_health = p.health if p else 700
			stats_label.text = "Player Level: " + str(global.level) + "\nMax Health: " + str(p_health) + "\nSpeed: " + str(p_speed) + "\nGold: " + str(global.gold)
			
	score_label.text = "Score: " + str(global.score)
	if gold_label:
		gold_label.text = "Gold: " + str(global.gold)
		
	# Follow Player for Weather
	var player = get_node_or_null("player")
	if player:
		var rain = get_node_or_null("RainParticles")
		if rain:
			rain.global_position = player.global_position + Vector2(0, -400)
		var fireflies = get_node_or_null("Fireflies")
		if fireflies:
			fireflies.global_position = player.global_position
	level_label.text = "Level: " + str(global.level) + " | XP: " + str(global.current_xp) + "/" + str(global.max_xp)
	
	if global.combo_timer > 0:
		global.combo_timer -= _delta
		if global.combo_timer <= 0:
			global.combo_count = 0
			global.emit_signal("combo_updated")
			
	# Day/Night Cycle (60 seconds for a full cycle)
	time_passed += _delta
	var cycle = (sin(time_passed * PI / 30.0) + 1.0) / 2.0 # Ranges from 0.0 (night) to 1.0 (day)
	var min_light = 0.2
	var val = min_light + cycle * (1.0 - min_light)
	var cm = get_node_or_null("DayNightModulate")
	if cm:
		cm.color = Color(val, val, val + 0.1)

func _on_combo_update():
	if global.combo_count > 1:
		combo_label.text = "Combo x" + str(global.combo_count) + "!"
		var tw = get_tree().create_tween()
		combo_label.scale = Vector2(1.5, 1.5)
		tw.tween_property(combo_label, "scale", Vector2(1, 1), 0.2)
	else:
		combo_label.text = ""
