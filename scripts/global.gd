extends Node

var player_current_attack = false
var currentscene = "world"
var player_dead = false
var score = 0
var high_score = 0

# RPG Stats
var level = 1
var current_xp = 0
var max_xp = 100

var gold = 0

var combo_count = 0
var combo_timer = 0.0

signal player_leveled_up
signal combo_updated

const SAVE_PATH = "user://save_game.dat"

func _ready():
	load_game()

func gain_xp(amount: int):
	current_xp += amount
	if current_xp >= max_xp:
		current_xp -= max_xp
		level += 1
		max_xp = int(max_xp * 1.5) # Increase max xp required for next level
		save_game()
		emit_signal("player_leveled_up")

func hit_stop(duration: float = 0.05, time_scale: float = 0.1):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale, true, false, true).timeout
	Engine.time_scale = 1.0

func save_game():
	var save_dict = {
		"high_score": high_score,
		"level": level,
		"current_xp": current_xp,
		"max_xp": max_xp,
		"score": score,
		"gold": gold
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))
		file.close()

func load_game() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_res = json.parse(content)
		if parse_res == OK:
			var data = json.data
			if typeof(data) == TYPE_DICTIONARY:
				if data.has("high_score"): high_score = data["high_score"]
				if data.has("level"): level = data["level"]
				if data.has("current_xp"): current_xp = data["current_xp"]
				if data.has("max_xp"): max_xp = data["max_xp"]
				if data.has("score"): score = data["score"]
				if data.has("gold"): gold = data["gold"]
				return true
	return false
