extends Node3D

const ModelUtil = preload("res://scripts/ModelUtil.gd")

enum Kind { ROCK, BUSH, PALM_TREE, FLOWER, REED, LILY_PAD, FENCE }

const MODEL_PATHS := {
	Kind.ROCK: "res://assets/props/rock.glb",
	Kind.BUSH: "res://assets/props/bush.glb",
	Kind.PALM_TREE: "res://assets/props/palm.glb",
	Kind.FLOWER: "res://assets/props/flower.glb",
	Kind.REED: "res://assets/props/reed.glb",
	Kind.LILY_PAD: "res://assets/props/lily_pad.glb",
	Kind.FENCE: "res://assets/props/fence.glb",
}
const MODEL_SIZES := {
	Kind.ROCK: Vector3(0.55, 0.45, 0.55),
	Kind.BUSH: Vector3(0.75, 0.65, 0.75),
	Kind.PALM_TREE: Vector3(0.6, 1.9, 0.6),
	Kind.FLOWER: Vector3(0.35, 0.4, 0.35),
	Kind.REED: Vector3(0.3, 0.7, 0.3),
	Kind.LILY_PAD: Vector3(0.6, 0.06, 0.6),
	Kind.FENCE: Vector3(1.2, 0.6, 0.15),
}

func setup(kind: int) -> void:
	var model_path: String = MODEL_PATHS.get(kind, "")
	if model_path != "" and ResourceLoader.exists(model_path):
		var size: Vector3 = MODEL_SIZES[kind]
		var model := ModelUtil.load_fitted(model_path, size)
		model.position.y = size.y * 0.5
		add_child(model)
		return
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
		Kind.FENCE:
			_add_fence()

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

func _add_fence() -> void:
	var post_color = Color(0.5, 0.35, 0.2)
	for x in [-0.5, 0.5]:
		var post := BoxMesh.new()
		post.size = Vector3(0.08, 0.55, 0.08)
		_mesh_child(post, post_color, Vector3(x, 0.275, 0))
	for y in [0.18, 0.4]:
		var rail := BoxMesh.new()
		rail.size = Vector3(1.1, 0.07, 0.05)
		_mesh_child(rail, post_color, Vector3(0, y, 0))
