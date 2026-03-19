extends Button

@export var upgrade_type: String
@export var amount: float = 20

func _ready():
	pivot_offset = size / 2
	
func _on_mouse_entered() -> void:
	scale = Vector2(1.2,1.2)

func _on_mouse_exited() -> void:
	scale = Vector2(1,1)

func _on_pressed() -> void:
	match upgrade_type:
		"damage":
			GameManager.damage += amount
		"size":
			GameManager.size += amount
		"speed":
			GameManager.speed += amount
	print("Upgraded:", upgrade_type)
	self.queue_free()
	
