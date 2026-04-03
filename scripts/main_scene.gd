extends Node3D
@onready var timer = $Timer
@onready var win_screen = $Ui/WinScreen
@onready var start_ui = $Ui/Start
@onready var timer_label = $Ui/TimerLabel
@onready var escapee_label = $Ui/EscapeeLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Current level on ready: ", GameManager.current_level)
	win_screen.hide()
	timer_label.visible = false
	escapee_label.visible = false
	GameManager.show_win_screen.connect(_on_show_win_screen)
	GameManager.start_game_requested.connect(_on_start_pressed)
	win_screen.continue_pressed.connect(_on_win_continue)
	MusicManager.play_music()
	
	if GameManager.current_level > 1:
		# Skip start screen on level 2+
		_on_start_pressed()
	else:
		get_tree().paused = true
		win_screen.hide()
		start_ui.visible = true

func _on_show_win_screen() -> void:
	get_tree().paused = true
	win_screen.visible = true
	

func _on_win_continue():
	print("Win continue pressed")
	
	print("LEVEL NOW:", GameManager.current_level)
	
	GameManager.reset_day()
	
	win_screen.hide()
	get_tree().paused = true
	
	var shop_scene = preload("res://scenes/shop.tscn").instantiate()
	$Ui.add_child(shop_scene)

func _process(delta: float) -> void:
	if not get_tree().paused:
		timer_label.text = str(int(timer.time_left)+1)
		escapee_label.text = str(GameManager.escapee) + "/10"


func _on_timer_timeout() -> void:
	print("Day Ended")
	GameManager.day_ended = true
	timer.stop()
	var enemies = get_tree().get_nodes_in_group("enemies")
	print("Enemies found: ", enemies.size())
	enemies.map(func(e): e.run_back())


func _on_start_pressed() -> void:
	print("Game Started")
	print("START PRESSED - LEVEL:", GameManager.current_level)
	GameManager.day_ended = false 
	get_tree().paused = false
	timer.wait_time = 10.0
	timer.start()
	var spawners = get_tree().get_nodes_in_group("spawner")
	for s in spawners:
		s.on_new_level()
	print("Timer started, wait time: ", timer.wait_time)
	start_ui.visible = false
	$Ui/TutorialSprite.visible = false
	timer_label.visible = true
	escapee_label.visible = true
