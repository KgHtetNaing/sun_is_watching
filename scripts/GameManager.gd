extends Node

var day_ended = false
signal show_win_screen

var damage := 60
var size := 0.6
var speed := 0.6
var escapee = 0
var current_level = 1
var enemies_alive = 0

signal start_game_requested #to restart the timer when new game start

func add_escape():
	escapee += 1
	if escapee >= 10:
		get_tree().paused = true
		get_tree().change_scene_to_file("res://lose_screen.tscn")
		
func register_enemy():
	enemies_alive += 1
	
func enemy_gone():
	enemies_alive -= 1
	print("Enemy gone, remaining: ", enemies_alive, " day_ended: ", day_ended)
	if enemies_alive <= 0 and day_ended:
		print("Emitting win screen!")
		show_win_screen.emit()
