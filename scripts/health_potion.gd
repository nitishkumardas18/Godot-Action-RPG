extends Area2D

func _ready():
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 15.0
	col.shape = shape
	add_child(col)
	
	var label = Label.new()
	label.text = "❤️"
	label.add_theme_font_size_override("font_size", 20)
	label.position = Vector2(-15, -15)
	add_child(label)
	
	# Set collision mask to collide with player (layer 1)
	collision_layer = 0
	collision_mask = 1 # Assuming player is on mask 1
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	var t = Timer.new()
	t.wait_time = 15.0
	t.autostart = true
	t.one_shot = true
	t.connect("timeout", Callable(self, "queue_free"))
	add_child(t)

func _on_body_entered(body):
	if body.has_method("player"):
		body.health += 100
		if body.health > 700:
			body.health = 700
		body.update_health()
		
		# Show a floating text for heal
		var float_text = Label.new()
		float_text.text = "+100 HP"
		float_text.add_theme_color_override("font_color", Color(0, 1, 0))
		float_text.global_position = global_position + Vector2(0, -20)
		get_parent().add_child(float_text)
		
		var t2 = Timer.new()
		t2.wait_time = 1.0
		t2.one_shot = true
		t2.connect("timeout", Callable(float_text, "queue_free"))
		float_text.add_child(t2)
		t2.start()
		
		queue_free()
