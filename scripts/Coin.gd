extends Area3D

const ModelUtil = preload("res://scripts/ModelUtil.gd")
const MODEL_PATH := "res://assets/props/coin.glb"
const MODEL_SIZE := Vector3(0.5, 0.5, 0.12)

var _spin_t := 0.0
var _collected := false

func _ready() -> void:
	if ResourceLoader.exists(MODEL_PATH):
		var model := ModelUtil.load_fitted(MODEL_PATH, MODEL_SIZE)
		model.rotation_degrees.x = 90
		add_child(model)
	else:
		var mesh := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.3
		cyl.bottom_radius = 0.3
		cyl.height = 0.08
		mesh.mesh = cyl
		mesh.rotation_degrees.x = 90
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.85, 0.2)
		mat.metallic = 0.6
		mat.roughness = 0.3
		mesh.material_override = mat
		add_child(mesh)

	var shape := CollisionShape3D.new()
	var cyl_shape := CylinderShape3D.new()
	cyl_shape.radius = 0.35
	cyl_shape.height = 0.4
	shape.shape = cyl_shape
	shape.rotation_degrees.x = 90
	add_child(shape)

	add_to_group("coin")
	collision_layer = 8
	collision_mask = 0
	monitoring = false
	monitorable = true

func _physics_process(delta: float) -> void:
	_spin_t += delta
	rotation.y = _spin_t * 2.5
	position.y = 0.6 + sin(_spin_t * 3.0) * 0.08

func collect() -> void:
	if _collected:
		return
	_collected = true
	Sfx.play("coin")
	GameManager.add_coin()
	queue_free()
