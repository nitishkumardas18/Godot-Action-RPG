extends Node2D

var player = null
var offset_target = Vector2(-30, -30)
var float_time = 0.0

func _ready():
	# Visuals: Glowing Fairy
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(1, 0.8, 0.2, 1), Color(1, 0.5, 0, 0)]) # Gold/Orange
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 15
	tex.height = 15
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	
	# Light
	var light = PointLight2D.new()
	light.texture = tex
	light.color = Color(1, 0.8, 0.2)
	light.energy = 1.0
	light.texture_scale = 2.0
	add_child(light)

func _process(delta):
	if not player:
		# Find player if not assigned
		var p = get_parent().get_node_or_null("player")
		if p:
			player = p
		return
		
	float_time += delta * 3.0
	var bobbing = Vector2(0, sin(float_time) * 10.0)
	
	# Smooth follow player
	var target_pos = player.global_position + offset_target + bobbing
	
	# Flip offset based on player facing direction
	if player.current_dir == "right":
		offset_target.x = -30
	elif player.current_dir == "left":
		offset_target.x = 30
		
	global_position = global_position.lerp(target_pos, delta * 4.0)

var shoot_timer = 0.0

func _physics_process(delta):
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot_timer = 2.0
		
		# Find closest enemy
		var closest_enemy = null
		var closest_dist = 300.0 # Max range
		
		var enemies = get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if is_instance_valid(enemy):
				var dist = global_position.distance_to(enemy.global_position)
				if dist < closest_dist:
					closest_dist = dist
					closest_enemy = enemy
					
		if closest_enemy:
			# Shoot magic orb
			var orb = load("res://scripts/magic_orb.gd").new()
			orb.direction = (closest_enemy.global_position - global_position).normalized()
			orb.global_position = global_position
			orb.damage = 15 # Pet does less damage
			
			# Make it smaller
			orb.scale = Vector2(0.5, 0.5)
			get_parent().add_child(orb)
