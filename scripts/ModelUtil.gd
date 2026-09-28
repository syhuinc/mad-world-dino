extends Node

# Loads a .glb, measures its combined mesh bounding box, and scales/centers
# it (non-uniformly, per axis) so that box exactly matches target_size,
# centered on the returned wrapper node's origin — the same convention the
# primitive BoxMesh placeholders used, so existing external positioning
# code (spawn_y = size.y * 0.5, etc.) keeps working unchanged.
static func load_fitted(path: String, target_size: Vector3, y_rotation_degrees: float = 0.0) -> Node3D:
	var scene: PackedScene = load(path)
	var model: Node3D = scene.instantiate()

	# Measure the model's intrinsic (unrotated, unscaled) bounding box first.
	# Godot composes a Node3D's basis as rotation * scale, meaning `scale` is
	# applied along the model's own LOCAL (pre-rotation) axes. If we then
	# rotate 90°, whatever we scaled along local X actually ends up pointing
	# along world Z (and vice versa) — so for a 90°-ish yaw we must swap
	# which target dimension each local axis is scaled to match, or the
	# model comes out sheared.
	var aabb := _get_combined_aabb(model)
	var wrapper := Node3D.new()
	if aabb.size.x <= 0.0001 or aabb.size.y <= 0.0001 or aabb.size.z <= 0.0001:
		wrapper.add_child(model)
		return wrapper

	var rot_mod = fmod(abs(y_rotation_degrees), 180.0)
	var swapped = abs(rot_mod - 90.0) < 1.0
	var target_for_scale = Vector3(target_size.z, target_size.y, target_size.x) if swapped else target_size

	var scale_vec := Vector3(
		target_for_scale.x / aabb.size.x,
		target_for_scale.y / aabb.size.y,
		target_for_scale.z / aabb.size.z
	)
	model.scale = scale_vec
	model.rotation_degrees.y = y_rotation_degrees

	var local_center: Vector3 = aabb.get_center() * scale_vec
	var rotated_center: Vector3 = local_center.rotated(Vector3.UP, deg_to_rad(y_rotation_degrees))
	model.position = -rotated_center

	wrapper.add_child(model)
	return wrapper

static func _all_mesh_instances(node: Node) -> Array:
	var result := []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_all_mesh_instances(child))
	return result

# Transform from `node` down to `root`, computed purely from local
# transforms — unlike global_transform, this works before the model is
# ever added to the scene tree.
static func _transform_relative_to(node: Node3D, root: Node3D) -> Transform3D:
	var t := node.transform
	var p := node.get_parent()
	while p != null and p != root:
		t = p.transform * t
		p = p.get_parent()
	return t

static func _get_combined_aabb(root: Node3D) -> AABB:
	var aabb := AABB()
	var first := true
	for mi in _all_mesh_instances(root):
		var rel_transform := _transform_relative_to(mi, root)
		var mesh_aabb: AABB = rel_transform * mi.get_aabb()
		if first:
			aabb = mesh_aabb
			first = false
		else:
			aabb = aabb.merge(mesh_aabb)
	return aabb
