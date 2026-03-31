extends Node2D

#func _ready():
	#$ouch.finished.connect(_on_finished)
	#$ouch.play()
#
#func _on_finished():
	#$ouch.play()

func play_ouch():
	if not $ouch.playing:
		$ouch.pitch_scale = 1.0
		$ouch.play()
	
