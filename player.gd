extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const START_LIFE = 100.0
const LIFE_DRAIN_PER_SEC = 1.0
const ORB_HEAL = 30.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var life: float = START_LIFE
var _drain_accum: float = 0.0
var _game_over: bool = false

@onready var life_label: Label = get_tree().get_first_node_in_group("life_label")
@onready var game_over_label: Label = get_tree().get_first_node_in_group("game_over_label")


func _ready() -> void:
	_update_hud()


func _physics_process(delta: float) -> void:
	if _game_over:
		if Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_ESCAPE):
			_restart()
		return

	# Drain 1 life point per second.
	_drain_accum += delta
	while _drain_accum >= 1.0:
		life -= LIFE_DRAIN_PER_SEC
		_drain_accum -= 1.0
		if life <= 0.0:
			life = 0.0
			_trigger_game_over()
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
	life += amount
	_update_hud()


func _trigger_game_over() -> void:
	_game_over = true
	velocity = Vector3.ZERO
	if game_over_label:
		game_over_label.visible = true
	_update_hud()


func _restart() -> void:
	_game_over = false
	life = START_LIFE
	_drain_accum = 0.0
	if game_over_label:
		game_over_label.visible = false
	# Respawn all orbs.
	for orb in get_tree().get_nodes_in_group("orb"):
		orb.respawn()
	_update_hud()


func _update_hud() -> void:
	if life_label:
		life_label.text = "Life: %d" % int(ceil(life))
