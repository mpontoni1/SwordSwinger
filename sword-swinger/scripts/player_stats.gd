#combat cita podake odavde; boons pisu ovdje
#autoload PlayerStats u Globals u Project Settings
extends Node

signal stats_changed
signal boon_applied(boon: BoonEffect)
signal player_died

const BASE_MAX_HP := 100
const BASE_MOVE_SPEED := 6.0
const BASE_DAMAGE := 5
const BASE_DODGE_COOLDOWN := 1.0
const BASE_HP_REGEN = 1.0

var max_hp: int = BASE_MAX_HP
var current_hp: int = BASE_MAX_HP
var move_speed: float = BASE_MOVE_SPEED
var damage_mult: float = 1.0
var attack_speed_mult: float = 1.0
var dodge_cooldown: float = BASE_DODGE_COOLDOWN
var hp_regen_per_sec: float = BASE_HP_REGEN

var owned_boons: Array[BoonEffect] = []
var _regen_accum: float = 0.0


func _ready() -> void:
	print("[PlayerStats] ready — HP=%d, speed=%.1f, damage=%d" % [current_hp, move_speed, get_attack_damage()])


func _process(delta: float) -> void:
	if hp_regen_per_sec > 0.0 and current_hp < max_hp:
		_regen_accum += hp_regen_per_sec * delta
		if _regen_accum >= 1.0:
			var heal := int(_regen_accum)
			current_hp = min(max_hp, current_hp + heal)
			_regen_accum -= heal
			stats_changed.emit()


func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp = max(0, current_hp - amount)
	stats_changed.emit()
	if current_hp <= 0:
		player_died.emit()


func apply_boon(boon: BoonEffect) -> void:
	owned_boons.append(boon)
	max_hp += boon.max_hp_bonus
	if boon.max_hp_bonus > 0:
		current_hp = min(max_hp, current_hp + boon.max_hp_bonus)
	else:
		current_hp = min(current_hp, max_hp)
	hp_regen_per_sec += boon.hp_regen_per_sec
	move_speed *= boon.move_speed_mult
	damage_mult *= boon.damage_mult
	attack_speed_mult *= boon.attack_speed_mult
	dodge_cooldown *= boon.dodge_cooldown_mult
	print("[Boon] Applied: %s" % boon.display_name)
	stats_changed.emit()
	boon_applied.emit(boon)


func get_attack_damage() -> int:
	return int(BASE_DAMAGE * damage_mult)


func reset() -> void:
	max_hp = BASE_MAX_HP
	current_hp = BASE_MAX_HP
	move_speed = BASE_MOVE_SPEED
	damage_mult = 1.0
	attack_speed_mult = 1.0
	dodge_cooldown = BASE_DODGE_COOLDOWN
	hp_regen_per_sec = BASE_HP_REGEN
	_regen_accum = 0.0
	owned_boons.clear()
	stats_changed.emit()
