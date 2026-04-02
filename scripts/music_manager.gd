extends Node2D

func play_music():
	if not $BGM_music.playing:
		$BGM_music.play()
