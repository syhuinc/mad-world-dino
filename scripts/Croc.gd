extends Area3D

const ModelUtil = preload("res://scripts/ModelUtil.gd")
const MODEL_PATH = "res://assets/creatures/crocodile.glb"

var velocity_x: float = 0.0
var half_range: float = 20.0

func setup(vel_x: float, size: Vector3, playfield_width: float) -> void:
	velocity_x = vel_x
	half_range = playfield_width * 0.5

	if ResourceLoader.exists(MODEL_PATH):
		var facing_yaw = 90.0 + (180.0 if vel_x < 0.0 else 0.0)
		add_child(ModelUtil.load_fitted(MODEL_PATH, size, facing_yaw))
	else:
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = size
		mesh.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.25, 0.45, 0.25)
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
