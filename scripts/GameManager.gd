extends Node

var damage := 100
var size := 1.0
var speed := 1.0
var escapee = 0

func add_escape():
	escapee += 1
	if escapee >= 10:
		print("Too many escape, you lose")
