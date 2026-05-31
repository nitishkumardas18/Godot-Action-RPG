# Enemy.gd
extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null

var health = 100
var player_in_attack_zone = false
var can_take_damage = true

var ray: RayCast2D

var is_boss = false
var shoot_timer = 0.0

var wander_direction = Vector2.ZERO
var wander_timer = 0.0
var has_aggro = false

func _ready():
	add_to_group("enemies")
	ray = RayCast2D.new()
	ray.target_position = Vector2(25, 0)
	ray.collision_mask = 1 # Environment collision
	add_child(ray)
	
	# Variant System
	var type = randi() % 10
	var anim = $AnimatedSprite2D
	
	if global.level > 2 and type < 2:
		# Ghost Slime (20% at level 3+)
		health = 50 + (global.level * 10) # Low health
		speed = 100 + (global.level * 5) # Very fast
		anim.modulate = Color(0.1, 0.1, 0.1, 0.6) # Dark/Transparent
	elif type < 6:
		# Standard Slime
		health = 100 + (global.level * 20)
		speed = 40 + (global.level * 5)
		anim.modulate = Color(1.0, 1.0, 1.0)
	elif type < 9:
		# Fast Red Slime
		health = 50 + (global.level * 15)
		speed = 85 + (global.level * 5)
		anim.modulate = Color(1.0, 0.3, 0.3)
	else:
		# Boss Slime
		health = 250 + (global.level * 50)
		speed = 20 + (global.level * 5)
		anim.modulate = Color(0.6, 0.1, 0.8) # Purple
		anim.scale = Vector2(1.5, 1.5)
		is_boss = true

func _physics_process(_delta):
	deal_with_damage()
	update_health()

	if player_chase and player:
		var dist = position.distance_to(player.position)
		var dir = (player.position - position).normalized()
		
		# Boss Shooting Logic
		if is_boss:
			shoot_timer -= _delta
			if shoot_timer <= 0 and dist < 300.0:
				shoot_timer = 2.0
				var orb = load("res://scripts/sludge_orb.gd").new()
				orb.direction = dir
				orb.global_position = global_position
				get_parent().add_child(orb)
		
		# Smart AI: Obstacle Avoidance
		ray.target_position = dir * 25.0
		ray.force_raycast_update()
		
		if ray.is_colliding():
			# Steer around the obstacle by adding a perpendicular force
			var perp = Vector2(-dir.y, dir.x)
			dir = (dir + perp * 1.5).normalized()
			
		velocity = dir * speed
		
		$AnimatedSprite2D.play("walk")
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk")
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		has_aggro = false # Reset aggro state when player leaves
		
		if wander_timer > 0:
			wander_timer -= _delta
			velocity = wander_direction * (speed * 0.5)
			$AnimatedSprite2D.play("walk")
			if velocity.x < 0:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
		else:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("idle")
			if randf() < 0.01: # 1% chance every frame to start wandering
				wander_timer = randf_range(1.0, 3.0)
				var angle = randf() * PI * 2
				wander_direction = Vector2(cos(angle), sin(angle))
				
		# Also avoid obstacles while wandering
		ray.target_position = wander_direction * 20.0
		ray.force_raycast_update()
		if ray.is_colliding():
			var perp = Vector2(-wander_direction.y, wander_direction.x)
			wander_direction = (wander_direction + perp).normalized()

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body.has_method("player"):
		player = body
		player_chase = true
		
		if not has_aggro:
			has_aggro = true
			var lbl = Label.new()
			lbl.text = "!"
			lbl.add_theme_font_size_override("font_size", 24)
			lbl.add_theme_color_override("font_color", Color(1, 0, 0)) # Red alert
			lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
			lbl.global_position = global_position + Vector2(-5, -40)
			get_parent().add_child(lbl)
			var tw = get_tree().create_tween()
			tw.tween_property(lbl, "global_position:y", lbl.global_position.y - 20, 0.4)
			tw.tween_callback(lbl.queue_free)

