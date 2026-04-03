extends Node3D
@onready var timer = $Timer
@onready var win_screen = $Ui/WinScreen
@onready var start_ui = $Ui/Start
@onready var timer_label = $Ui/TimerLabel
@onready var escapee_label = $Ui/EscapeeLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	win_screen.hide()
	get_tree().paused = true
	win_screen.continue_pressed.connect(_on_win_continue)
	GameManager.start_game_requested.connect(_on_start_pressed)
	MusicManager.play_music()
	timer_label.visible = false
	escapee_label.visible = false
	GameManager.show_win_screen.connect(_on_show_win_screen)

func _on_show_win_screen() -> void:
	get_tree().paused = true
	win_screen.visible = true
	

func _on_win_continue():
	print("Go to shop")
	win_screen.hide()
	var shop_scene = preload("res://scenes/shop.tscn").instantiate()
	$Ui.add_child(shop_scene)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not get_tree().paused:
		timer_label.text = str(int(timer.time_left)+1)
		escapee_label.text = str(GameManager.escapee) + "/10"


func _on_timer_timeout() -> void:
	print("Day Ended")
	GameManager.day_ended = true
	var enemies = get_tree().get_nodes_in_group("enemies")
	print("Enemies found: ", enemies.size())
	enemies.map(func(e): e.run_back())
	# Tell all enemies to go home
	get_tree().get_nodes_in_group("enemies").map(func(e): e.run_back())



func _on_start_pressed() -> void:
	print("Game Started")
	get_tree().paused = false
	timer.start()
	start_ui.visible = false
	$Ui/TutorialSprite.visible = false
	timer_label.visible = true
	escapee_label.visible = true
