extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var cards_container: HBoxContainer = $CanvasLayer/CardsContainer
@onready var title_label: Label = $CanvasLayer/TitleLabel
@onready var subtitle_label: Label = $CanvasLayer/SubtitleLabel

var card_options: Array[Dictionary] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	MusicManager.play_music()
	
	if subtitle_label:
		subtitle_label.text = "DAY " + str(GameManager.current_level) + " CLEARED - SELECT A BLESSING"
		
	populate_cards()

func populate_cards() -> void:
	# Clear existing children if any
	for child in cards_container.get_children():
		child.queue_free()
		
	card_options = GameManager.get_random_upgrades(3)
	
	for i in range(card_options.size()):
		var data = card_options[i]
		var card = create_card_ui(data, i)
		cards_container.add_child(card)

func create_card_ui(data: Dictionary, index: int) -> Control:
	var card_button = Button.new()
	card_button.custom_minimum_size = Vector2(280, 400)
	card_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card_button.pivot_offset = Vector2(140, 200)
	card_button.flat = true
	
	# Background Panel
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# StyleBox for Card
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.08, 0.1, 0.18, 0.92)
	normal_style.set_corner_radius_all(16)
	normal_style.border_width_left = 3
	normal_style.border_width_right = 3
	normal_style.border_width_top = 3
	normal_style.border_width_bottom = 3
	normal_style.border_color = data.get("rarity_color", Color.WHITE)
	normal_style.shadow_color = Color(0, 0, 0, 0.5)
	normal_style.shadow_size = 12
	normal_style.content_margin_left = 18
	normal_style.content_margin_right = 18
	normal_style.content_margin_top = 18
	normal_style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", normal_style)
	card_button.add_child(panel)
	
	# Vertical Layout Inside Card
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	
	# Top Rarity Badge + Rank Tag
	var top_bar = HBoxContainer.new()
	top_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var rarity_label = Label.new()
	rarity_label.text = "✦ " + str(data.get("rarity", "Common")).to_upper()
	rarity_label.add_theme_color_override("font_color", data.get("rarity_color", Color.WHITE))
	rarity_label.add_theme_font_size_override("font_size", 14)
	top_bar.add_child(rarity_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	
	var rank_label = Label.new()
	var rank = data.get("current_rank", 0)
	rank_label.text = "NEW" if rank == 0 else "LV. " + str(rank + 1)
	rank_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4) if rank == 0 else Color(0.7, 1.0, 0.7))
	rank_label.add_theme_font_size_override("font_size", 13)
	top_bar.add_child(rank_label)
	vbox.add_child(top_bar)
	
	# Card Icon
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(100, 100)
	icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path = data.get("icon_path", "")
	if ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	vbox.add_child(icon_rect)
	
	# Card Title
	var name_label = Label.new()
	name_label.text = data.get("name", "Upgrade")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)
	
	# Horizontal Divider
	var hsep = HSeparator.new()
	var sep_style = StyleBoxLine.new()
	sep_style.color = Color(1, 1, 1, 0.2)
	hsep.add_theme_stylebox_override("separator", sep_style)
	vbox.add_child(hsep)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = data.get("description", "")
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95, 0.9))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_label)
	
	# Select Button / Hint
	var select_hint = Label.new()
	select_hint.text = "CLICK TO CHOOSE"
	select_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	select_hint.add_theme_font_size_override("font_size", 12)
	select_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 0.7))
	vbox.add_child(select_hint)
	
	# Initial Entry Animation
	card_button.scale = Vector2(0.8, 0.8)
	card_button.modulate = Color(1, 1, 1, 0)
	var entry_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	entry_tween.tween_property(card_button, "scale", Vector2.ONE, 0.35).set_delay(index * 0.08)
	entry_tween.tween_property(card_button, "modulate:a", 1.0, 0.25).set_delay(index * 0.08)
	
	# Hover Animations
	card_button.mouse_entered.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(card_button, "scale", Vector2(1.06, 1.06), 0.12)
		normal_style.border_width_left = 5
		normal_style.border_width_right = 5
		normal_style.border_width_top = 5
		normal_style.border_width_bottom = 5
	)
	card_button.mouse_exited.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(card_button, "scale", Vector2.ONE, 0.12)
		normal_style.border_width_left = 3
		normal_style.border_width_right = 3
		normal_style.border_width_top = 3
		normal_style.border_width_bottom = 3
	)
	
	# Click Selection
	card_button.pressed.connect(func():
		_on_card_selected(data.get("id", ""), card_button)
	)
	
	return card_button

func _on_card_selected(upgrade_id: String, card_node: Control) -> void:
	# Disable all cards to prevent double clicks
	for card in cards_container.get_children():
		if card is Button:
			card.disabled = true
			
	# Quick punch animation on selected card
	var select_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	select_tween.tween_property(card_node, "scale", Vector2(1.15, 1.15), 0.1)
	select_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	
	await select_tween.finished
	
	# Apply the upgrade to GameManager
	GameManager.apply_upgrade(upgrade_id)
	
	# Increase level
	GameManager.current_level += 1
	GameManager.reset_day()
	
	# Free shop UI
	queue_free()
	
	# Unpause and request game start for new level
	get_tree().paused = false
	GameManager.start_game_requested.emit()
