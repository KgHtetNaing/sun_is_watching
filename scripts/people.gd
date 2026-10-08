extends CharacterBody3D
class_name Peep

@export var healthpoint: float = 450.0
@export var speed: float = 3.0
@export var running_speed: float = 10.0
@export var escape_point: Node3D
@export var walk_anim: String = "1walk"
@export var walk_back_anim: String = "1walk_back"

var blink_tween: Tween
var base_speed: float = 3.0
var target_position: Vector3
var going_home: bool = false
var home_position: Vector3

# Status Effects
var is_slowed: bool = false
var slow_amount: float = 0.0
var sunburn_dps: float = 0.0
var sunburn_timer: float = 0.0
var burn_tick_timer: float = 0.0

var sprite: AnimatedSprite3D

func _ready() -> void:
	base_speed = speed
	sprite = _find_animated_sprite()
	if sprite:
		sprite.play(walk_anim)
	pick_new_target()
	GameManager.register_enemy()

func _find_animated_sprite() -> AnimatedSprite3D:
	for child in get_children():
		if child is AnimatedSprite3D:
			return child
	return null

func _physics_process(delta: float) -> void:
	# Process Sunburn DoT
	if sunburn_timer > 0.0 and not going_home:
		sunburn_timer -= delta
		burn_tick_timer += delta
		if burn_tick_timer >= 0.1:
			take_burn_damage(sunburn_dps * burn_tick_timer)
			burn_tick_timer = 0.0

	var current_speed: float
	if going_home:
		current_speed = running_speed
	else:
		if is_slowed:
			current_speed = base_speed * (1.0 - slow_amount)
		else:
			current_speed = base_speed

	var direction = target_position - global_position
	if sprite:
		if direction.x > 0.1:
			sprite.flip_h = true
		elif direction.x < -0.1:
			sprite.flip_h = false
	
	if going_home:
		var new_dir = home_position - global_position
		if sprite and sprite.animation != walk_back_anim:
			sprite.play(walk_back_anim)
		if new_dir.length() < 0.5:
			destroy_body()
			return
	else:
		if direction.length() < 1.0:
			finding_escape()
		
	velocity = direction.normalized() * current_speed
	move_and_slide()

func pick_new_target() -> void:
	target_position = Vector3(
		randf_range(-10, 10),
		global_position.y,
		randf_range(-10, 10)
	)

func finding_escape() -> void:
	if escape_point != null:
		target_position = escape_point.global_position
	else:
		print("Warning: Peep cannot find escape_point!")

func take_damage(amount: float) -> void:
	if going_home:
		return
		
	healthpoint -= amount
	SfxManager.play_ouch()
	blink_red()
	
	if healthpoint <= 0:
		run_back()

func take_burn_damage(amount: float) -> void:
	if going_home:
		return
	healthpoint -= amount
	blink_orange()
	if healthpoint <= 0:
		run_back()

func apply_slow(amount: float) -> void:
	is_slowed = true
	slow_amount = clamp(amount, 0.0, 0.85)

func remove_slow() -> void:
	is_slowed = false
	slow_amount = 0.0

func apply_sunburn(dps: float, duration: float) -> void:
	sunburn_dps = max(sunburn_dps, dps)
	sunburn_timer = max(sunburn_timer, duration)

func blink_red() -> void:
	if blink_tween:
		blink_tween.kill()
		if sprite:
			sprite.modulate = Color.WHITE
	if not sprite:
		return
	blink_tween = create_tween()
	for i in 2:
		blink_tween.tween_property(sprite, "modulate", Color.RED, 0.05)
		blink_tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)

func blink_orange() -> void:
	if not sprite:
		return
	if blink_tween and blink_tween.is_running():
		return
	blink_tween = create_tween()
	blink_tween.tween_property(sprite, "modulate", Color(1.0, 0.6, 0.2), 0.05)
	blink_tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)

func run_back() -> void:
	if going_home:
		return
	going_home = true
	remove_slow()
	sunburn_timer = 0.0
	target_position = home_position
	if sprite:
		sprite.play(walk_back_anim)

func destroy_body() -> void:
	GameManager.enemy_gone()
	queue_free()

func sucessfully_escape() -> void:
	GameManager.add_escape()
	GameManager.enemy_gone()
	queue_free()

		
