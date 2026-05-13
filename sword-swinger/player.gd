extends CharacterBody3D

@onready var model: MeshInstance3D = $MeshInstance3D
@onready var camera: Camera3D = $Camera3D

var ray_origin = Vector3()
var ray_end = Vector3()

const SPEED = 5.0
const JUMP_VELOCITY = 6


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	look_at_mouse()
	
func look_at_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_pos)
	ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 2000
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_end
	var intersection = space_state.intersect_ray(params)
	
	if !intersection.is_empty():
		var pos = intersection.position
		var look = Vector3(pos.x, position.y,pos.z)
		model.look_at(look,Vector3.UP)