func _on_detection_area_body_exited(_body):
	player = null
	player_chase = false

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false

func deal_with_damage():
	if player_in_attack_zone and global.player_current_attack:
		if can_take_damage:
			var is_crit = randf() < 0.2
			var final_damage = 90 if is_crit else 45
			health -= final_damage
			
			$take_damage_cooldown.start()
			can_take_damage = false
			spawn_hit_particles()
			
			# Knockback Juice
			var p = get_node_or_null("../player")
			if p:
				var kb_dir = (global_position - p.global_position).normalized()
				var kb_tw = create_tween().bind_node(self)
				kb_tw.tween_property(self, "global_position", global_position + kb_dir * 15.0, 0.1)
			
			var dmg_lbl = Label.new()
			if is_crit:
				dmg_lbl.text = "CRIT! -" + str(final_damage)
				dmg_lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2)) # Bright Red
				dmg_lbl.add_theme_font_size_override("font_size", 26) # Bigger font
				global.hit_stop(0.05, 0.1) # Add juicy hit stop!
			else:
				dmg_lbl.text = "-" + str(final_damage)
				dmg_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
				dmg_lbl.add_theme_font_size_override("font_size", 20)
				
			dmg_lbl.global_position = global_position + Vector2(randf_range(-10, 10), -20)
			get_parent().add_child(dmg_lbl)
			var tw = get_tree().create_tween()
			tw.tween_property(dmg_lbl, "global_position:y", dmg_lbl.global_position.y - 40, 0.5)
			tw.tween_callback(dmg_lbl.queue_free)
			
			if health <= 0:
				global.combo_count += 1
				global.combo_timer = 4.0
				global.emit_signal("combo_updated")
				
				var bonus_xp = 40 + (global.combo_count * 5)
				global.score += 10 * global.combo_count
				global.gain_xp(bonus_xp) # Grant XP
				
				var xp_lbl = Label.new()
				xp_lbl.text = "+" + str(bonus_xp) + " XP"
				xp_lbl.add_theme_font_size_override("font_size", 18)
				xp_lbl.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0)) # Blue XP
				xp_lbl.global_position = global_position + Vector2(-15, -40)
				get_parent().add_child(xp_lbl)
				var tw_xp = get_tree().create_tween()
				tw_xp.tween_property(xp_lbl, "global_position:y", xp_lbl.global_position.y - 40, 1.0)
				tw_xp.tween_callback(xp_lbl.queue_free)
				
				# Boss Core drop
				if is_boss:
					var core = load("res://scripts/boss_core.gd").new()
					core.global_position = global_position
					get_parent().add_child(core)
				
				# 30% chance to drop a health potion
				elif randf() < 0.3:
					var potion = load("res://scripts/health_potion.gd").new()
					potion.global_position = global_position
					get_parent().add_child(potion)
					
				# 50% chance to drop gold coin
				if randf() < 0.5:
					var coin = load("res://scripts/coin.gd").new()
					coin.global_position = global_position + Vector2(10, 10)
					get_parent().add_child(coin)
					
				queue_free()

func spawn_hit_particles():
	var p = CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.amount = 15
	p.lifetime = 0.4
	p.explosiveness = 0.8
	p.spread = 180
	p.gravity = Vector2(0, 0)
	p.initial_velocity_min = 50
	p.initial_velocity_max = 100
	p.scale_amount_min = 3.0
	p.scale_amount_max = 6.0
	p.color = Color(0.2, 0.6, 1.0) # Slime blue color
	
	p.global_position = global_position
	get_parent().add_child(p)
	p.emitting = true
	
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.connect("timeout", Callable(p, "queue_free"))
	p.add_child(timer)
	timer.start()

func _on_take_damage_cooldown_timeout():
	can_take_damage = true

func update_health():
	var healthbar = $healthbar
	healthbar.value = health

	healthbar.modulate = Color(1.0, 0.0, 1.0)

	if health >= 70:
		healthbar.visible = false
	else:
		healthbar.visible = true
