# Central state singleton. Combat reads from here; boons write here
# Registered as autoload "PlayerStats" in Project Settings → Globals.
extends Node

signal stats_changed
signal player_died

const BASE_MAX_HP := 100
const BASE_MOVE_SPEED := 6.0
const BASE_DAMAGE := 10
const BASE_DODGE_COOLDOWN := 1.0

var max_hp: int = BASE_MAX_HP
var current_hp: int = BASE_MAX_HP
var move_speed: float = BASE_MOVE_SPEED
var damage_mult: float = 1.0
var attack_speed_mult: float = 1.0
var dodge_cooldown: float = BASE_DODGE_COOLDOWN


func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp = max(0, current_hp - amount)
	stats_changed.emit()
	if current_hp <= 0:
		player_died.emit()


func get_attack_damage() -> int:
	return int(BASE_DAMAGE * damage_mult)


func reset() -> void:
	max_hp = BASE_MAX_HP
	current_hp = BASE_MAX_HP
	move_speed = BASE_MOVE_SPEED
	damage_mult = 1.0
	attack_speed_mult = 1.0
	dodge_cooldown = BASE_DODGE_COOLDOWN
	stats_changed.emit()
	
#debug purposes
func _ready() -> void:
	print("[PlayerStats] ready — HP=%d, speed=%.1f, damage=%d" % [current_hp, move_speed, get_attack_damage()])
