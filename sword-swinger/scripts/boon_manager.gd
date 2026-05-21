extends Node

const BOON_DIR := "res://resources/boons/"

const RARITY_WEIGHTS := {
	BoonEffect.Rarity.COMMON: 60,
	BoonEffect.Rarity.RARE: 30,
	BoonEffect.Rarity.EPIC: 9,
	BoonEffect.Rarity.LEGENDARY: 1,
}

var all_boons: Array[BoonEffect] = []


func _ready() -> void:
	_load_all_boons()


func _load_all_boons() -> void:
	var dir := DirAccess.open(BOON_DIR)
	if dir == null:
		push_warning("BoonManager: could not open %s" % BOON_DIR)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".res")):
			var res = load(BOON_DIR + file_name)
			if res is BoonEffect:
				all_boons.append(res)
		file_name = dir.get_next()
	print("[BoonManager] Loaded %d boons" % all_boons.size())


func roll_choices(count: int = 3) -> Array[BoonEffect]:
	var available: Array[BoonEffect] = []
	for boon in all_boons:
		if boon not in PlayerStats.owned_boons:
			available.append(boon)
	var choices: Array[BoonEffect] = []
	for i in range(count):
		if available.is_empty():
			break
		var picked := _weighted_pick(available)
		choices.append(picked)
		available.erase(picked)
	return choices


func _weighted_pick(pool: Array[BoonEffect]) -> BoonEffect:
	var total := 0
	for b in pool:
		total += RARITY_WEIGHTS.get(b.rarity, 1)
	var r := randi() % total
	var running := 0
	for b in pool:
		running += RARITY_WEIGHTS.get(b.rarity, 1)
		if r < running:
			return b
	return pool[0]
