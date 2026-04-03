extends MeshInstance3D

@onready var spawn_point = $spawnPoint
@onready var spawn_timer = $spawn_timer
var peep_hat = preload("res://scenes/peep_sunscreen.tscn")
var peep_umbrella = preload("res://scenes/peep_umbrella.tscn")
var peep_skater = preload("res://scenes/peep_skater.tscn")
var default_enemy = preload("res://scenes/peep.tscn")
#enemy scenes are put into array in home -> inspector -> enemy_scene array
@export var enemy_scene : Array[PackedScene] = []


func _ready():
	print ("Timer has started")
	print("Spawner instance:", self)
	if enemy_scene.is_empty():
		enemy_scene.append(default_enemy)
	update_difficulity()
	spawn_person()
	spawn_timer.wait_time = randf_range(0.5 , 1.5)
	spawn_timer.start()

func on_new_level():
	print("Spawner updating for NEW LEVEL:", GameManager.current_level)
	
	update_difficulity()
	
	spawn_timer.wait_time = randf_range(0.5, 1.5)
	spawn_timer.start()

func spawn_person():
	if enemy_scene.is_empty():
		return
	if GameManager.day_ended:
		return
	var spawn_count = 1 + int(GameManager.current_level / 2)
	for i in spawn_count:
		var random_enemy =  randi() % enemy_scene.size()
		var person = enemy_scene[random_enemy].instantiate()
		get_parent().add_child.call_deferred(person)
		person.escape_point = $"../../escape_point"
		person.global_position = spawn_point.global_position
		person.home_position = spawn_point.global_position
		print("Spawning enemy index:", random_enemy)
		print("Enemy scene:", enemy_scene[random_enemy])

func _on_spawn_timer_timeout() -> void:
	if GameManager.day_ended:
		spawn_timer.stop()
		return
	spawn_person()
	var current_wait =  10.0 - (GameManager.current_level * 0.5)
	spawn_timer.wait_time = clamp(current_wait , 0.5 ,10.0)
	print ("current_wait" , current_wait)
	update_difficulity()
	print ("Enemy scene length" ,len(enemy_scene))
	

func update_difficulity():
	print("Updating difficulty, current level: ", GameManager.current_level)
	
	if GameManager.current_level >= 2 and not enemy_scene.has(peep_hat):
			enemy_scene.append(peep_hat)
			print ("Peep_hat added")
		
	if GameManager.current_level >= 4 and not enemy_scene.has(peep_umbrella):
		enemy_scene.append(peep_umbrella)
		print("Peep_umbrella added")
		#
	if GameManager.current_level >= 6 and not enemy_scene.has(peep_skater):
		enemy_scene.append(peep_skater)
		print("Peep_skater added")
	print("Enemy scene size after update: ", enemy_scene.size())
