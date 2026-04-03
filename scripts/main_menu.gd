extends Control

@onready var sprite = $CanvasLayer/Umbre
func _ready():
	MusicManager.play_music()
	sprite.play("default")


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
