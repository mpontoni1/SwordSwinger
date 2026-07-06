extends Node

signal wave_started(wave_number: int, total_waves: int)
signal wave_cleared(wave_number: int)
signal run_won
signal run_lost

const WAVE_DIR := "res://resources/waves/"
const SHRINE_SCENE := preload("res://scenes/boon_shrine.tscn")
const POST_BOON_DELAY := 3.0

var all_waves: Array[WaveDefinition] = []
var current_wave_index: int = -1
var alive_enemies: Array = []
var last_death_position: Vector3 = Vector3.ZERO
var _run_active: bool = false
var _wave_clear_announced: bool = false

func _ready() -> void:
	_load_waves()
	PlayerStats.player_died.connect(_on_player_died)


func _load_waves() -> void:
	var dir := DirAccess.open(WAVE_DIR)
	if dir == null:
		push_warning("WaveManager: could not open %s" % WAVE_DIR)
		return
	var files: Array[String] = []
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir() and f.ends_with(".tres"):
			files.append(f)
		f = dir.get_next()
	files.sort()
	for fname in files:
		var res = load(WAVE_DIR + fname)
		if res is WaveDefinition:
			all_waves.append(res)
	print("[WaveManager] Loaded %d waves" % all_waves.size())


func start_run() -> void:
	if all_waves.is_empty():
		push_warning("WaveManager: no waves loaded")
		return
	if _run_active:
		return
	PlayerStats.reset()
	current_wave_index = -1
	_run_active = true
	_start_next_wave()


func _start_next_wave() -> void:
	current_wave_index += 1
	if current_wave_index >= all_waves.size():
		_finish_run()
		return
	_wave_clear_announced = false
	var wave := all_waves[current_wave_index]
	var wave_num := current_wave_index + 1
	print("[WaveManager] Wave %d starting (%d enemies)" % [wave_num, wave.enemies.size()])
	wave_started.emit(wave_num, all_waves.size())
	_spawn_wave(wave)


func _spawn_wave(wave: WaveDefinition) -> void:
	var spawn_points := get_tree().get_nodes_in_group("enemy_spawn")
	if spawn_points.is_empty():
		push_warning("WaveManager: no Marker3D in group 'enemy_spawn'")
		return
	for enemy_scene in wave.enemies:
		var enemy = enemy_scene.instantiate()
		if enemy == null:
			continue
		var spawn = spawn_points.pick_random() as Node3D
		spawn.get_parent().add_child(enemy)
		enemy.global_position = spawn.global_position
		alive_enemies.append(enemy)
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)
		enemy.tree_exited.connect(_on_enemy_tree_exited.bind(enemy))
		if wave.spawn_interval > 0.0:
			await get_tree().create_timer(wave.spawn_interval).timeout
			if not _run_active:
				return


func _on_enemy_died(enemy) -> void:
	if enemy is Node3D:
		last_death_position = enemy.global_position
	_remove_enemy(enemy)


func _on_enemy_tree_exited(enemy) -> void:
	_remove_enemy(enemy)


func _remove_enemy(enemy) -> void:
	if enemy in alive_enemies:
		alive_enemies.erase(enemy)
	if alive_enemies.is_empty() and _run_active and not _wave_clear_announced:
		_wave_clear_announced = true
		_on_wave_cleared()


func _on_wave_cleared() -> void:
	var wave_num := current_wave_index + 1
	print("[WaveManager] Wave %d cleared" % wave_num)
	wave_cleared.emit(wave_num)
	var wave := all_waves[current_wave_index]
	if wave.is_final:
		_finish_run()
		return
	var shrine = SHRINE_SCENE.instantiate()
	get_tree().current_scene.add_child(shrine)
	shrine.global_position = last_death_position + Vector3(0, 0.1, 0)
	PlayerStats.boon_applied.connect(_on_boon_picked, CONNECT_ONE_SHOT)


func _on_boon_picked(_boon) -> void:
	await get_tree().create_timer(POST_BOON_DELAY).timeout
	if _run_active:
		_start_next_wave()


func _on_player_died() -> void:
	print("[WaveManager] Player died — run lost")
	_run_active = false
	for e in alive_enemies:
		if is_instance_valid(e):
			e.queue_free()
	alive_enemies.clear()
	run_lost.emit()


func _finish_run() -> void:
	print("[WaveManager] Run won")
	_run_active = false
	run_won.emit()
