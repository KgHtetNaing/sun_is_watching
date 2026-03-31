extends Node3D
@onready var timer = $Timer
@onready var win_screen = $Ui/WinScreen
@onready var start_ui = $Ui/Start
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	win_screen.hide()
	get_tree().paused = true	
	win_screen.continue_pressed.connect(_on_win_continue)
	GameManager.start_game_requested.connect(_on_start_pressed)
	MusicManager.play_music()

	
func _on_win_continue():
	print("Go to shop")
	win_screen.hide()
	var shop_scene = preload("res://scenes/shop.tscn").instantiate()
	$Ui.add_child(shop_scene)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	print("Day Ended")
	get_tree().paused = true
	win_screen.visible = true



func _on_start_pressed() -> void:
	print("Game Started")
	get_tree().paused = false
	timer.start()
	start_ui.visible = false
