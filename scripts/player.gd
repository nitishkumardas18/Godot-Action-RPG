# Player.gd
extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 700
var player_alive = true
signal health_depleted

var mana = 100.0
var max_mana = 100.0

var attack_ip = false
var attack_mode = false

const speed = 150
var current_dir = "none"
var shake_intensity = 0.0

var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
var is_invincible = false

var dust_particles: CPUParticles2D


func _ready():
	$AnimatedSprite2D.play("front_idle")
	global.connect("player_leveled_up", Callable(self, "_on_level_up"))
	
	$Camera2D.position_smoothing_enabled = true
	$Camera2D.position_smoothing_speed = 5.0
	
	# Player Lantern Light
	var light = PointLight2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(1.0, 0.9, 0.6, 1.0), Color(1.0, 0.9, 0.6, 0.0)])
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 250
	tex.height = 250
	light.texture = tex
	light.energy = 1.0
	light.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(light)
	
	if not InputMap.has_action("dash"):
		InputMap.add_action("dash")
		var ev = InputEventKey.new()
		ev.keycode = KEY_SPACE
		InputMap.action_add_event("dash", ev)
		
	if not InputMap.has_action("magic"):
		InputMap.add_action("magic")
		var ev2 = InputEventKey.new()
		ev2.keycode = KEY_F
		InputMap.action_add_event("magic", ev2)
		
	if not InputMap.has_action("shuriken"):
		InputMap.add_action("shuriken")
		var ev3 = InputEventKey.new()
		ev3.keycode = KEY_E
		InputMap.action_add_event("shuriken", ev3)
		
	# Footstep Dust Particles
	dust_particles = CPUParticles2D.new()
	dust_particles.emitting = false
	dust_particles.amount = 10
	dust_particles.lifetime = 0.5
	dust_particles.gravity = Vector2(0, -10)
	dust_particles.initial_velocity_min = 5
	dust_particles.initial_velocity_max = 15
	dust_particles.scale_amount_min = 2.0
	dust_particles.scale_amount_max = 4.0
	dust_particles.color = Color(0.8, 0.8, 0.7, 0.5)
	dust_particles.position = Vector2(0, 15)
	add_child(dust_particles)

func _on_level_up():
	health += 250
	if health > 700:
		health = 700
	update_health()
	
	# Show level up text
	var float_text = Label.new()
	float_text.text = "LEVEL UP!"
	float_text.add_theme_font_size_override("font_size", 24)
	float_text.add_theme_color_override("font_color", Color(1, 0.8, 0)) # Gold
	float_text.global_position = global_position + Vector2(-40, -40)
	get_parent().add_child(float_text)
	
	var t2 = Timer.new()
	t2.wait_time = 2.0
	t2.one_shot = true
	t2.connect("timeout", Callable(float_text, "queue_free"))
	float_text.add_child(t2)
	t2.start()

func _physics_process(_delta):
	# Mana Regen
	if mana < max_mana:
		mana += _delta * 5.0
		if mana > max_mana: mana = max_mana
		
	# Low Health Warning (Danger Mode)
	if health > 0 and health < 150:
		var blink = sin(Time.get_ticks_msec() / 100.0) * 0.5 + 0.5
		$AnimatedSprite2D.modulate = Color(1.0, 1.0 - blink * 0.5, 1.0 - blink * 0.5)
	else:
		$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0)
		
	player_movement(_delta)
	enemy_attack()
	attack()
	update_health()
	
	if Input.is_action_just_pressed("magic"):
		if mana >= 20:
			mana -= 20
			shoot_magic()
		
	if Input.is_action_just_pressed("shuriken"):
		if mana >= 15:
			mana -= 15
			throw_shuriken()
		
	if shake_intensity > 0:
		shake_intensity = move_toward(shake_intensity, 0.0, _delta * 30.0)
		$Camera2D.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_intensity

	if health <= 0 and player_alive:
		player_alive = false
		health = 0
		print("Player has been killed")
		emit_signal("health_depleted")

