extends CharacterBody3D

@onready var anim_player: AnimationPlayer = $Goblin_Male/AnimationPlayer
@onready var hitbox: CollisionShape3D = $Area3D/CollisionShape3D
@onready var attack_area: Area3D = $Area3D
@onready var hp: Label3D = $Goblin_Male/Label3D
@onready var death_particle: CPUParticles3D = $Goblin_Male/CharacterArmature/Skeleton3D/BoneAttachment3D/CPUParticles3D

var player = null
var is_attacking = false
var can_deal_damage = true
var is_dead = false

signal died(enemy)

@export var max_health: int = 20
@export var damage: int = 10
var HEALTH: int

# _init runs BEFORE @export values are applied from the scene,
# so we initialize HEALTH in _ready instead.

const SPEED = 5.0
const ROTATION_SPEED = 6.0
@export var attack_cooldown: float = 1.5
@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D

func _ready():
	HEALTH = max_health
	if not has_node("NavigationAgent3D"):
		push_error("Missing NavigationAgent3D child on " + name)
		return
	# Only use player_path if it actually points somewhere valid
	if player_path and has_node(player_path):
		player = get_node(player_path)
	else:
		# Fall back to "player" group — works for runtime-spawned enemies
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	anim_player.animation_finished.connect(_on_animation_finished)
	await get_tree().physics_frame
	await get_tree().physics_frame

func _physics_process(delta):
	if is_dead:
		velocity = Vector3.ZERO
		return
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	if player:
		if is_attacking:
			velocity.x = 0
			velocity.z = 0
		else:
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			var direction = (next_nav_point - global_transform.origin).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			play_anim("CharacterArmature|Run")
			if direction.length() > 0.1:
				var target_angle = atan2(direction.x, direction.z)
				rotation.y = lerp_angle(rotation.y, target_angle, ROTATION_SPEED * delta)
	move_and_slide()
	hp.text = str(HEALTH)

func _on_animation_finished(anim_name: String):
	if anim_name == "CharacterArmature|Punch" and is_attacking:
		anim_player.play("CharacterArmature|Punch")
	elif anim_name == "CharacterArmature|Death":
		queue_free()

func _on_attack_area_body_entered(body):
	if body == player and not is_dead:
		is_attacking = true
		play_anim("CharacterArmature|Punch")
		_attack_loop()

func _on_attack_area_body_exited(body):
	if body == player:
		is_attacking = false

func _attack_loop() -> void:
	while is_attacking and not is_dead:
		if can_deal_damage:
			attack()
			can_deal_damage = false
			await get_tree().create_timer(attack_cooldown).timeout
			can_deal_damage = true
		else:
			await get_tree().physics_frame

func play_anim(anim_name: String) -> void:
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

func attack() -> void:
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("get_damage_player"):
			body.get_damage_player(damage)

func get_damage_mob(amount: int = 10) -> void:
	if is_dead:
		return
	HEALTH -= amount
	SoundManager.play("enemy_hurt")
	if HEALTH <= 0:
		die()

func die() -> void:
	died.emit(self)
	SoundManager.play("enemy_die")
	is_dead = true
	is_attacking = false
	velocity = Vector3.ZERO
	hp.text = "0"
	play_anim("CharacterArmature|Death")
	death_particle.emitting = true
