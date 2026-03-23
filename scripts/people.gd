extends CharacterBody3D
@export var healthpoint = 100

var speed = 3
var running_speed = 10
var target_position
var going_home = false
var home_position: Vector3

@export var escape_point : Node3D

func _ready():
	pick_new_target()

func _physics_process(delta):
	target_position = escape_point.global_position
	var direction = target_position - global_position
	if going_home:
		var new_dir = home_position - global_position
		speed = running_speed
		if new_dir.length() < 0.5:
			destroy_body()			
			
	else:		
		if direction.length() < 1:
			pick_new_target()
		
	velocity = direction.normalized() * speed	
	move_and_slide()

func pick_new_target():
	target_position = Vector3(
		randf_range(-10, 10),
		global_position.y,
		randf_range(-10, 10)
	)
	
func take_damage(amount):
	if going_home:
		return
		
	healthpoint -= amount
	print ("health ", healthpoint)
	
	if healthpoint <= 0:
		run_back()
		
func run_back():
	going_home = true
	target_position = home_position
	
func destroy_body():
	print ("reached home")
	queue_free()

func sucessfully_escape():
	GameManager.add_escape()
	queue_free()	
		
