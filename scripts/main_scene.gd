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

	
func _on_win_continue():
	print("Go to shop")
	win_screen.hide()
	# Clean up any existing shop first!
	var old_shop = $Ui.get_node_or_null("Shop")
	if old_shop:
		old_shop.queue_free()
		
	var shop_instance = preload("res://scenes/shop.tscn").instantiate()
	shop_instance.name = "Shop" # Give it a name so we can find it to delete it later
	$Ui.add_child(shop_instance)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	print("Day Ended")
	get_tree().paused = true
	if has_node("Ui/Shop"):
		$Ui/Shop.queue_free()
	win_screen.visible = true
	
	if not win_screen.continue_pressed.is_connected(_on_win_continue):
		win_screen.continue_pressed.connect(_on_win_continue)



func _on_start_pressed() -> void:
	print("Game Started")
	get_tree().paused = false
	timer.start()
	start_ui.visible = false
