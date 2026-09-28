extends Node3D

enum LaneType { GRASS, DINO_COMMON, DINO_RARE, RIVER }
enum DinoSpecies { PARA, GALLI, TRI, TREX, SPINO }

const TILE_SIZE := 2.0
const COLS := 9

var player: Node3D
var lanes: Dictionary = {}
var max_generated_row: int = -1

func _ready() -> void:
	for i in range(0, 14):
		ensure_row(i)

func reset() -> void:
	for row_key in lanes.keys():
		_clear_lane(row_key)
	lanes.clear()
	max_generated_row = -1
	for i in range(0, 14):
		ensure_row(i)

func _clear_lane(row_key: int) -> void:
	var lane = lanes[row_key]
	for node in lane.get("nodes", []):
		if is_instance_valid(node):
			node.queue_free()
	if is_instance_valid(lane.get("root")):
		lane["root"].queue_free()

func ensure_row(target_row: int) -> void:
	while max_generated_row < target_row:
		max_generated_row += 1
		_generate_row(max_generated_row)
	if player:
		var cutoff = player.row - 6
		var to_remove := []
		for k in lanes.keys():
			if k < cutoff:
				to_remove.append(k)
		for k in to_remove:
			_clear_lane(k)
			lanes.erase(k)

func get_lane_type(row: int) -> int:
	if lanes.has(row):
		return lanes[row]["type"]
	return LaneType.GRASS

func on_player_row_changed(row: int) -> void:
	var meters = int(row * TILE_SIZE)
	GameManager.update_distance(meters)

func _generate_row(row: int) -> void:
	var lane_root := Node3D.new()
	lane_root.position = Vector3(0, 0, -row * TILE_SIZE)
	add_child(lane_root)

	var type := LaneType.GRASS
	if row == 0:
		type = LaneType.GRASS
	elif row <= 3:
		type = LaneType.GRASS if row % 2 == 1 else LaneType.DINO_COMMON
	else:
		var cycle = (row - 1) % 4
		match cycle:
			0:
				type = LaneType.GRASS
			2:
				type = LaneType.RIVER
			_:
				var rare_chance = clamp(0.05 + row * 0.004, 0.05, 0.28)
				type = LaneType.DINO_RARE if randf() < rare_chance else LaneType.DINO_COMMON

	var nodes := []
	var ground := _make_ground(type)
	lane_root.add_child(ground)
	nodes.append(ground)

	match type:
		LaneType.DINO_COMMON:
			nodes.append_array(_spawn_dino_common(lane_root, row))
		LaneType.DINO_RARE:
			nodes.append_array(_spawn_dino_rare(lane_root, row))
		LaneType.RIVER:
			nodes.append_array(_spawn_river(lane_root, row))
		LaneType.GRASS:
			if randf() < 0.5:
				nodes.append(_spawn_coin(lane_root, randi_range(1, COLS - 2)))

	lanes[row] = {"type": type, "nodes": nodes, "root": lane_root}

func _make_ground(type: int) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(COLS * TILE_SIZE, 0.2, TILE_SIZE)
	mesh.mesh = box
	mesh.position.y = -0.1
	var mat := StandardMaterial3D.new()
	match type:
		LaneType.RIVER:
			mat.albedo_color = Color(0.25, 0.55, 0.85)
		LaneType.GRASS:
			mat.albedo_color = Color(0.45, 0.72, 0.35)
		_:
			mat.albedo_color = Color(0.62, 0.52, 0.38)
	mesh.material_override = mat
	return mesh

func _col_to_x(c: int) -> float:
	return (c - int(COLS / 2)) * TILE_SIZE

func _spawn_coin(parent: Node3D, col: int) -> Node3D:
	var coin = preload("res://scripts/Coin.gd").new()
	coin.position = Vector3(_col_to_x(col), 0.6, 0)
	parent.add_child(coin)
	return coin

func _species_data(species: int) -> Dictionary:
	match species:
		DinoSpecies.PARA:
			return {"color": Color(0.75, 0.65, 0.3), "size": Vector3(1.0, 0.9, 1.8), "speed": 1.6}
		DinoSpecies.GALLI:
			return {"color": Color(0.6, 0.55, 0.4), "size": Vector3(0.7, 0.8, 1.5), "speed": 2.8}
		DinoSpecies.TRI:
			return {"color": Color(0.55, 0.6, 0.45), "size": Vector3(1.8, 1.1, 2.4), "speed": 1.1}
		DinoSpecies.TREX:
			return {"color": Color(0.65, 0.25, 0.2), "size": Vector3(4.4, 2.4, 3.6), "speed": 1.3}
		DinoSpecies.SPINO:
			return {"color": Color(0.25, 0.4, 0.55), "size": Vector3(4.6, 2.1, 4.2), "speed": 1.4}
	return {"color": Color.WHITE, "size": Vector3.ONE, "speed": 1.0}

func _spawn_dino(parent: Node3D, species: int, start_x: float, direction: float, speed_mult: float) -> Node3D:
	var data = _species_data(species)
	var color: Color = data["color"]
	color = color.lightened(randf_range(0.0, 0.12)) if randf() < 0.5 else color.darkened(randf_range(0.0, 0.12))
	var dino = preload("res://scripts/Obstacle.gd").new()
	dino.add_to_group("dino")
	dino.setup(color, data["size"], data["speed"] * direction * speed_mult, COLS * TILE_SIZE)
	dino.position = Vector3(start_x, data["size"].y * 0.5, 0)
	parent.add_child(dino)
	return dino

func _spawn_dino_common(parent: Node3D, row: int) -> Array:
	var result := []
	var direction = 1.0 if randi() % 2 == 0 else -1.0
	var speed_mult = clamp(1.0 + row * 0.01, 1.0, 1.8)
	var species_pool = [DinoSpecies.PARA, DinoSpecies.GALLI, DinoSpecies.TRI]
	var count = randi_range(2, 3)
	var half = COLS * TILE_SIZE * 0.5
	var slot = (half * 2.0) / count
	for i in range(count):
		var species = species_pool[randi() % species_pool.size()]
		var jitter = randf_range(slot * 0.15, slot * 0.85)
		var start_x = -half + i * slot + jitter
		result.append(_spawn_dino(parent, species, start_x, direction, speed_mult))
	return result

func _spawn_dino_rare(parent: Node3D, row: int) -> Array:
	var species = DinoSpecies.TREX if randi() % 2 == 0 else DinoSpecies.SPINO
	var direction = 1.0 if randi() % 2 == 0 else -1.0
	var speed_mult = clamp(1.0 + row * 0.006, 1.0, 1.4)
	var half = COLS * TILE_SIZE * 0.5
	var start_x = randf_range(-half, half)
	return [_spawn_dino(parent, species, start_x, direction, speed_mult)]

func _spawn_river(parent: Node3D, row: int) -> Array:
	var result := []
	var direction = 1.0 if randi() % 2 == 0 else -1.0
	var speed = randf_range(1.0, 1.8)
	var half = COLS * TILE_SIZE * 0.5
	var croc_len = TILE_SIZE * 1.4
	var gap = TILE_SIZE * 1.3
	var spacing = croc_len + gap
	var count = int((COLS * TILE_SIZE * 2) / spacing)
	var offset = randf_range(0, spacing)
	for i in range(count):
		var start_x = -half - offset + i * spacing
		var croc = preload("res://scripts/Croc.gd").new()
		croc.add_to_group("croc")
		croc.setup(direction * speed, croc_len, COLS * TILE_SIZE * 2.0)
		croc.position = Vector3(start_x, 0.15, 0)
		parent.add_child(croc)
		result.append(croc)
	return result
