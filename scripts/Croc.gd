extends Area3D

const ModelUtil = preload("res://scripts/ModelUtil.gd")
const DEFAULT_MODEL_PATH = "res://assets/creatures/crocodile.glb"

var velocity_x: float = 0.0
var half_range: float = 20.0

func setup(vel_x: float, size: Vector3, playfield_width: float, model_path: String = DEFAULT_MODEL_PATH, fallback_color: Color = Color(0.25, 0.45, 0.25)) -> void:
	velocity_x = vel_x
	half_range = playfield_width * 0.5

	if ResourceLoader.exists(model_path):
		var facing_yaw = 90.0 + (180.0 if vel_x < 0.0 else 0.0)
		add_child(ModelUtil.load_fitted(model_path, size, facing_yaw))
	else:
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = size
		mesh.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = fallback_color
		mesh.material_override = mat
		add_child(mesh)

	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	add_child(shape)

	collision_layer = 4
	collision_mask = 0
	monitoring = false
	monitorable = true

func _physics_process(delta: float) -> void:
	position.x += velocity_x * delta
	if position.x > half_range:
		position.x = -half_range
	elif position.x < -half_range:
		position.x = half_range
