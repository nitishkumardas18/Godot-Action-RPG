extends Area2D

func _ready():
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(0.8, 0.0, 1.0, 1), Color(0.2, 0.0, 0.4, 1)])
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 24
	tex.height = 24
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	
	var light = PointLight2D.new()
	light.texture = tex
	light.color = Color(0.8, 0.2, 1.0)
	light.energy = 2.0
	light.texture_scale = 3.0
	add_child(light)
	
	var shape = CircleShape2D.new()
	shape.radius = 16.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
	collision_layer = 0
	collision_mask = 2 # Player
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	var tw = create_tween().bind_node(sprite).set_loops()
	tw.tween_property(sprite, "rotation", PI * 2, 2.0)
	tw.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.5)
	tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.5)

func _on_body_entered(body):
	if body.has_method("player"):
		global.max_xp += 50 # Just a meta-bonus
		body.health += 100
		
		# Boss core effects!
		var float_text = Label.new()
		float_text.text = "BOSS CORE: +MAX HP, +SPEED"
		float_text.add_theme_font_size_override("font_size", 24)
		float_text.add_theme_color_override("font_color", Color(0.8, 0.0, 1.0))
		float_text.global_position = global_position + Vector2(-80, -40)
		get_parent().add_child(float_text)
		
		var tw = create_tween().bind_node(float_text)
		tw.tween_property(float_text, "global_position:y", float_text.global_position.y - 50, 2.0)
		tw.tween_callback(float_text.queue_free)
		
		queue_free()
