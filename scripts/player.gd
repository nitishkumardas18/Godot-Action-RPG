# Player.gd
extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 700
var player_alive = true
signal health_depleted

var attack_ip = false
var attack_mode = false

const speed = 150
var current_dir = "none"
var can_move = false

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(_delta):
	player_movement(_delta)
	enemy_attack()
	attack()
	update_health()
	if not can_move:
		return

	if health <= 0 and player_alive:
		player_alive = false
		health = 0
		print("Player has been killed")
		emit_signal("health_depleted")
		queue_free()

func player_movement(_delta):
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0

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
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health -= 40
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)

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

func _on_regin_timer_timeout():
	if health > 0 and health < 250:
		health += 150
	if health <= 40 and player_alive:
		player_alive = true
		health = 0
		queue_free()
	update_health()


func _on_health_depleted() -> void:
	pass # Replace with function body.
