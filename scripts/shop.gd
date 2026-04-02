extends Control

func _ready():
	MusicManager.play_music()
	SfxManager.get_node("ouch").stop
