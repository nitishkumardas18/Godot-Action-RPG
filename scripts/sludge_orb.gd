extends Area2D

var direction = Vector2.RIGHT
var speed = 250.0
var damage = 60

func _ready():
	# Visuals: Sludge Orb
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(0.6, 0, 0.8, 1), Color(0.3, 0, 0.4, 0)])
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 25
	tex.height = 25
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	
	# Light
	var light = PointLight2D.new()
	light.texture = tex
	light.color = Color(0.6, 0.0, 0.8)
	light.energy = 1.5
	light.texture_scale = 3.0
	add_child(light)
	
	# Collision
	var shape = CircleShape2D.new()
	shape.radius = 12.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
	# Detect player (Layer 1/2)
	collision_layer = 0
	collision_mask = 3 
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	var t = Timer.new()
	t.wait_time = 3.0
	t.autostart = true
	t.one_shot = true
	t.connect("timeout", Callable(self, "queue_free"))
	add_child(t)

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("player") and body.player_alive:
		body.health -= damage
		body.update_health()
		body.shake_intensity = 10.0
		
		# Show damage on player
		var dmg_lbl = Label.new()
		dmg_lbl.text = "-" + str(damage)
		dmg_lbl.add_theme_font_size_override("font_size", 20)
		dmg_lbl.add_theme_color_override("font_color", Color(1, 0, 0))
		dmg_lbl.global_position = body.global_position + Vector2(randf_range(-10, 10), -20)
		body.get_parent().add_child(dmg_lbl)
		var tw = get_tree().create_tween()
		tw.tween_property(dmg_lbl, "global_position:y", dmg_lbl.global_position.y - 30, 0.5)
		tw.tween_callback(dmg_lbl.queue_free)
		
		queue_free()
