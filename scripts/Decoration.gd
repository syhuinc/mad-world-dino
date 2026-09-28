extends Node3D

enum Kind { ROCK, BUSH, PALM_TREE, FLOWER, REED, LILY_PAD }

func setup(kind: int) -> void:
	match kind:
		Kind.ROCK:
			_add_rock()
		Kind.BUSH:
			_add_bush()
		Kind.PALM_TREE:
			_add_palm_tree()
		Kind.FLOWER:
			_add_flower()
		Kind.REED:
			_add_reed()
		Kind.LILY_PAD:
			_add_lily_pad()

func _mesh_child(mesh: Mesh, color: Color, pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mi.material_override = mat
	mi.position = pos
	add_child(mi)
	return mi

func _add_rock() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = randf_range(0.25, 0.4)
	sphere.height = sphere.radius * 1.6
	_mesh_child(sphere, Color(0.5, 0.5, 0.52), Vector3(0, sphere.radius * 0.5, 0))

func _add_bush() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.6
	_mesh_child(sphere, Color(0.25, 0.55, 0.2), Vector3(0, 0.3, 0))

func _add_palm_tree() -> void:
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.08
	trunk.bottom_radius = 0.12
	trunk.height = 1.6
	_mesh_child(trunk, Color(0.5, 0.35, 0.2), Vector3(0, 0.8, 0))
	var crown := SphereMesh.new()
	crown.radius = 0.55
	crown.height = 0.7
	_mesh_child(crown, Color(0.2, 0.6, 0.25), Vector3(0, 1.7, 0))

func _add_flower() -> void:
	var stem := CylinderMesh.new()
	stem.top_radius = 0.02
	stem.bottom_radius = 0.03
	stem.height = 0.3
	_mesh_child(stem, Color(0.3, 0.55, 0.25), Vector3(0, 0.15, 0))
	var bloom_colors = [Color(1, 0.9, 0.2), Color(1, 0.4, 0.6), Color(1, 1, 1)]
	var bloom := SphereMesh.new()
	bloom.radius = 0.09
	bloom.height = 0.14
	_mesh_child(bloom, bloom_colors[randi() % bloom_colors.size()], Vector3(0, 0.32, 0))

func _add_reed() -> void:
	for i in range(3):
		var blade := CylinderMesh.new()
		blade.top_radius = 0.015
		blade.bottom_radius = 0.03
		blade.height = randf_range(0.5, 0.8)
		var mi := _mesh_child(blade, Color(0.3, 0.55, 0.2), Vector3(randf_range(-0.15, 0.15), blade.height * 0.5, randf_range(-0.1, 0.1)))
		mi.rotation.z = randf_range(-0.15, 0.15)

func _add_lily_pad() -> void:
	var disc := CylinderMesh.new()
	disc.top_radius = 0.3
	disc.bottom_radius = 0.3
	disc.height = 0.03
	_mesh_child(disc, Color(0.25, 0.6, 0.25), Vector3(0, 0.05, 0))
