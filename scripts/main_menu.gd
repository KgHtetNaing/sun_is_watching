extends Control

func _ready():
	MusicManager.play_music()


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
