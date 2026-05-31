# enemyspawner.gd
extends Node

const TAU := PI * 2
@export var enemy_scene: PackedScene
@export var enemy_count: int = 25

func _ready() -> void:
	randomize()
	spawn_wave(enemy_count)
	global.connect("player_leveled_up", Callable(self, "_on_level_up"))

func _on_level_up() -> void:
	# Spawn more enemies based on level
	var new_count = 20 + (global.level * 5)
	spawn_wave(new_count)

func spawn_wave(count: int) -> void:
	var map_w := 1165
	var map_h := 655
	var min_dist := 90
	var max_attempts := 70

	var points: Array[Vector2] = []
	points.append(Vector2(randf() * map_w, randf() * map_h))

	var active: Array[Vector2] = []
	active.append(points[0])

	# Poisson-disc sampling to place enemycount points
	while active.size() > 0 and points.size() < count:
		var idx := randi() % active.size()
		var origin := active[idx]
		var placed := false

		for _i in range(max_attempts):
			var ang := randf() * TAU
			var dist := randf() * (min_dist * 2) + min_dist
			var sample := origin + Vector2(cos(ang), sin(ang)) * dist

			if sample.x < 0 or sample.x > map_w or sample.y < 0 or sample.y > map_h:
				continue

			var valid := true
			for existing in points:
				if existing.distance_to(sample) < min_dist:
					valid = false
					break

			if not valid:
				continue

			points.append(sample)
			active.append(sample)
			placed = true
			break

		if not placed:
			active.remove_at(idx)

	# Instantiate enemies at each sampled point
	for pos in points:
		var enemy = enemy_scene.instantiate()
		enemy.position = pos
		# Scale up the enemy based on level
		enemy.health += (global.level * 20)
		enemy.speed += (global.level * 5)
		add_child(enemy)
