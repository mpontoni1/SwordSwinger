class_name BoonEffect
extends Resource

enum Rarity { COMMON, RARE, EPIC, LEGENDARY }
enum God { THOR, ODIN, LOKI }

@export var id: StringName
@export var display_name: String = "Unnamed Boon"
@export_multiline var description: String = ""
@export var god: God = God.THOR
@export var rarity: Rarity = Rarity.COMMON

@export var max_hp_bonus: int = 0
@export var hp_regen_per_sec: float = 0.0

@export var move_speed_mult: float = 1.0
@export var damage_mult: float = 1.0
@export var attack_speed_mult: float = 1.0
@export var dodge_cooldown_mult: float = 1.0
