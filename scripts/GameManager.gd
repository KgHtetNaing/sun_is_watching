extends Node

var day_ended = false
signal show_win_screen
signal start_game_requested # to restart the timer when new game starts

# Base Stats
const DEFAULT_DAMAGE := 400.0
const DEFAULT_SIZE := 0.8
const DEFAULT_SPEED := 0.6
const DEFAULT_ROUND_TIMER := 30.0

var damage := DEFAULT_DAMAGE
var size := DEFAULT_SIZE
var speed := DEFAULT_SPEED
var escapee := 0
var current_level := 1
var enemies_alive := 0
var round_timer := DEFAULT_ROUND_TIMER

# Roguelike Upgrade Modifiers
var slow_factor := 0.0          # Sticky Heat (% speed reduction in beam)
var magnifying_rate := 0.0      # Magnifying Focus (damage ramp rate per sec)
var sunburn_ratio := 0.0        # Sunburn (lingering DoT ratio of base damage)
var sunburn_duration := 3.0     # Sunburn duration in seconds

# Upgrades acquired this run: { "upgrade_id": rank_int }
var upgrades_acquired: Dictionary = {}

# Upgrade Catalog
const UPGRADE_CATALOG: Array[Dictionary] = [
	{
		"id": "damage",
		"name": "Solar Intensity",
		"rarity": "Common",
		"rarity_color": Color(0.35, 0.75, 1.0),
		"description": "Intensifies solar radiation to overheat peeps much faster.",
		"stats": "• Beam Damage: +100 DPS",
		"icon_path": "res://art/Upgrade/hotter.png"
	},
	{
		"id": "size",
		"name": "Expanding Corona",
		"rarity": "Common",
		"rarity_color": Color(0.35, 0.75, 1.0),
		"description": "Expands the beam's burning footprint across the map.",
		"stats": "• Beam Radius: +25%",
		"icon_path": "res://art/Upgrade/bigger.png"
	},
	{
		"id": "speed",
		"name": "Solar Swiftness",
		"rarity": "Common",
		"rarity_color": Color(0.35, 0.75, 1.0),
		"description": "Enhances beam responsiveness to swiftly track moving targets.",
		"stats": "• Tracking Speed: +30%",
		"icon_path": "res://art/Upgrade/faster.png"
	},
	{
		"id": "sticky_sun",
		"name": "Sticky Sun",
		"rarity": "Rare",
		"rarity_color": Color(1.0, 0.68, 0.15),
		"description": "Heavy solar pressure weighs down anyone caught under the beam.",
		"stats": "• Peep Speed: -10% (In Beam)",
		"icon_path": "res://art/TooHotIcon-01.png"
	},
	{
		"id": "magnifying_focus",
		"name": "Magnifying Focus",
		"rarity": "Rare",
		"rarity_color": Color(1.0, 0.68, 0.15),
		"description": "Concentrates light on a target, continuously amplifying heat.",
		"stats": "• Damage Ramp: Up to +150%",
		"icon_path": "res://art/Ray-44.png"
	},
	{
		"id": "sunburn",
		"name": "Sunburn",
		"rarity": "Epic",
		"rarity_color": Color(0.88, 0.35, 0.95),
		"description": "Inflicts severe sunburn that keeps burning after exiting the beam.",
		"stats": "• Lingering DoT: 30% DPS (3s)",
		"icon_path": "res://art/Ui/sunray-45.png"
	}
]

func get_random_upgrades(count: int = 3) -> Array[Dictionary]:
	var available = UPGRADE_CATALOG.duplicate()
	available.shuffle()
	var selected: Array[Dictionary] = []
	for i in range(min(count, available.size())):
		var item = available[i].duplicate()
		var current_rank = upgrades_acquired.get(item["id"], 0)
		item["current_rank"] = current_rank
		selected.append(item)
	return selected

func apply_upgrade(id: String) -> void:
	var current_rank = upgrades_acquired.get(id, 0) + 1
	upgrades_acquired[id] = current_rank
	print("Applied upgrade: ", id, " to rank: ", current_rank)
	
	match id:
		"damage":
			damage += 100.0
		"size":
			size += 0.25
		"speed":
			speed += 0.3
		"sticky_sun", "sticky_heat":
			slow_factor = min(0.10 * current_rank, 0.60)
		"magnifying_focus":
			magnifying_rate = 0.35 + (current_rank - 1) * 0.20
		"sunburn":
			sunburn_ratio = 0.30 + (current_rank - 1) * 0.15
			sunburn_duration = 3.0 + (current_rank - 1) * 0.5


func reset_run() -> void:
	current_level = 1
	damage = DEFAULT_DAMAGE
	size = DEFAULT_SIZE
	speed = DEFAULT_SPEED
	slow_factor = 0.0
	magnifying_rate = 0.0
	sunburn_ratio = 0.0
	sunburn_duration = 3.0
	upgrades_acquired.clear()
	reset_day()

func add_escape() -> void:
	escapee += 1
	if escapee >= 10:
		get_tree().paused = true
		get_tree().change_scene_to_file("res://scenes/lose_screen.tscn")
		
func register_enemy() -> void:
	enemies_alive += 1

func reset_day() -> void:
	day_ended = false
	enemies_alive = 0
	escapee = 0

func enemy_gone() -> void:
	enemies_alive -= 1
	print("Enemy gone, remaining: ", enemies_alive, " day_ended: ", day_ended)
	if enemies_alive <= 0 and day_ended:
		print("Emitting win screen!")
		show_win_screen.emit()

func start_next_level() -> void:
	current_level += 1
	get_tree().call_group("houses", "on_new_level")
