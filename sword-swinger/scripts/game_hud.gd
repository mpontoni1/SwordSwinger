extends CanvasLayer

var _wave_label: Label
var _hp_bar: ProgressBar
var _hp_label: Label
var _banner: Label


func _ready() -> void:
	layer = 5

	var wave_panel := PanelContainer.new()
	wave_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	wave_panel.offset_left = -120
	wave_panel.offset_right = 120
	wave_panel.offset_top = 10
	wave_panel.offset_bottom = 50
	add_child(wave_panel)

	_wave_label = Label.new()
	_wave_label.text = "Ready"
	_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wave_label.add_theme_font_size_override("font_size", 22)
	wave_panel.add_child(_wave_label)


	var hp_box := VBoxContainer.new()
	hp_box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hp_box.offset_left = 16
	hp_box.offset_top = 16
	hp_box.custom_minimum_size = Vector2(280, 60)
	add_child(hp_box)

	_hp_label = Label.new()
	_hp_label.text = "HP"
	_hp_label.add_theme_font_size_override("font_size", 14)
	hp_box.add_child(_hp_label)

	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(280, 24)
	_hp_bar.show_percentage = false
	hp_box.add_child(_hp_bar)

	_banner = Label.new()
	_banner.set_anchors_preset(Control.PRESET_CENTER)
	_banner.offset_left = -300
	_banner.offset_right = 300
	_banner.offset_top = -60
	_banner.offset_bottom = 60
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner.add_theme_font_size_override("font_size", 56)
	_banner.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	_banner.add_theme_color_override("font_outline_color", Color.BLACK)
	_banner.add_theme_constant_override("outline_size", 8)
	_banner.visible = false
	add_child(_banner)

	# Always wire HP
	PlayerStats.stats_changed.connect(_update_hp)
	_update_hp()

	if has_node("/root/WaveManager"):
			var wm = get_node("/root/WaveManager")
			wm.wave_started.connect(_on_wave_started)
			wm.wave_cleared.connect(_on_wave_cleared)
			wm.run_won.connect(_on_run_won)
			wm.run_lost.connect(_on_run_lost)
			_wave_label.text = "Press F to begin"
	else:
			_wave_label.text = "Free play"


func _update_hp() -> void:
	_hp_bar.max_value = PlayerStats.max_hp
	_hp_bar.value = PlayerStats.current_hp
	_hp_label.text = "HP  %d / %d" % [int(PlayerStats.current_hp), int(PlayerStats.max_hp)]


func _on_wave_started(n: int, total: int) -> void:
	_wave_label.text = "Wave %d / %d" % [n, total]
	_banner.visible = false


func _on_wave_cleared(_n: int) -> void:
	_show_banner("Wave Cleared", 1.5)


func _on_run_won() -> void:
	_show_banner("You Win!", 0.0)
	_wave_label.text = "Run Complete"


func _on_run_lost() -> void:
	_show_banner("You Died", 0.0)
	_wave_label.text = "Run Over"


func _show_banner(text: String, hide_after: float) -> void:
	_banner.text = text
	_banner.visible = true
	if hide_after > 0.0:
		await get_tree().create_timer(hide_after).timeout
		_banner.visible = false
