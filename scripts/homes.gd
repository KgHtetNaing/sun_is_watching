extends MeshInstance3D

@onready var spawn_point = $spawnPoint
@onready var spawn_timer = $spawn_timer
@export var person_scene : PackedScene



func _ready():
	spawn_timer.wait_time = randf_range(1.0 , 6.0)
	spawn_timer.start()
	

	
func spawn_person():
	var person = person_scene.instantiate()
	person.escape_point = $"../../escape_point"
	get_parent().add_child.call_deferred(person)
	person.global_position = spawn_point.global_position
	person.home_position = spawn_point.global_position





func _on_spawn_timer_timeout() -> void:
	spawn_person()
	spawn_timer.wait_time = randf_range(1.0 , 6.0)
