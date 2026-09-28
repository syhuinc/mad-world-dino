extends Node3D

enum LaneType { GRASS, GRASS_DANGER, ROCK, DINO_RARE, RIVER }
enum DinoSpecies { PARA, GALLI, TRI, TREX, SPINO }

const TILE_SIZE := 2.0
const COLS := 9
const Decoration = preload("res://scripts/Decoration.gd")
const ModelUtil = preload("res://scripts/ModelUtil.gd")
const TILE_HEIGHT := 0.5
const TILE_MODELS := {
	LaneType.RIVER: "res://assets/tiles/water.glb",
	LaneType.GRASS: "res://assets/tiles/grass.glb",
	LaneType.GRASS_DANGER: "res://assets/tiles/grass.glb",
	LaneType.ROCK: "res://assets/tiles/stone.glb",
}
const DEFAULT_TILE_MODEL := "res://assets/tiles/dirt.glb"

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
		type = LaneType.GRASS if row % 2 == 1 else LaneType.GRASS_DANGER
	else:
		var cycle = (row - 1) % 4
		match cycle:
			0:
				var skip_rest_chance = clamp((row - 20) * 0.01, 0.0, 0.35)
				type = LaneType.GRASS_DANGER if randf() < skip_rest_chance else LaneType.GRASS
			2:
				type = LaneType.RIVER
			_:
				var rare_chance = clamp(0.05 + row * 0.004, 0.05, 0.28)
				if randf() < rare_chance:
					type = LaneType.DINO_RARE
				else:
					type = LaneType.ROCK if randi() % 2 == 0 else LaneType.GRASS_DANGER

	var nodes := []
	var ground := _make_ground(type)
	lane_root.add_child(ground)
	nodes.append(ground)

	match type:
		LaneType.GRASS_DANGER:
			nodes.append_array(_spawn_dino_common(lane_root, row, [DinoSpecies.PARA, DinoSpecies.GALLI], 2, 3))
			if randf() < 0.25:
				nodes.append(_spawn_coin(lane_root, randi_range(1, COLS - 2)))
		LaneType.ROCK:
			nodes.append_array(_spawn_dino_common(lane_root, row, [DinoSpecies.TRI], 1, 2))
			if randf() < 0.25:
				nodes.append(_spawn_coin(lane_root, randi_range(1, COLS - 2)))
		LaneType.DINO_RARE:
			nodes.append_array(_spawn_dino_rare(lane_root, row))
		LaneType.RIVER:
			nodes.append_array(_spawn_river(lane_root, row))
			if randf() < 0.25:
				nodes.append(_spawn_coin(lane_root, randi_range(1, COLS - 2)))
		LaneType.GRASS:
			if randf() < 0.5:
				nodes.append(_spawn_coin(lane_root, randi_range(1, COLS - 2)))

	_decorate_edges(lane_root, type)

	lanes[row] = {"type": type, "nodes": nodes, "root": lane_root}

func _decorate_edges(lane_root: Node3D, type: int) -> void:
	var half = COLS * TILE_SIZE * 0.5
	for side in [-1.0, 1.0]:
		if randf() >= 0.6:
			continue
		var deco := Decoration.new()
		var kind: int
		var y := 0.0
		if type == LaneType.RIVER:
			kind = Decoration.Kind.LILY_PAD if randf() < 0.5 else Decoration.Kind.REED
			y = 0.05
		else:
			var pool = [Decoration.Kind.ROCK, Decoration.Kind.BUSH, Decoration.Kind.PALM_TREE, Decoration.Kind.FLOWER]
			kind = pool[randi() % pool.size()]
		deco.setup(kind)
		var edge_margin = randf_range(0.6, 1.8)
		deco.position = Vector3(side * (half + edge_margin), y, randf_range(-0.6, 0.6))
		lane_root.add_child(deco)

func _make_ground(type: int) -> Node3D:
	var container := Node3D.new()
	var model_path: String = TILE_MODELS.get(type, DEFAULT_TILE_MODEL)

	if ResourceLoader.exists(model_path):
		var tile_size := Vector3(TILE_SIZE, TILE_HEIGHT, TILE_SIZE)
		for c in range(COLS):
			var tile := ModelUtil.load_fitted(model_path, tile_size)
			tile.position = Vector3(_col_to_x(c), -TILE_HEIGHT * 0.5, 0)
			container.add_child(tile)
		return container

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(COLS * TILE_SIZE, 0.2, TILE_SIZE)
	mesh.mesh = box
	mesh.position.y = -0.1
	var mat := StandardMaterial3D.new()
	match type:
		LaneType.RIVER:
			mat.albedo_color = Color(0.25, 0.55, 0.85)
		LaneType.GRASS, LaneType.GRASS_DANGER:
			mat.albedo_color = Color(0.45, 0.72, 0.35)
		LaneType.ROCK:
			mat.albedo_color = Color(0.55, 0.55, 0.58)
		_:
			mat.albedo_color = Color(0.62, 0.52, 0.38)
	mesh.material_override = mat
	container.add_child(mesh)
	return container

