extends Camera3D

var player: Node3D
const OFFSET := Vector3(0, 9, 7)

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = 14
	rotation_degrees = Vector3(-52, 0, 0)
	current = true

func snap() -> void:
	if player:
		global_position = player.global_position + OFFSET

func _process(delta: float) -> void:
	if player == null:
		return
	var target = player.global_position + OFFSET
	global_position = global_position.lerp(target, clamp(delta * 6.0, 0.0, 1.0))
