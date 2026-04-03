extends Node

var damage := 60
var size := 0.6
var speed := 0.6
var escapee = 0
var current_level = 1


signal start_game_requested #to restart the timer when new game start

func add_escape():
	escapee += 1
	if escapee >= 10:
		get_tree().paused = true
		get_tree().change_scene_to_file("res://lose_screen.tscn")
		
