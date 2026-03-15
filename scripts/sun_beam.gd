extends CharacterBody3D
@onready var camera = get_viewport().get_camera_3d()


	


func _physics_process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		global_position = global_position.lerp(result.position, 5 * delta)
		
