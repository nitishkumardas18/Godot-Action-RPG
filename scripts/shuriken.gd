extends Area2D

var direction = Vector2.RIGHT
var speed = 350.0
var damage = 35
var hit_enemies = []

func _ready():
	# Visuals: A spinning shuriken
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(0.8, 0.8, 0.8, 1), Color(0.2, 0.2, 0.2, 0)])
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_SQUARE
	tex.width = 24
	tex.height = 24
	
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = tex
	add_child(sprite)
	
	# Light
	var light = PointLight2D.new()
	var grad2 = Gradient.new()
	grad2.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var tex2 = GradientTexture2D.new()
	tex2.gradient = grad2
	tex2.fill = GradientTexture2D.FILL_RADIAL
	tex2.fill_from = Vector2(0.5, 0.5)
	tex2.fill_to = Vector2(0.5, 0.0)
	light.texture = tex2
	light.color = Color(0.8, 0.8, 1.0)
	light.energy = 1.0
	light.texture_scale = 1.5
	add_child(light)
	
	# Collision
	var shape = CircleShape2D.new()
	shape.radius = 12.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
	# Setup collision layers (hit enemy layer 2)
	collision_layer = 0
	collision_mask = 2 # Enemy layer
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Destroy after 3 seconds (Longer range than magic orb)
	var t = Timer.new()
	t.wait_time = 3.0
	t.autostart = true
	t.one_shot = true
	t.connect("timeout", Callable(self, "queue_free"))
	add_child(t)

func _physics_process(delta):
	global_position += direction * speed * delta
	var spr = get_node_or_null("Sprite")
	if spr:
		spr.rotation += 15.0 * delta # Spin very fast

func _on_body_entered(body):
	if hit_enemies.has(body):
		return
		
	if body.has_method("enemy") or body.has_method("bush"):
		hit_enemies.append(body)
		
		# Trick the enemy/bush into taking damage
		if body.has_method("enemy"):
			body.player_in_attack_zone = true
		else:
			# Bush has similar properties
			body.player_in_attack_zone = true
			
		global.player_current_attack = true
		
		var can_hit = false
		if "can_take_damage" in body:
			can_hit = body.can_take_damage
		elif body.has_method("bush"):
			can_hit = true
			
		if can_hit:
			var is_crit = randf() < 0.35 # 35% crit chance for shuriken!
			var final_damage = damage * 2 if is_crit else damage
			body.health -= final_damage
			
			if body.has_node("take_damage_cooldown"):
				body.get_node("take_damage_cooldown").start()
			if "can_take_damage" in body:
				body.can_take_damage = false
			
			if body.has_method("spawn_hit_particles"):
				body.spawn_hit_particles()
				
			# Knockback Juice
			var kb_dir = direction.normalized()
			var kb_tw = create_tween().bind_node(body)
			kb_tw.tween_property(body, "global_position", body.global_position + kb_dir * 15.0, 0.1)
			
			var dmg_lbl = Label.new()
			if is_crit:
				dmg_lbl.text = "CRIT! -" + str(final_damage)
				dmg_lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2)) # Bright Red
				dmg_lbl.add_theme_font_size_override("font_size", 26)
				global.hit_stop(0.05, 0.1) # Juicy hit stop
			else:
				dmg_lbl.text = "-" + str(final_damage)
				dmg_lbl.add_theme_font_size_override("font_size", 20)
				dmg_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1)) # Yellow for Shuriken
				
			dmg_lbl.global_position = body.global_position + Vector2(randf_range(-10, 10), -20)
			body.get_parent().add_child(dmg_lbl)
			var tw = get_tree().create_tween()
			tw.tween_property(dmg_lbl, "global_position:y", dmg_lbl.global_position.y - 40, 0.5)
			tw.tween_callback(dmg_lbl.queue_free)
			
			if body.health <= 0:
				global.score += 10
				global.gain_xp(40) # Grant XP
				
				# 30% chance to drop a health potion
				if randf() < 0.3:
					var potion = load("res://scripts/health_potion.gd").new()
					potion.global_position = body.global_position
					body.get_parent().add_child(potion)
					
				# 50% chance to drop gold coin
				if randf() < 0.5:
					var coin = load("res://scripts/coin.gd").new()
					coin.global_position = body.global_position + Vector2(10, 10)
					body.get_parent().add_child(coin)
					
				body.queue_free()
		
		# DO NOT EXPLODE ORB! PIERCE THROUGH ENEMIES!
