extends ColorRect

var player = null
var map_scale = 0.1

func _process(_delta):
	queue_redraw()

func _draw():
	if not player:
		player = get_tree().get_root().get_node_or_null("world/player")
		
	if not player: return
	
	# Draw player (green) in center
	draw_circle(Vector2(size.x/2, size.y/2), 5, Color(0, 1, 0))
	
	# Draw enemies (red)
	for node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(node):
			var rel_pos = (node.global_position - player.global_position) * map_scale
			var draw_pos = Vector2(size.x/2, size.y/2) + rel_pos
			
			if draw_pos.x > 0 and draw_pos.x < size.x and draw_pos.y > 0 and draw_pos.y < size.y:
				draw_circle(draw_pos, 4, Color(1, 0, 0))
				
	# Draw shops (blue)
	for node in get_tree().get_nodes_in_group("shop"):
		if is_instance_valid(node):
			var rel_pos = (node.global_position - player.global_position) * map_scale
			var draw_pos = Vector2(size.x/2, size.y/2) + rel_pos
			
			if draw_pos.x > 0 and draw_pos.x < size.x and draw_pos.y > 0 and draw_pos.y < size.y:
				draw_circle(draw_pos, 6, Color(0, 0.5, 1.0))
