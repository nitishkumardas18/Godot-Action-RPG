# Enemy.gd
extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null

var health = 100
var player_in_attack_zone = false
var can_take_damage = true

func _physics_process(_delta):
	deal_with_damage()
	update_health()

	if player_chase and player:
		velocity = (player.position - position).normalized() * speed
		$AnimatedSprite2D.play("walk")
		if player.position.x - position.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle")

	move_and_slide()

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

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
			health -= 45
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Slime health: ", health)
			if health <= 0:
				queue_free()

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
