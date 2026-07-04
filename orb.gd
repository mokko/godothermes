extends Area3D

var _base_y: float


func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	# Gentle spin and bob for visual appeal.
	rotation.y += delta * 2.0
	position.y = _base_y + sin(Time.get_ticks_msec() * 0.002) * 0.15


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.heal(30.0)
		queue_free()
