# Floating HP bar above a character's head. Drop the HpBar3D.tscn onto the
# character, set `mode` to "player" or "enemy". For enemies, the bar finds
# the parent CharacterBody3D (enemy.gd) automatically.
extends Node3D

@export_enum("player", "enemy") var mode: String = "enemy"
@export var offset_y: float = 2.5      # height above the character's origin

@onready var sprite: Sprite3D = $Sprite3D
@onready var viewport: SubViewport = $Sprite3D/SubViewport
@onready var bar: ProgressBar = $Sprite3D/SubViewport/Bar

var _target_node: Node = null
var _last_hp: float = -1.0
var _last_max: float = -1.0


func _ready() -> void:
	position.y = offset_y

	if mode == "player":
		PlayerStats.stats_changed.connect(_refresh_from_playerstats)
		_refresh_from_playerstats()
	else:
		# Walk up parent chain to find the enemy body
		_target_node = get_parent()
		while _target_node and not ("HEALTH" in _target_node):
			_target_node = _target_node.get_parent()
		if _target_node:
			_refresh_from_enemy()


func _process(_delta: float) -> void:
	# Cheap poll for enemy mode. Player mode is signal-driven, no poll needed.
	if mode == "enemy" and _target_node:
		var cur: float = _target_node.HEALTH
		var maxh: float = _target_node.max_health if "max_health" in _target_node else 20.0
		if cur != _last_hp or maxh != _last_max:
			_refresh_from_enemy()


func _refresh_from_playerstats() -> void:
	_update_bar(PlayerStats.current_hp, PlayerStats.max_hp)


func _refresh_from_enemy() -> void:
	var cur: float = _target_node.HEALTH
	var maxh: float = _target_node.max_health if "max_health" in _target_node else 20.0
	_update_bar(cur, maxh)


func _update_bar(cur: float, maxh: float) -> void:
	_last_hp = cur
	_last_max = maxh
	bar.max_value = maxh
	bar.value = max(0.0, cur)
	var pct := cur / maxh if maxh > 0 else 0.0
	var color: Color
	if pct > 0.6:
		color = Color(0.3, 0.85, 0.3)
	elif pct > 0.3:
		color = Color(0.95, 0.8, 0.2)
	else:
		color = Color(0.9, 0.2, 0.2)
	# Duplicate the style so this instance has its own — otherwise all bars share one.
	var style := bar.get_theme_stylebox("fill") as StyleBoxFlat
	if style:
		var owned := style.duplicate() as StyleBoxFlat
		owned.bg_color = color
		bar.add_theme_stylebox_override("fill", owned)