func player_movement(_delta):
	if is_dashing:
		is_invincible = true
		dash_timer -= _delta
		# Spawn Ghost Trail
		var ghost = Sprite2D.new()
		ghost.texture = $AnimatedSprite2D.sprite_frames.get_frame_texture($AnimatedSprite2D.animation, $AnimatedSprite2D.frame)
		ghost.global_position = global_position
		ghost.flip_h = $AnimatedSprite2D.flip_h
		ghost.modulate = Color(1, 1, 1, 0.5)
		get_parent().add_child(ghost)
		var tw = create_tween().bind_node(ghost)
		tw.tween_property(ghost, "modulate:a", 0.0, 0.3)
		tw.tween_callback(ghost.queue_free)
		
		velocity = dash_direction * (speed * 3.0)
		move_and_slide()
		if dash_timer <= 0:
			is_dashing = false
			is_invincible = false
		return

	var is_moving = false
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
		is_moving = true
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
		is_moving = true
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed
		velocity.x = 0
		is_moving = true
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed
		velocity.x = 0
		is_moving = true
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
		is_moving = false
		
	if is_moving and dust_particles:
		dust_particles.emitting = true
	elif dust_particles:
		dust_particles.emitting = false
		
	if Input.is_action_just_pressed("dash") and velocity != Vector2.ZERO and not is_dashing:
		is_dashing = true
		dash_timer = 0.2
		dash_direction = velocity.normalized()

	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D

	# Attack mode has highest priority
	if attack_mode:
		if dir == "right":
			anim.flip_h = false
			anim.play("side_attack")
		elif dir == "left":
			anim.flip_h = true
			anim.play("side_attack")
		elif dir == "down":
			anim.play("front_attack")
		elif dir == "up":
			anim.play("back_attack")
		return  # Exit early since attack animation is playing

	# Normal movement/idle animations
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		else:
			anim.play("side_idle")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		else:
			anim.play("side_idle")
	elif dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front_walk")
		else:
			anim.play("front_idle")
	elif dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		else:
			anim.play("back_idle")

func player():
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true and not is_invincible:
		health -= 40
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		shake_intensity = 15.0
		
		# Reset Combo
		global.combo_count = 0
		global.combo_timer = 0.0
		global.emit_signal("combo_updated")
		
		var dmg_lbl = Label.new()
		dmg_lbl.text = "-40"
		dmg_lbl.add_theme_font_size_override("font_size", 20)
		dmg_lbl.add_theme_color_override("font_color", Color(0.8, 0.2, 1.0)) # Purple for player damage
		dmg_lbl.global_position = global_position + Vector2(randf_range(-10, 10), -20)
		get_parent().add_child(dmg_lbl)
		var tw = create_tween().bind_node(self)
		tw.tween_property(dmg_lbl, "global_position:y", dmg_lbl.global_position.y - 30, 0.5)
		tw.tween_callback(dmg_lbl.queue_free)

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func attack():
	if Input.is_action_just_pressed("attack"):
		attack_mode = not attack_mode
		global.player_current_attack = attack_mode
		attack_ip = attack_mode

		if attack_mode:
			$deal_attack_timer.start()
		else:
			$deal_attack_timer.stop()
			global.player_current_attack = false
			attack_ip = false

func _on_deal_attack_timer_timeout():
	if attack_mode:
		$deal_attack_timer.start()

func shoot_magic():
	var orb = load("res://scripts/magic_orb.gd").new()
	var dir = Vector2.RIGHT
	if current_dir == "left": dir = Vector2.LEFT
	elif current_dir == "up": dir = Vector2.UP
	elif current_dir == "down": dir = Vector2.DOWN
	
	orb.direction = dir
	orb.global_position = global_position
	get_parent().add_child(orb)

func throw_shuriken():
	var s = load("res://scripts/shuriken.gd").new()
	var dir = Vector2.RIGHT
	if current_dir == "left": dir = Vector2.LEFT
	elif current_dir == "up": dir = Vector2.UP
	elif current_dir == "down": dir = Vector2.DOWN
	
	s.direction = dir
	s.global_position = global_position
	get_parent().add_child(s)

func update_health():
	var healthbar = $healthBar
	healthbar.value = health

	if health >= 375:
		healthbar.modulate = Color8(0, 255, 0)
	elif health >= 250:
		healthbar.modulate = Color8(255, 255, 0)
	elif health >= 125:
		healthbar.modulate = Color8(255, 128, 0)
	else:
		healthbar.modulate = Color8(255, 0, 0)

	if health >= 400:
		healthbar.visible = false
	else:
		healthbar.visible = true
		
	# Mana Bar UI (Dynamic)
	var manabar = get_node_or_null("manaBar")
	if not manabar:
		manabar = ProgressBar.new()
		manabar.name = "manaBar"
		manabar.max_value = 100
		manabar.value = mana
		manabar.position = Vector2(-20, 15)
		manabar.size = Vector2(40, 5)
		manabar.show_percentage = false
		manabar.modulate = Color(0, 0.5, 1.0) # Blue
		add_child(manabar)
	manabar.max_value = max_mana
	manabar.value = mana
	manabar.visible = (mana < max_mana)

func _on_regin_timer_timeout():	
	if health > 0 and health < 250:
		health += 150
	update_health()


func _on_health_depleted() -> void:
	global.player_dead = true 
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
