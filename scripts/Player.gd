extends Area3D

const TILE_SIZE := 2.0
const COLS := 9
const HOP_TIME := 0.14
const HOP_HEIGHT := 0.5

var lane_manager: Node3D

var row: int = 0
var col: int = 4
var is_hopping: bool = false
var hop_elapsed: float = 0.0
var hop_from: Vector3
var hop_to: Vector3

var riding_crocs: Array = []

var _touch_start: Vector2
var _touch_active: bool = false
var _mesh: MeshInstance3D

func _ready() -> void:
	collision_layer = 1
	collision_mask = (1 << 1) | (1 << 2) | (1 << 3) # dino, croc, coin
	monitoring = true

	var mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.35
	capsule.height = 1.2
	mesh.mesh = capsule
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.55, 0.2)
	mesh.material_override = mat
	mesh.position.y = 0.6
	add_child(mesh)
	_mesh = mesh

	var shape := CollisionShape3D.new()
	var cs := CapsuleShape3D.new()
	cs.radius = 0.35
	cs.height = 1.2
	shape.shape = cs
	shape.position.y = 0.6
	add_child(shape)

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	global_position = _cell_to_world(row, col)

func reset() -> void:
	row = 0
	col = int(COLS / 2)
	is_hopping = false
	riding_crocs.clear()
	global_position = _cell_to_world(row, col)

func _cell_to_world(r: int, c: int) -> Vector3:
	return Vector3((c - int(COLS / 2)) * TILE_SIZE, 0, -r * TILE_SIZE)

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	if is_hopping:
		return
	if event.is_action_pressed("ui_up") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_W):
		_try_move(1, 0)
	elif event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_S):
		_try_move(-1, 0)
	elif event.is_action_pressed("ui_left") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_A):
		_try_move(0, -1)
	elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_D):
		_try_move(0, 1)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
			_touch_active = true
		else:
			if _touch_active:
				_handle_swipe(event.position - _touch_start)
			_touch_active = false

func _handle_swipe(delta: Vector2) -> void:
	if GameManager.state != GameManager.State.PLAYING or is_hopping:
		return
	if delta.length() < 30:
		return
	if abs(delta.x) > abs(delta.y):
		_try_move(0, 1 if delta.x > 0 else -1)
	else:
		_try_move(1 if delta.y < 0 else -1, 0)

func _try_move(d_row: int, d_col: int) -> void:
	var target_row = row + d_row
	var target_col = col + d_col
	if target_row < 0:
		return
	if target_col < 0 or target_col >= COLS:
		return
	if lane_manager:
		lane_manager.ensure_row(target_row + 6)
	row = target_row
	col = target_col
	riding_crocs.clear()
	hop_from = global_position
	hop_to = _cell_to_world(row, col)
	hop_elapsed = 0.0
	is_hopping = true
	Sfx.play("hop")
	if lane_manager:
		lane_manager.on_player_row_changed(row)

func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	if is_hopping:
		hop_elapsed += delta
		var t = clamp(hop_elapsed / HOP_TIME, 0.0, 1.0)
		var pos = hop_from.lerp(hop_to, t)
		var height_phase = sin(t * PI)
		pos.y = height_phase * HOP_HEIGHT
		global_position = pos
		var stretch = 1.0 + height_phase * 0.25
		_mesh.scale = Vector3(1.0 / sqrt(stretch), stretch, 1.0 / sqrt(stretch))
		if t >= 1.0:
			is_hopping = false
			global_position = hop_to
			_mesh.scale = Vector3(1.25, 0.72, 1.25)
			_check_landing()
			_spawn_landing_puff()
	else:
		_mesh.scale = _mesh.scale.lerp(Vector3.ONE, clamp(delta * 10.0, 0.0, 1.0))
		_check_resting()

func _spawn_landing_puff() -> void:
	if lane_manager == null:
		return
	if lane_manager.get_lane_type(row) == lane_manager.LaneType.RIVER:
		return
	var particles := GPUParticles3D.new()
	particles.amount = 8
	particles.lifetime = 0.4
	particles.one_shot = true
	particles.explosiveness = 1.0
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 1.0
	mat.initial_velocity_max = 2.0
	mat.gravity = Vector3(0, -4, 0)
	mat.scale_min = 0.05
	mat.scale_max = 0.12
	particles.process_material = mat
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	var quad_mat := StandardMaterial3D.new()
	quad_mat.albedo_color = Color(0.85, 0.8, 0.6, 0.8)
	quad_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	quad.material = quad_mat
	particles.draw_pass_1 = quad
	get_parent().add_child(particles)
	particles.global_position = global_position + Vector3(0, 0.05, 0)
	particles.emitting = true
	var timer := get_tree().create_timer(particles.lifetime + 0.1)
	timer.timeout.connect(particles.queue_free)

func _check_landing() -> void:
	if lane_manager == null:
		return
	var lane_type = lane_manager.get_lane_type(row)
	if lane_type == lane_manager.LaneType.RIVER:
		if riding_crocs.is_empty():
			_die()

func _check_resting() -> void:
	if lane_manager == null:
		return
	var lane_type = lane_manager.get_lane_type(row)
	if lane_type != lane_manager.LaneType.RIVER:
		return
	if riding_crocs.is_empty():
		_die()
		return
	var drift := 0.0
	for c in riding_crocs:
		if is_instance_valid(c):
			drift += c.velocity_x
	drift /= riding_crocs.size()
	global_position.x += drift * get_physics_process_delta_time()
	var half_width = (COLS - 1) * 0.5 * TILE_SIZE
	if global_position.x < -half_width - TILE_SIZE or global_position.x > half_width + TILE_SIZE:
		_die()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("dino"):
		_die()
	elif area.is_in_group("croc"):
		riding_crocs.append(area)
	elif area.is_in_group("coin"):
		if area.has_method("collect"):
			area.collect()

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("croc"):
		riding_crocs.erase(area)

func _die() -> void:
	if GameManager.state == GameManager.State.PLAYING:
		Sfx.play("death")
		GameManager.end_run()
