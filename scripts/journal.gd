extends Control

@onready var stats_container: VBoxContainer = %StatsList
@onready var upgrades_container: VBoxContainer = %UpgradesList
@onready var empty_label: Label = %EmptyLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var panel_container: PanelContainer = %PanelContainer


var is_open: bool = false
var was_paused_before_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	$CanvasLayer.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_J:
			toggle_journal()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and is_open:
			close_journal()
			get_viewport().set_input_as_handled()

func toggle_journal() -> void:
	if is_open:
		close_journal()
	else:
		open_journal()

func open_journal() -> void:
	if is_open:
		return
	is_open = true
	was_paused_before_open = get_tree().paused
	get_tree().paused = true
	
	populate_data()
	
	show()
	$CanvasLayer.show()
	
	# Smooth entry animation
	panel_container.scale = Vector2(0.9, 0.9)
	panel_container.modulate = Color(1, 1, 1, 0)
	panel_container.pivot_offset = panel_container.size / 2
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.25)
	tween.tween_property(panel_container, "modulate:a", 1.0, 0.2)

func close_journal() -> void:
	if not is_open:
		return
	is_open = false
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(panel_container, "scale", Vector2(0.92, 0.92), 0.15)
	tween.tween_property(panel_container, "modulate:a", 0.0, 0.15)
	
	await tween.finished
	hide()
	$CanvasLayer.hide()
	
	# Only unpause if the game was not already paused before opening journal
	if not was_paused_before_open:
		get_tree().paused = false

func populate_data() -> void:
	if subtitle_label:
		subtitle_label.text = "CURRENT DAY: " + str(GameManager.current_level) + "  •  PRESS [J] OR [ESC] TO CLOSE"
		
	# 1. Populate Core Stats
	_populate_stats()
	
	# 2. Populate Acquired Blessings
	_populate_upgrades()

func _populate_stats() -> void:
	for child in stats_container.get_children():
		child.queue_free()
		
	var stats_data = [
		{"icon": "☀️", "name": "Solar Damage", "val": str(int(GameManager.damage)) + " DPS", "color": Color(1.0, 0.85, 0.2)},
		{"icon": "🔍", "name": "Beam Radius", "val": str(snapped(GameManager.size, 0.01)) + "x", "color": Color(0.4, 0.8, 1.0)},
		{"icon": "⚡", "name": "Tracking Speed", "val": str(snapped(GameManager.speed, 0.01)) + "x", "color": Color(0.4, 1.0, 0.7)},
		{"icon": "🧊", "name": "Sticky Slowdown", "val": (str(int(GameManager.slow_factor * 100)) + "%") if GameManager.slow_factor > 0 else "0% (Inactive)", "color": Color(1.0, 0.65, 0.2) if GameManager.slow_factor > 0 else Color(0.6, 0.6, 0.7)},
		{"icon": "🔬", "name": "Magnifying Ramp", "val": ("+" + str(int(GameManager.magnifying_rate * 100)) + "%/s") if GameManager.magnifying_rate > 0 else "0% (Inactive)", "color": Color(1.0, 0.65, 0.2) if GameManager.magnifying_rate > 0 else Color(0.6, 0.6, 0.7)},
		{"icon": "🔥", "name": "Sunburn DoT", "val": (str(int(GameManager.damage * GameManager.sunburn_ratio)) + " DPS") if GameManager.sunburn_ratio > 0 else "0 (Inactive)", "color": Color(0.9, 0.4, 1.0) if GameManager.sunburn_ratio > 0 else Color(0.6, 0.6, 0.7)},
		{"icon": "🚪", "name": "Escaped Peeps", "val": str(GameManager.escapee) + " / 10 Max", "color": Color(1.0, 0.4, 0.4) if GameManager.escapee >= 7 else Color(0.9, 0.9, 0.9)}
	]
	
	for stat in stats_data:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var name_lbl = Label.new()
		name_lbl.text = stat["icon"] + " " + stat["name"]
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95))
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)
		
		var val_lbl = Label.new()
		val_lbl.text = stat["val"]
		val_lbl.add_theme_font_size_override("font_size", 14)
		val_lbl.add_theme_color_override("font_color", stat["color"])
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(val_lbl)
		
		stats_container.add_child(row)

func _populate_upgrades() -> void:
	for child in upgrades_container.get_children():
		child.queue_free()
		
	var acquired = GameManager.upgrades_acquired
	
	if acquired.is_empty():
		empty_label.show()
		return
		
	empty_label.hide()
	
	for upgrade_id in acquired.keys():
		var rank = acquired[upgrade_id]
		var info = _find_upgrade_info(upgrade_id)
		if info.is_empty():
			continue
			
		var item_card = _create_upgrade_item(info, rank)
		upgrades_container.add_child(item_card)

func _find_upgrade_info(id: String) -> Dictionary:
	for item in GameManager.UPGRADE_CATALOG:
		if item["id"] == id or (id == "sticky_heat" and item["id"] == "sticky_sun"):
			return item
	return {}

func _create_upgrade_item(data: Dictionary, rank: int) -> Control:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var rarity_col = data.get("rarity_color", Color.WHITE)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.11, 0.2, 0.85)
	style.set_corner_radius_all(10)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(rarity_col.r, rarity_col.g, rarity_col.b, 0.7)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(hbox)
	
	# Icon
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(44, 44)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path = data.get("icon_path", "")
	if ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	hbox.add_child(icon_rect)
	
	# Info VBox
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(vbox)
	
	# Title Row
	var title_row = HBoxContainer.new()
	var name_lbl = Label.new()
	name_lbl.text = data.get("name", "Upgrade")
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	title_row.add_child(name_lbl)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(spacer)
	
	var rank_lbl = Label.new()
	rank_lbl.text = "RANK " + str(rank)
	rank_lbl.add_theme_font_size_override("font_size", 13)
	rank_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	title_row.add_child(rank_lbl)
	vbox.add_child(title_row)
	
	# Stat Description
	var stat_lbl = Label.new()
	stat_lbl.text = data.get("stats", data.get("description", ""))
	stat_lbl.add_theme_font_size_override("font_size", 12)
	stat_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.92, 0.85))
	vbox.add_child(stat_lbl)
	
	return panel

func _on_close_button_pressed() -> void:
	close_journal()
