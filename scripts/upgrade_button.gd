extends Button

@export var upgrade_type: String
@export var amount: float = 20

func _ready():
	pivot_offset = size / 2
	
func _on_mouse_entered() -> void:
	scale = Vector2(1.2,1.2)

func _on_mouse_exited() -> void:
	scale = Vector2(1,1)

func _on_pressed() -> void:
	match upgrade_type:
		"damage":
			GameManager.damage += amount
		"size":
			GameManager.size += amount
		"speed":
			GameManager.speed += amount
	print("Upgraded:", upgrade_type)
	
	#remove the UI and increase the level in gamemanager
	get_parent().queue_free() 
	GameManager.current_level += 1
	remove_people()
	
	#unpause and go back to the game scene
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
	
func remove_people():
	#people.tscn is added to group("enemies")
	var people =  get_tree().get_nodes_in_group("enemies")
	for i in people:
		i.queue_free()
	
	
