extends Area2D

func _ready():
	# Visuals: Small yellow coin
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(1, 0.9, 0, 1), Color(0.8, 0.6, 0, 0)]) # Gold
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 16
	tex.height = 16
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	
	var shape = CircleShape2D.new()
	shape.radius = 12.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
	# Detect player
	collision_layer = 0
	collision_mask = 2 # Wait, player is layer 2. Actually, let's just connect to body_entered
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Coin bounce animation
	var tw = create_tween().bind_node(self).set_loops()
	tw.tween_property(sprite, "position:y", -5.0, 0.5)
	tw.tween_property(sprite, "position:y", 0.0, 0.5)
	
	# Despawn after 15 seconds
	var t = Timer.new()
	t.wait_time = 15.0
	t.autostart = true
	t.one_shot = true
	t.connect("timeout", Callable(self, "queue_free"))
	add_child(t)

func _on_body_entered(body):
	if body.has_method("player"):
		var amt = randi_range(5, 20)
		global.gold += amt
		
		var gold_lbl = Label.new()
		gold_lbl.text = "+" + str(amt) + " Gold"
		gold_lbl.add_theme_font_size_override("font_size", 18)
		gold_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0)) # Yellow Gold
		gold_lbl.global_position = global_position + Vector2(-15, -20)
		get_parent().add_child(gold_lbl)
		var tw_gold = get_tree().create_tween()
		tw_gold.tween_property(gold_lbl, "global_position:y", gold_lbl.global_position.y - 40, 1.0)
		tw_gold.tween_callback(gold_lbl.queue_free)
		
		queue_free()
