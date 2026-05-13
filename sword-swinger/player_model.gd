extends CharacterBody3D

@onready var model = $Viking_Male       
@onready var camera: Camera3D = $Camera3D
@onready var anim_player: AnimationPlayer = $Viking_Male/AnimationPlayer

var ray_origin = Vector3()
var ray_end = Vector3()
var is_jumping = false
var is_rolling = false
var can_roll = true
var roll_direction = Vector3()  # locked direction during roll

const SPEED = 5.0
const ROLL_SPEED = 15.0
const JUMP_VELOCITY = 6
const ROTATION_SPEED = 6.0

func _ready():
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	if anim_name == "CharacterArmature|Jump":
		is_jumping = false
	if anim_name == "CharacterArmature|Roll":
		is_rolling = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor() and is_jumping and anim_player.current_animation != "CharacterArmature|Jump":
		is_jumping = false

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		is_jumping = true
		velocity.y = JUMP_VELOCITY
		play_anim("CharacterArmature|Jump")

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var cam_forward = camera.global_transform.basis.z * -1
	var cam_right = camera.global_transform.basis.x
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()

	var direction = (cam_right * input_dir.x + cam_forward * -input_dir.y).normalized()

	if Input.is_key_pressed(KEY_SHIFT) and can_roll and direction.length() > 0 and not is_rolling:
		is_rolling = true
		can_roll = false
		roll_direction = direction   # lock the direction
		play_anim("CharacterArmature|Roll")
		roll_cooldown()

	if is_rolling:
		velocity.x = roll_direction.x * ROLL_SPEED
		velocity.z = roll_direction.z * ROLL_SPEED
		var target_angle = atan2(roll_direction.x, roll_direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, ROTATION_SPEED * delta)
	elif direction.length() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var target_angle = atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, ROTATION_SPEED * delta)
		if not is_jumping:
			play_anim("CharacterArmature|Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if not is_jumping and not is_rolling:
			play_anim("CharacterArmature|Idle")

	move_and_slide()

func roll_cooldown():
	await get_tree().create_timer(1.0).timeout
	can_roll = true

func play_anim(anim_name: String):
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)
