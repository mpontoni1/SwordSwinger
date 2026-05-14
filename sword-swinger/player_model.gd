extends CharacterBody3D

# Nodes
@onready var model := $Viking_Male
@onready var camera: Camera3D = $Camera3D
@onready var anim_player: AnimationPlayer = $Viking_Male/AnimationPlayer

# Constants
const SPEED := 5.0
const ROLL_SPEED := 15.0
const ROTATION_SPEED := 6.0

# State
var is_rolling := false
var can_roll := true
var roll_direction := Vector3.ZERO


func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "CharacterArmature|Roll":
		is_rolling = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := _get_move_direction()

	if Input.is_key_pressed(KEY_SHIFT) and can_roll and not is_rolling and direction.length() > 0:
		_start_roll(direction)

	if is_rolling:
		_handle_roll(delta)
	elif direction.length() > 0:
		_handle_movement(direction, delta)
	else:
		_handle_idle(delta)

	move_and_slide()


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


func _handle_roll(delta: float) -> void:
	velocity.x = roll_direction.x * ROLL_SPEED
	velocity.z = roll_direction.z * ROLL_SPEED
	var angle := atan2(roll_direction.x, roll_direction.z)
	model.rotation.y = lerp_angle(model.rotation.y, angle, ROTATION_SPEED * delta)


func _handle_movement(direction: Vector3, delta: float) -> void:
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	var angle := atan2(direction.x, direction.z)
	model.rotation.y = lerp_angle(model.rotation.y, angle, ROTATION_SPEED * delta)
	play_anim("CharacterArmature|Run")


func _handle_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)
	play_anim("CharacterArmature|Idle")


func play_anim(anim_name: String) -> void:
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)


func _roll_cooldown() -> void:
	await get_tree().create_timer(1.0).timeout
	can_roll = true
