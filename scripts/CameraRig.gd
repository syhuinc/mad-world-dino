extends Camera3D

var player: Node3D
const OFFSET := Vector3(0, 7, 3)
const SHAKE_DURATION := 0.3

var _shake_time := 0.0

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = 11
	rotation_degrees = Vector3(-52, 0, 0)
	current = true
	GameManager.game_over.connect(func(_dist, _coins): _shake_time = SHAKE_DURATION)

func snap() -> void:
	if player:
		global_position = player.global_position + OFFSET
		_shake_time = 0.0

func _process(delta: float) -> void:
	if player == null:
		return
	var target = player.global_position + OFFSET
	global_position = global_position.lerp(target, clamp(delta * 6.0, 0.0, 1.0))
	if _shake_time > 0.0:
		_shake_time = max(_shake_time - delta, 0.0)
		var strength = 0.25 * (_shake_time / SHAKE_DURATION)
		global_position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * strength