func _col_to_x(c: int) -> float:
	return (c - int(COLS / 2)) * TILE_SIZE

func _spawn_coin(parent: Node3D, col: int) -> Node3D:
	var coin = preload("res://scripts/Coin.gd").new()
	coin.position = Vector3(_col_to_x(col), 0.6, 0)
	parent.add_child(coin)
	return coin

func _species_data(species: int) -> Dictionary:
	# Sizes (length x width x height) are taken from the Mad World Meshy
	# reference spec sheets (reference/creatures/); length maps to the X
	# (movement) axis, width to Z (lane depth), height to Y.
	# model_path points at the real Meshy-generated glb; colors are only
	# used for the primitive fallback if that asset is ever missing.
	match species:
		DinoSpecies.PARA: # spec: 2.0 x 0.8 x 1.4
			return {"color": Color(0.85, 0.8, 0.15), "size": Vector3(2.0, 1.4, 0.8), "speed": 1.6, "model": "res://assets/creatures/parasaurolophus.glb"}
		DinoSpecies.GALLI: # spec: 1.8 x 0.6 x 1.6
			return {"color": Color(0.35, 0.7, 0.65), "size": Vector3(1.8, 1.6, 0.6), "speed": 2.8, "model": "res://assets/creatures/gallimimus.glb"}
		DinoSpecies.TRI: # spec: 2.4 x 1.2 x 1.4
			return {"color": Color(0.3, 0.45, 0.25), "size": Vector3(2.4, 1.4, 1.2), "speed": 1.1, "model": "res://assets/creatures/triceratops.glb"}
		DinoSpecies.TREX: # spec: 3.0 x 1.8 x 2.0, scaled 1.4x so it genuinely
			# dominates a lane per the "wait for the gap" design intent
			return {"color": Color(0.8, 0.12, 0.12), "size": Vector3(4.2, 2.8, 2.52), "speed": 1.3, "model": "res://assets/creatures/trex.glb"}
		DinoSpecies.SPINO: # spec: 3.2 x 1.6 x 1.8, scaled 1.4x (see T-Rex)
			return {"color": Color(0.1, 0.3, 0.75), "size": Vector3(4.48, 2.24, 2.52), "speed": 1.4, "model": "res://assets/creatures/spinosaurus.glb"}
	return {"color": Color.WHITE, "size": Vector3.ONE, "speed": 1.0, "model": ""}

func _spawn_dino(parent: Node3D, species: int, start_x: float, direction: float, speed_mult: float) -> Node3D:
	var data = _species_data(species)
	var color: Color = data["color"]
	color = color.lightened(randf_range(0.0, 0.12)) if randf() < 0.5 else color.darkened(randf_range(0.0, 0.12))
	var dino = preload("res://scripts/Obstacle.gd").new()
	dino.add_to_group("dino")
	var model_path: String = data.get("model", "")
	if model_path != "" and not ResourceLoader.exists(model_path):
		model_path = ""
	dino.setup(color, data["size"], data["speed"] * direction * speed_mult, COLS * TILE_SIZE, model_path, 90.0)
	dino.position = Vector3(start_x, data["size"].y * 0.5, 0)
	parent.add_child(dino)
	return dino

func _spawn_dino_common(parent: Node3D, row: int, species_pool: Array, min_count: int, max_count: int) -> Array:
	var result := []
	var direction = 1.0 if randi() % 2 == 0 else -1.0
	var speed_mult = clamp(1.0 + row * 0.01, 1.0, 1.8)
	var count = randi_range(min_count, max_count)
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

	var use_logs = randf() < 0.3
	var platform_model: String
	var platform_size: Vector3
	var fallback_color: Color
	if use_logs:
		platform_model = "res://assets/tiles/log.glb"
		platform_size = Vector3(2.4, 0.5, 1.1)
		fallback_color = Color(0.45, 0.3, 0.15)
	else:
		# Crocodile size (length x width x height) from the Meshy reference spec.
		platform_model = "res://assets/creatures/crocodile.glb"
		platform_size = Vector3(2.6, 0.6, 1.0)
		fallback_color = Color(0.25, 0.45, 0.25)

	var platform_len = platform_size.x
	var gap = TILE_SIZE * 1.3
	var spacing = platform_len + gap
	var count = int((COLS * TILE_SIZE * 2) / spacing)
	var offset = randf_range(0, spacing)
	for i in range(count):
		var start_x = -half - offset + i * spacing
		var croc = preload("res://scripts/Croc.gd").new()
		croc.add_to_group("croc")
		croc.setup(direction * speed, platform_size, COLS * TILE_SIZE * 2.0, platform_model, fallback_color)
		croc.position = Vector3(start_x, 0.15, 0)
		parent.add_child(croc)
		result.append(croc)
	return result
