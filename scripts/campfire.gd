extends Area2D

var player_in_range = false
var heal_timer = 0.0

func _ready():
	var tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(1.0, 0.4, 0.0, 1), Color(1.0, 0.0, 0.0, 1)])
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 20
	tex.height = 20
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	
	var light = PointLight2D.new()
	light.texture = tex
	light.color = Color(1.0, 0.5, 0.0)
	light.energy = 1.5
	light.texture_scale = 10.0
	light.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(light)
	
	var p = CPUParticles2D.new()
	p.amount = 15
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 10.0
	p.gravity = Vector2(0, -50)
	p.scale_amount_min = 2.0
	p.scale_amount_max = 4.0
	p.color = Color(1.0, 0.6, 0.1)
	add_child(p)
	
	var shape = CircleShape2D.new()
	shape.radius = 60.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
	collision_layer = 0
	collision_mask = 2 # Player
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.has_method("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.has_method("player"):
		player_in_range = false

func _physics_process(delta):
	if player_in_range:
		heal_timer -= delta
		if heal_timer <= 0:
			heal_timer = 1.0
			var p = get_node_or_null("../player")
			if p:
				p.health += 20
				if p.health > 700: p.health = 700
				p.mana += 10
				if p.mana > p.max_mana: p.mana = p.max_mana
				
				var float_text = Label.new()
				float_text.text = "+20 HP / +10 MP"
				float_text.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
				float_text.global_position = p.global_position + Vector2(-30, -30)
				get_parent().add_child(float_text)
				
				var tw = create_tween().bind_node(float_text)
				tw.tween_property(float_text, "global_position:y", float_text.global_position.y - 40, 1.0)
				tw.tween_callback(float_text.queue_free)
