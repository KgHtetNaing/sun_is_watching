extends MeshInstance3D

@onready var spawn_point = $spawnPoint
@export var person_scene : PackedScene



func _ready():
	while true:
		spawn_person()
		await get_tree().create_timer(5).timeout
	
func spawn_person():
	var person = person_scene.instantiate()
	person.escape_point = $"../../escape_point"
	get_parent().add_child.call_deferred(person)
	person.global_position = spawn_point.global_position
	person.home_position = spawn_point.global_position
