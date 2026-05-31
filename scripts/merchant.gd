extends Area2D

var shop_ui: Panel

func _ready():
	add_to_group("shop")
	# Visuals: Merchant
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(0.2, 0.4, 0.8, 1), Color(0.1, 0.2, 0.5, 0)]) # Blue merchant
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 40
	tex.height = 40
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	
	var lbl = Label.new()
	lbl.text = "SHOP"
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.position = Vector2(-15, -30)
	add_child(lbl)
	
	var shape = CircleShape2D.new()
	shape.radius = 30.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	setup_shop_ui()

func setup_shop_ui():
	var canvas = CanvasLayer.new()
	canvas.layer = 150
	
	shop_ui = Panel.new()
	shop_ui.size = Vector2(400, 300)
	# Center it
	shop_ui.position = Vector2(1152/2 - 200, 648/2 - 150)
	shop_ui.visible = false
	
	var title = Label.new()
	title.text = "Merchant Shop"
	title.add_theme_font_size_override("font_size", 30)
	title.position = Vector2(100, 20)
	shop_ui.add_child(title)
	
	var btn1 = Button.new()
	btn1.text = "+10 Speed (50 Gold)"
	btn1.position = Vector2(100, 100)
	btn1.size = Vector2(200, 50)
	btn1.connect("pressed", Callable(self, "_buy_speed"))
	shop_ui.add_child(btn1)
	
	var btn2 = Button.new()
	btn2.text = "+20 Max Health (100 Gold)"
	btn2.position = Vector2(100, 170)
	btn2.size = Vector2(200, 50)
	btn2.connect("pressed", Callable(self, "_buy_health"))
	shop_ui.add_child(btn2)
	
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.position = Vector2(150, 240)
	close_btn.size = Vector2(100, 40)
	close_btn.connect("pressed", Callable(self, "_close_shop"))
	shop_ui.add_child(close_btn)
	
	canvas.add_child(shop_ui)
	add_child(canvas)

func _on_body_entered(body):
	if body.has_method("player"):
		shop_ui.visible = true

func _on_body_exited(body):
	if body.has_method("player"):
		shop_ui.visible = false

func _close_shop():
	shop_ui.visible = false

func _buy_speed():
	if global.gold >= 50:
		global.gold -= 50
		var p = get_parent().get_node_or_null("player")
		if p:
			p.speed += 10
		_show_feedback("Speed Increased!")
	else:
		_show_feedback("Not enough Gold!")

func _buy_health():
	if global.gold >= 100:
		global.gold -= 100
		var p = get_parent().get_node_or_null("player")
		if p:
			p.health += 20 # Wait, player health isn't capped currently. Let's just heal them.
		_show_feedback("Health Restored & Boosted!")
	else:
		_show_feedback("Not enough Gold!")

func _show_feedback(msg):
	var lbl = Label.new()
	lbl.text = msg
	lbl.position = Vector2(100, 70)
	lbl.add_theme_color_override("font_color", Color(1, 1, 0))
	shop_ui.add_child(lbl)
	var tw = get_tree().create_tween()
	tw.tween_property(lbl, "modulate:a", 0.0, 1.0)
	tw.tween_callback(lbl.queue_free)
