extends CharacterBody3D

# Nodes
@onready var model := $Viking_Male
@onready var camera: Camera3D = $Camera3D
@onready var anim_player: AnimationPlayer = $Viking_Male/AnimationPlayer
@onready var hit_box: Area3D = $HitBox
@onready var Particle2: CPUParticles3D = $Viking_Male/CharacterArmature/Skeleton3D/BoneAttachment3D2/CPUParticles3D
@onready var Particle1: CPUParticles3D = $Viking_Male/CharacterArmature/Skeleton3D/BoneAttachment3D3/CPUParticles3D
@onready var hp: Label3D = $Viking_Male/Label3D

#var SPEED := 6.0
#var HEALTH := 100 obsolete


const ROLL_SPEED := 15.0
const ROTATION_SPEED := 6.0

# State
var is_rolling := false
var can_roll := true
var roll_direction := Vector3.ZERO
var is_attacking := false
var is_dead := false

func _ready() -> void:
	add_to_group("player")
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	#anim_player.speed_scale = 1.0
	#SPEED = 6.0
	if anim_name == "CharacterArmature|Roll":
		is_rolling = false
	elif anim_name == "CharacterArmature|SwordSlash":
		is_attacking = false
		Particle1.lifetime = 1
		Particle2.lifetime = 1
		Particle1.speed_scale = 1
		Particle2.speed_scale = 1
		Particle1.amount = 8
		Particle2.amount = 8
	elif anim_name == "CharacterArmature|Death":
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := _get_move_direction()

	if Input.is_key_pressed(KEY_SHIFT) and can_roll and not is_rolling \
			and not is_attacking and direction.length() > 0:
		_start_roll(direction)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
			and not is_attacking and not is_rolling:
		anim_player.speed_scale = 2.0
		#SPEED = 10.0
		Particle1.emitting = true
		Particle2.emitting = true
		Particle1.lifetime = 1.42
		Particle2.lifetime = 1.42
		Particle1.speed_scale = 4.3
		Particle2.speed_scale = 4.3
		Particle1.amount = 15
		Particle2.amount = 15
		_start_attack()

	if is_rolling:
		_handle_roll(delta)
	elif direction.length() > 0:
		_handle_movement(direction, delta)
	else:
		_handle_idle(delta)

	move_and_slide()
	hp.text = str(PlayerStats.current_hp)

# --- Helpers ---

func _get_move_direction() -> Vector3:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var cam_forward := -camera.global_transform.basis.z
	var cam_right := camera.global_transform.basis.x
	cam_forward.y = 0
	cam_right.y = 0
	return (cam_right * input.x + cam_forward * -input.y).normalized()

func _start_roll(direction: Vector3) -> void:
	is_rolling = true
	can_roll = false
	roll_direction = direction
	play_anim("CharacterArmature|Roll")
	_roll_cooldown()

func _start_attack() -> void:
	is_attacking = true
	anim_player.play("CharacterArmature|SwordSlash")
	attack()

func _handle_roll(delta: float) -> void:
	velocity.x = roll_direction.x * ROLL_SPEED
	velocity.z = roll_direction.z * ROLL_SPEED
	var angle := atan2(roll_direction.x, roll_direction.z)
	model.rotation.y = lerp_angle(model.rotation.y, angle, ROTATION_SPEED * delta)

func _handle_movement(direction: Vector3, delta: float) -> void:
	velocity.x = direction.x * PlayerStats.move_speed
	velocity.z = direction.z * PlayerStats.move_speed
	var angle := atan2(direction.x, direction.z)
	model.rotation.y = lerp_angle(model.rotation.y, angle, ROTATION_SPEED * delta)
	if not is_attacking:
		play_anim("CharacterArmature|Run")
		Particle1.emitting = true
		Particle2.emitting = true

func _handle_idle(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, PlayerStats.move_speed)
	velocity.z = move_toward(velocity.z, 0, PlayerStats.move_speed)
	if not is_attacking:
		play_anim("CharacterArmature|Idle")
		Particle1.emitting = false
		Particle2.emitting = false

func play_anim(anim_name: String) -> void:
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

func _roll_cooldown() -> void:
	await get_tree().create_timer(PlayerStats.dodge_cooldown).timeout
	can_roll = true

func attack() -> void:
	var enemies = hit_box.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.has_method("get_damage_mob"):
			enemy.get_damage_mob(PlayerStats.get_attack_damage())

func get_damage_player() -> void:
	if is_dead:
		return
	PlayerStats.take_damage(10)
	if PlayerStats.current_hp <= 0:
		hp.text = str(0)
		die()

func die() -> void:
	is_dead = true
	is_attacking = false
	is_rolling = false
	velocity = Vector3.ZERO
	Particle1.emitting = false
	Particle2.emitting = false
	play_anim("CharacterArmature|Death")
