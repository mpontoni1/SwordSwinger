extends CanvasLayer

const RARITY_COLORS := {
	BoonEffect.Rarity.COMMON: Color(0.85, 0.85, 0.85),
	BoonEffect.Rarity.RARE: Color(0.35, 0.65, 1.0),
	BoonEffect.Rarity.EPIC: Color(0.75, 0.4, 1.0),
	BoonEffect.Rarity.LEGENDARY: Color(1.0, 0.7, 0.15),
}

const RARITY_NAMES := {
	BoonEffect.Rarity.COMMON: "Common",
	BoonEffect.Rarity.RARE: "Rare",
	BoonEffect.Rarity.EPIC: "Epic",
	BoonEffect.Rarity.LEGENDARY: "Legendary",
}

const GOD_NAMES := {
	BoonEffect.God.THOR: "Thor",
	BoonEffect.God.ODIN: "Odin",
	BoonEffect.God.LOKI: "Loki",
}

const GOD_COLORS := {
	BoonEffect.God.THOR: Color(1.0, 0.85, 0.3),
	BoonEffect.God.ODIN: Color(0.6, 0.8, 1.0),
	BoonEffect.God.LOKI: Color(0.6, 1.0, 0.5),
}

var _card_container: HBoxContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 32)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(col)

	var title := Label.new()
	title.text = "Choose a Blessing"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)

	_card_container = HBoxContainer.new()
	_card_container.add_theme_constant_override("separation", 20)
	_card_container.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(_card_container)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true


func present(choices: Array[BoonEffect]) -> void:
	for boon in choices:
		_card_container.add_child(_build_card(boon))


func _build_card(boon: BoonEffect) -> Control:
	var rarity_color: Color = RARITY_COLORS[boon.rarity]

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(240, 340)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.11, 0.97)
	style.border_color = rarity_color
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	card.add_theme_stylebox_override("panel", style)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	card.add_child(vb)

	var god_lbl := Label.new()
	god_lbl.text = GOD_NAMES[boon.god].to_upper()
	god_lbl.add_theme_color_override("font_color", GOD_COLORS[boon.god])
	god_lbl.add_theme_font_size_override("font_size", 14)
	vb.add_child(god_lbl)

	var name_lbl := Label.new()
	name_lbl.text = boon.display_name
	name_lbl.add_theme_color_override("font_color", rarity_color)
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(name_lbl)

	var rarity_lbl := Label.new()
	rarity_lbl.text = RARITY_NAMES[boon.rarity]
	rarity_lbl.add_theme_color_override("font_color", rarity_color)
	rarity_lbl.add_theme_font_size_override("font_size", 14)
	vb.add_child(rarity_lbl)

	vb.add_child(HSeparator.new())

	var desc := Label.new()
	desc.text = boon.description
	desc.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))
	desc.add_theme_font_size_override("font_size", 15)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(desc)

	var btn := Button.new()
	btn.text = "Choose"
	btn.custom_minimum_size = Vector2(0, 40)
	btn.add_theme_font_size_override("font_size", 18)
	btn.pressed.connect(_on_choice.bind(boon))
	vb.add_child(btn)

	return card


func _on_choice(boon: BoonEffect) -> void:
	PlayerStats.apply_boon(boon)
	_close()


func _close() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	queue_free()
