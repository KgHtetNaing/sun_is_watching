extends Area3D

var bodies_inside: Array = []
var focus_timers: Dictionary = {}

func _physics_process(delta: float) -> void:
	# Clean up any freed / destroyed bodies
	for i in range(bodies_inside.size() - 1, -1, -1):
		var body = bodies_inside[i]
		if not is_instance_valid(body):
			bodies_inside.remove_at(i)
			focus_timers.erase(body)

	for body in bodies_inside:
		if not is_instance_valid(body):
			continue
			
		# Track continuous focus time on this target for Magnifying Focus
		var current_focus: float = focus_timers.get(body, 0.0) + delta
		focus_timers[body] = current_focus
		
		# Compute Magnifying multiplier (e.g. +35% per sec up to max cap)
		var dmg_mult: float = 1.0
		if GameManager.magnifying_rate > 0.0:
			var max_bonus: float = 0.5 * GameManager.upgrades_acquired.get("magnifying_focus", 1)
			dmg_mult += min(current_focus * GameManager.magnifying_rate, max_bonus)
		
		var tick_damage: float = GameManager.damage * dmg_mult * delta
		
		if body.has_method("take_damage"):
			body.take_damage(tick_damage)
			
		# Apply Sticky Heat slow effect
		if GameManager.slow_factor > 0.0 and body.has_method("apply_slow"):
			body.apply_slow(GameManager.slow_factor)
			
		# Apply Sunburn DoT tag
		if GameManager.sunburn_ratio > 0.0 and body.has_method("apply_sunburn"):
			var dps: float = GameManager.damage * GameManager.sunburn_ratio
			body.apply_sunburn(dps, GameManager.sunburn_duration)

func _on_body_entered(body: Node3D) -> void:
	if not bodies_inside.has(body):
		bodies_inside.append(body)
		focus_timers[body] = 0.0
		if GameManager.slow_factor > 0.0 and body.has_method("apply_slow"):
			body.apply_slow(GameManager.slow_factor)

func _on_body_exited(body: Node3D) -> void:
	bodies_inside.erase(body)
	focus_timers.erase(body)
	if is_instance_valid(body) and body.has_method("remove_slow"):
		body.remove_slow()

