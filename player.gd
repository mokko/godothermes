extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_LIFE = 100.0
const LIFE_DRAIN_PER_SEC = 1.0
const ORB_HEAL = 30.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var life: float = MAX_LIFE
var _drain_accum: float = 0.0

@onready var life_label: Label = get_tree().get_first_node_in_group("life_label")


func _ready() -> void:
	_update_hud()


func _physics_process(delta: float) -> void:
	# Drain 1 life point per second.
	_drain_accum += delta
	while _drain_accum >= 1.0:
		life -= LIFE_DRAIN_PER_SEC
		_drain_accum -= 1.0
	_update_hud()

	# Apply gravity when airborne.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump with Space.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# WASD movement in world space (W = -Z forward, S = +Z back, A = -X left, D = +X right).
	var input_dir := Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	var direction := Vector3(input_dir.x, 0, -input_dir.y).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

	move_and_slide()


func heal(amount: float) -> void:
	life = min(life + amount, MAX_LIFE)
	_update_hud()


func _update_hud() -> void:
	if life_label:
		life_label.text = "Life: %d" % int(ceil(life))
