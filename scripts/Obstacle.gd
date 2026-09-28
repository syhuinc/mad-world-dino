extends Area3D

var velocity_x: float = 0.0
var half_range: float = 20.0

func setup(color: Color, size: Vector3, vel_x: float, playfield_width: float) -> void:
	velocity_x = vel_x
	half_range = playfield_width * 0.5 + size.z

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	add_child(mesh)

	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	add_child(shape)

	collision_layer = 2
	collision_mask = 0
	monitoring = false
	monitorable = true

func _physics_process(delta: float) -> void:
	position.x += velocity_x * delta
	if position.x > half_range:
		position.x = -half_range
	elif position.x < -half_range:
		position.x = half_range
