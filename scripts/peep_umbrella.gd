extends CharacterBody3D
@export var healthpoint = 300

var speed = 1
var running_speed = 10
var target_position
var going_home = false
var home_position: Vector3
@onready var sprite = $peepumbrella
@export var escape_point : Node3D

func _ready():
	pick_new_target()
	sprite.play("1walk")
	
func _physics_process(delta):
	
	var direction = target_position - global_position
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < 0.1:
		sprite.flip_h = false
		
	if going_home:
		var new_dir = home_position - global_position
		sprite.play("1walk_back")
		speed = running_speed
		if new_dir.length() < 0.5:
			destroy_body()			
			
	else:		
		if direction.length() < 1:
			finding_escape()
		
	velocity = direction.normalized() * speed	
	move_and_slide()

func pick_new_target():
	target_position = Vector3(
		randf_range(-10, 10),
		global_position.y,
		randf_range(-10, 10)
	)

func finding_escape():
	target_position = escape_point.global_position
	
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
		
