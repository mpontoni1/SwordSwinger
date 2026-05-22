# Plays one-shot SFX. Autoloaded as "SoundManager".
# Drop wav/ogg files into res://audio/sfx/ with names matching the keys below.
# Missing files are silently skipped — game stays playable even without audio.
#
# Usage from anywhere:
#   SoundManager.play("sword_swing")
#   SoundManager.play("enemy_hurt", -3.0)   # volume offset in dB
extends Node

const SFX_DIR := "res://audio/sfx/"
const DEFAULT_VOLUME_DB := -20.0

# Map of sound key -> list of player pool. We pool a few players per key
# so rapid-fire sounds (multiple sword swings, simultaneous enemy hits)
# don't cut each other off.
const POOL_SIZE := 4

var _streams: Dictionary = {}    # key -> AudioStream
var _players: Dictionary = {}    # key -> Array[AudioStreamPlayer]


func _ready() -> void:
	_load_sfx()
	# Wire up signals so combat code doesn't need to manually call play()
	if PlayerStats:
		PlayerStats.boon_applied.connect(func(_b): play("boon_pickup"))
		PlayerStats.player_died.connect(func(): play("player_die"))
	if has_node("/root/WaveManager"):
		var wm = get_node("/root/WaveManager")
		wm.wave_started.connect(func(_n, _t): play("wave_start"))
		wm.wave_cleared.connect(func(_n): play("wave_clear"))
		wm.run_won.connect(func(): play("victory"))
		wm.run_lost.connect(func(): play("player_die"))


func _load_sfx() -> void:
	var dir := DirAccess.open(SFX_DIR)
	if dir == null:
		push_warning("SoundManager: %s does not exist (no sounds will play)" % SFX_DIR)
		return
	dir.list_dir_begin()
	var f := dir.get_next()
	var loaded := 0
	while f != "":
		if not dir.current_is_dir() and (f.ends_with(".wav") or f.ends_with(".ogg") or f.ends_with(".mp3")):
			var key := f.get_basename()
			var stream = load(SFX_DIR + f) as AudioStream
			if stream:
				_streams[key] = stream
				_create_pool(key, stream)
				loaded += 1
		f = dir.get_next()
	print("[SoundManager] Loaded %d SFX from %s" % [loaded, SFX_DIR])


func _create_pool(key: String, stream: AudioStream) -> void:
	var pool: Array[AudioStreamPlayer] = []
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.stream = stream
		p.bus = "Master"   # default audio bus
		add_child(p)
		pool.append(p)
	_players[key] = pool


# Play a sound by key (filename without extension). Volume offset in dB.
func play(key: String, volume_db: float = DEFAULT_VOLUME_DB) -> void:
	if not _players.has(key):
		# Silently skip missing files — useful for graceful degradation.
		return
	var pool: Array = _players[key]
	# Find a free player (not currently playing) or take the first one.
	for p in pool:
		if not p.playing:
			p.volume_db = volume_db
			p.play()
			return
	# All busy — interrupt the first (rare with POOL_SIZE = 4)
	pool[0].volume_db = volume_db
	pool[0].play()
