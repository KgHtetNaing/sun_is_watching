extends Area3D

var bodies_inside = []

	
func _physics_process(delta):
	#print ("physics_running")
	#print("Damage:", GameManager.damage) #for debug
	for body in bodies_inside:
		#print("Trying to damage:", body.name)
		if body.has_method ("take_damage"):
			body.take_damage(GameManager.damage * delta)
		


func _on_body_entered(body: Node3D) -> void:
	bodies_inside.append(body)
	#print("Bodies inside:", bodies_inside.size())

# for Upgrade cheat test (select all and ctrl+k to activate it) 
#----------------------------^put this in incase you don't know cus i didn't 
#func _input(event):
	#if event.is_action_pressed("ui_accept"): # press space
		#GameManager.size += 2
		#print("Upgraded! New size:", GameManager.size)


func _on_body_exited(body: Node3D) -> void:
	bodies_inside.erase(body)
