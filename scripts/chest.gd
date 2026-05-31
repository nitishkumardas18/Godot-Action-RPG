extends StaticBody2D

var health = 1
var player_in_attack_zone = false

func _ready():
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(0.8, 0.6, 0.2, 1), Color(0.6, 0.4, 0.1, 1)])
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_SQUARE
	tex.width = 30
	tex.height = 20
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	
	var lbl = Label.new()
	lbl.text = "CHEST"
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.position = Vector2(-15, -20)
	add_child(lbl)
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 20)
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
	var area = Area2D.new()
	var area_col = CollisionShape2D.new()
	var area_shape = CircleShape2D.new()
	area_shape.radius = 35.0
	area_col.shape = area_shape
	area.add_child(area_col)
	area.connect("body_entered", Callable(self, "_on_player_entered"))
	area.connect("body_exited", Callable(self, "_on_player_exited"))
	add_child(area)

func bush(): # Hack to reuse bush/chest hit detection in player's magic/melee logic
	pass

func _on_player_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true

func _on_player_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false

func _physics_process(_delta):
	if player_in_attack_zone and global.player_current_attack and health > 0:
		health -= 1
		break_chest()

func break_chest():
	# Spawn 5 coins
	for i in range(5):
		var coin = load("res://scripts/coin.gd").new()
		coin.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_parent().add_child(coin)
	
	# Spawn 1 health potion
	var potion = load("res://scripts/health_potion.gd").new()
	potion.global_position = global_position + Vector2(0, -10)
	get_parent().add_child(potion)
	
	var p = CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.amount = 20
	p.explosiveness = 1.0
	p.spread = 180
	p.initial_velocity_min = 50
	p.initial_velocity_max = 100
	p.color = Color(1, 0.8, 0) # Gold burst
	p.global_position = global_position
	get_parent().add_child(p)
	p.emitting = true
	
	var t = Timer.new()
	t.wait_time = 1.0
	t.one_shot = true
	t.connect("timeout", Callable(p, "queue_free"))
	p.add_child(t)
	t.start()
	
	queue_free()
