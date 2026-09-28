extends Area3D

var velocity_x: float = 0.0
var half_range: float = 20.0

func setup(vel_x: float, length: float, playfield_width: float) -> void:
	velocity_x = vel_x
	half_range = playfield_width * 0.5

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(length, 0.3, 1.6)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 0.45, 0.25)
	mesh.material_override = mat
	add_child(mesh)

	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(length, 0.3, 1.6)
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
