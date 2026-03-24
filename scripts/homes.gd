extends MeshInstance3D

@onready var spawn_point = $spawnPoint
@onready var spawn_timer = $spawn_timer

#enemy scenes are put into array in home -> inspector -> enemy_scene array
@export var enemy_scene : Array[PackedScene] = []




func _ready():
	spawn_timer.wait_time = randf_range(1.0 , 6.0)
	spawn_timer.start()
	

	
func spawn_person():
	if enemy_scene.is_empty():
		return
		
	var random_enemy =  randi() % enemy_scene.size()
	var person = enemy_scene[random_enemy].instantiate()
	print (random_enemy)
	person.escape_point = $"../../escape_point"
	get_parent().add_child.call_deferred(person)
	person.global_position = spawn_point.global_position
	person.home_position = spawn_point.global_position





func _on_spawn_timer_timeout() -> void:
	spawn_person()
	spawn_timer.wait_time = randf_range(1.0 , 6.0)
