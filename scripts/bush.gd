extends StaticBody2D

var health = 50

func _ready():
	var sprite = Sprite2D.new()
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(0, 0.5, 0.1, 1), Color(0, 0.8, 0.2, 0)])
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 40
	tex.height = 40
	sprite.texture = tex
	add_child(sprite)
	
	var shape = CircleShape2D.new()
	shape.radius = 20.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
	# Set layers so player can collide and attack it
	collision_layer = 3 # Layer 1 & 2
	collision_mask = 3
	
	# Add Area2D to detect melee attack
	var detect_area = Area2D.new()
	var detect_col = CollisionShape2D.new()
	var detect_shape = CircleShape2D.new()
	detect_shape.radius = 25.0
	detect_col.shape = detect_shape
	detect_area.add_child(detect_col)
	detect_area.connect("body_entered", Callable(self, "_on_player_entered"))
	detect_area.connect("body_exited", Callable(self, "_on_player_exited"))
	add_child(detect_area)

func bush():
	pass

var player_in_attack_zone = false
var can_take_damage = true

func _on_player_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true

func _on_player_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false

func _physics_process(_delta):
	if player_in_attack_zone and global.player_current_attack and can_take_damage:
		health -= 45
		can_take_damage = false
		
		# Cooldown timer to prevent taking 60 hits a second
		var t = Timer.new()
		t.wait_time = 0.5
		t.one_shot = true
		t.connect("timeout", Callable(self, "reset_damage"))
		add_child(t)
		t.start()
		
		var dmg_lbl = Label.new()
		dmg_lbl.text = "Hit!"
		dmg_lbl.add_theme_font_size_override("font_size", 16)
		dmg_lbl.global_position = global_position + Vector2(0, -20)
		get_parent().add_child(dmg_lbl)
		var tw = get_tree().create_tween()
		tw.tween_property(dmg_lbl, "global_position:y", dmg_lbl.global_position.y - 20, 0.5)
		tw.tween_callback(dmg_lbl.queue_free)
		
		if health <= 0:
			if randf() < 0.4: # 40% drop berry
				var berry = load("res://scripts/berry.gd").new()
				berry.global_position = global_position
				get_parent().add_child(berry)
			elif randf() < 0.1: # 10% drop potion
				var potion = load("res://scripts/health_potion.gd").new()
				potion.global_position = global_position
				get_parent().add_child(potion)
			queue_free()

func reset_damage():
	can_take_damage = true
