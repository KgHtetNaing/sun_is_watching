extends Node2D

func play_ouch():
	
	$ouch.pitch_scale = randf_range(1.3 , 1.5)
	
	$ouch.play()
	
