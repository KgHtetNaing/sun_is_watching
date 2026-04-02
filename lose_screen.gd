extends Control
@onready var current_lvl = $CanvasLayer/HBoxContainer/current_lvl

func _ready():
	if get_tree().paused ==  true:
		get_tree().paused = false
		
	var level = GameManager.current_level
	current_lvl.text = str(level)
	MusicManager.get_node("BGM_music").stop()
	


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
