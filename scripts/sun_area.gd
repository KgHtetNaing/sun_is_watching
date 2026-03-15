extends Area3D

@export var damage = 100
var bodies_inside = []

	
func _physics_process(delta):
	print ("physics_running")
	for body in bodies_inside:
		print("Trying to damage:", body.name)
		if body.has_method ("take_damage"):
			body.take_damage(damage*delta)
		


func _on_body_entered(body: Node3D) -> void:
	bodies_inside.append(body)
	print("Bodies inside:", bodies_inside.size())

	



func _on_body_exited(body: Node3D) -> void:
	bodies_inside.erase(body)
