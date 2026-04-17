extends CharacterBody3D
@export var healthpoint = 100

var blink_tween: Tween
var speed = 4
var running_speed = 10
var target_position
var going_home = false
var home_position: Vector3
var state = "Approaching"
@onready var hit_box = $Area3D
@onready var sprite = $AnimatedSprite3D
@onready var dialog_box = $"Dialog Box"
@export var escape_point : Node3D

func _ready():
	
	var marker = get_tree().get_nodes_in_group("final_pos")
	if marker:
		target_position = marker[0].global_position
		
	else:
		target_position = Vector3.ZERO 
		print("Warning: No cinematic_target group found!")
	
	dialog_box.hide()
	sprite.play("1walk")
	
	print ("Current state", state)
	#hit_box.disabled = true
	

func _physics_process(delta):
	
	if state == "Talking":
		velocity = Vector3.ZERO
		
		return
		
	var current_target = target_position if state == "Approaching" else home_position
	var direction = current_target - global_position
	
	if direction.length() < 0.8:
		if state == "Approaching":
			start_talking()
		elif state == "Going_home":
			print ("Peep arrived home")
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			queue_free()
	
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < 0.1:
		sprite.flip_h = false
	
	#if going_home:
		#var new_dir = home_position - global_position
		#sprite.play("1walk_back")
		#speed = running_speed
		#if new_dir.length() < 0.5:
			#destroy_body()
			#
	#else:
		#if direction.length() < 1:
			#finding_escape()
		
	velocity = direction.normalized() * speed	
	move_and_slide()

#

	#GameManager.add_escape()
	#GameManager.enemy_gone()
	#queue_free()
		
func start_talking():
	state = "Talking"
	dialog_box.show()
	sprite.play("idle")
	
	print ("Current state is" , state)
	await get_tree().create_timer(4.0).timeout
	
	dialog_box.hide()
	state = "Going_home"
	sprite.play("1walk_back")
