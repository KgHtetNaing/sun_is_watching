extends MeshInstance3D

@onready var spawn_point = $spawnPoint
@onready var spawn_timer = $spawn_timer

#enemy scenes are put into array in home -> inspector -> enemy_scene array
@export var enemy_scene : Array[PackedScene] = []




func _ready():
	print ("Timer has started")
	print("Enemy scene array size on ready: ", enemy_scene.size())
	update_difficulity()
	spawn_person()
	spawn_timer.wait_time = randf_range(1.0 , 2.0)
	spawn_timer.start()

	

	
func spawn_person():
	if enemy_scene.is_empty():
		return
	if GameManager.day_ended:
		return
	var random_enemy =  randi() % enemy_scene.size()
	var person = enemy_scene[random_enemy].instantiate()	
	get_parent().add_child.call_deferred(person)
	person.escape_point = $"../../escape_point"
	person.global_position = spawn_point.global_position
	person.home_position = spawn_point.global_position

func _on_spawn_timer_timeout() -> void:
	if GameManager.day_ended:
		spawn_timer.stop()
		return
	spawn_person()
	var current_wait =  10.0 - (GameManager.current_level * 0.5)
	spawn_timer.wait_time = clamp(current_wait , 1.5 ,10.0)
	print ("current_wait" , current_wait)
	update_difficulity()
	print ("Enemy scene length" ,len(enemy_scene))

func update_difficulity():
	print("Updating difficulty, current level: ", GameManager.current_level)
	var peep_hat = preload("res://scenes/peep_sunscreen.tscn")
	var peep_umbrella = preload("res://scenes/peep_umbrella.tscn")
	var peep_skater = preload("res://scenes/peep_skater.tscn")
	
	if GameManager.current_level >= 2:
		if not enemy_scene.has(peep_hat):
			enemy_scene.append(peep_hat)
			print ("Peep_hat added")
		
	if GameManager.current_level >=4:
		if not enemy_scene.has(peep_umbrella):
			enemy_scene.append(peep_umbrella)
			print ("Peep_umbrella added")
		#
	if GameManager.current_level >= 6:
		if not enemy_scene.has(peep_skater):
			enemy_scene.append(peep_skater)
			print("Peep_skater added")
	print("Enemy scene size after update: ", enemy_scene.size())
