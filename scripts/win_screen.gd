extends CanvasLayer

signal continue_pressed



func _on_continue_pressed() -> void:
	emit_signal("continue_pressed")
