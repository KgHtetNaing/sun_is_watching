extends MeshInstance3D

@onready var spawn_point = $spawnPoint
@onready var spawn_timer = $spawn_timer
var peep_hat = preload("res://scenes/peep_sunscreen.tscn")
var peep_umbrella = preload("res://scenes/peep_umbrella.tscn")
var peep_skater = preload("res://scenes/peep_skater.tscn")
var default_enemy = preload("res://scenes/peep.tscn")

var final_peep_scene =preload("res://scenes/final_peep.tscn")
var final_trigger = false
static var boss_spawned = false
#enemy scenes are put into array in home -> inspector -> enemy_scene array
@export var enemy_scene : Array[PackedScene] = []


func _ready():
	enemy_scene = enemy_scene.duplicate()
	print("Timer has started")
	print("Spawner instance:", self)
	if enemy_scene.is_empty():
		enemy_scene.append(default_enemy)
	
	update_difficulity()
	# Random initial stagger so houses don't fire at the exact same moment
	spawn_timer.wait_time = randf_range(1.5, 5.0)
	spawn_timer.start()

func on_new_level():
	print("Spawner updating for NEW LEVEL:", GameManager.current_level)
	update_difficulity()
	final_trigger = false
	spawn_timer.wait_time = randf_range(1.0, 4.0)
	spawn_timer.start()

func spawn_person():
	if enemy_scene.is_empty():
		update_difficulity()
	if GameManager.day_ended:
		return
		
	# Spawn 1 peep per house trigger for controlled, tactical pacing
	var random_enemy = randi() % enemy_scene.size()
	var person = enemy_scene[random_enemy].instantiate()
	person.home_position = spawn_point.global_position
	
	var escape_nodes = get_tree().get_nodes_in_group("escape_point")
	if not escape_nodes.is_empty():
		person.escape_point = escape_nodes[0]
		
	get_tree().current_scene.add_child(person)
	person.global_position = spawn_point.global_position
	
	# Slight health scaling per level
	if "healthpoint" in person:
		person.healthpoint *= (1.0 + (GameManager.current_level - 1) * 0.12)
		
	print("Spawning enemy index:", random_enemy)

func _on_spawn_timer_timeout() -> void:
	if GameManager.current_level >= 6:
		spawn_timer.stop()
		if not final_trigger:
			get_tree().call_group("houses", "trigger_final_day")
		return
		
	if GameManager.day_ended:
		spawn_timer.stop()
		return
		
	spawn_person()
	
	# Comfortable spawn interval per house (4.5 to 7.5 seconds)
	var base_wait = max(4.0, 7.5 - GameManager.current_level * 0.4)
	spawn_timer.wait_time = randf_range(base_wait * 0.85, base_wait * 1.25)
	spawn_timer.start()

	

func update_difficulity():
	print("Updating difficulty, current level: ", GameManager.current_level)
	
	if GameManager.current_level >= 2 and not enemy_scene.has(peep_hat):
			enemy_scene.append(peep_hat)
			print ("Peep_hat added")
		
	if GameManager.current_level >= 3 and not enemy_scene.has(peep_umbrella):
		enemy_scene.append(peep_umbrella)
		print("Peep_umbrella added")
		#
	if GameManager.current_level >= 4 and not enemy_scene.has(peep_skater):
		enemy_scene.append(peep_skater)
		print("Peep_skater added")
	print("Enemy scene size after update: ", enemy_scene.size())

func trigger_final_day():
	
	print ("I am spawning final peep")
	final_trigger = true
	spawn_timer.stop()
	
	# 3. Clear the array (Nuclear Option)
	enemy_scene.clear() 
	print ( "enemy scene length" , enemy_scene.size())
	#print("Array cleared: No more regular peeps can spawn.")
	#
	#print ("Final day triggered")
	if is_in_group("final_house"):
		print("SUCCESS: This is the final house!")
		
		var final_peep = final_peep_scene.instantiate()
		get_tree().current_scene.add_child(final_peep)
		
		# Use 'self.global_position' so we don't rely on a 'spawn_point' node
		final_peep.global_position = self.global_position
		final_peep.home_position = self.global_position
		
		print("Peep spawned at: ", final_peep.global_position)
	else:
		print("DEBUG: House ", name, " is not in the group 'final_house'")
		# If this house isn't the boss house, it should just go away
		#queue_free()
