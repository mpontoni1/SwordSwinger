extends Area3D

@onready var prompt_label: Label3D = $PromptLabel
@onready var visual: MeshInstance3D = $Visual

var player_in_range: bool = false
var consumed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.visible = false


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not consumed:
		player_in_range = true
		prompt_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range or consumed:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_activate()


func _activate() -> void:
	consumed = true
	prompt_label.visible = false
	visual.visible = false

	var choices := BoonManager.roll_choices(3)
	if choices.is_empty():
		queue_free()
		return

	var ui_script := preload("res://scripts/boon_choice_ui.gd")
	var ui = ui_script.new()
	get_tree().current_scene.add_child(ui)
	ui.present(choices)
	await get_tree().create_timer(1.0).timeout
	queue_free()
