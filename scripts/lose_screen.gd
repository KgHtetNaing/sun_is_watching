extends Control

func _ready():
	$CenterContainer/VBoxContainer/HBoxContainer2/current_level.text = str(GameManager.current_level)


func _on_retry_pressed() -> void:
	GameManager.current_level = 1
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	MusicManager.play_music()
	
