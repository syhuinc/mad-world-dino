extends Node3D

var player: Node3D
var lane_manager: Node3D
var hud: CanvasLayer
var camera_rig: Camera3D

func _ready() -> void:
	_setup_world()
	_setup_player()
	_setup_lane_manager()
	_setup_camera()
	_setup_hud()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		match GameManager.state:
			GameManager.State.PLAYING:
				GameManager.set_paused(true)
			GameManager.State.PAUSED:
				GameManager.set_paused(false)
			_:
				get_tree().quit()

func _setup_world() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.light_color = Color(1.0, 0.97, 0.9)
	light.light_energy = 1.15
	light.shadow_enabled = true
	add_child(light)

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.3, 0.58, 0.88)
	sky_mat.sky_horizon_color = Color(0.75, 0.85, 0.85)
	sky_mat.ground_bottom_color = Color(0.45, 0.72, 0.35)
	sky_mat.ground_horizon_color = Color(0.75, 0.85, 0.85)
	sky_mat.sun_angle_max = 30.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.35
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.15
	e.adjustment_contrast = 1.05
	env.environment = e
	add_child(env)

	# Permanent backdrop so the camera never sees empty background where no
	# lane has been generated yet (e.g. behind row 0 at the start of a run).
	# Kept well below any lane geometry (including the uneven undersides of
	# real 3D tile models) so it never competes with or shows through real
	# ground — it should only ever be visible where no lane exists at all.
	var backdrop := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(200.0, 0.1, 800.0)
	backdrop.mesh = box
	backdrop.position = Vector3(0, -3.0, -380.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.72, 0.35)
	backdrop.material_override = mat
	backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(backdrop)

func _setup_player() -> void:
	player = preload("res://scripts/Player.gd").new()
	player.name = "Player"
	add_child(player)

func _setup_lane_manager() -> void:
	lane_manager = preload("res://scripts/LaneManager.gd").new()
	lane_manager.name = "LaneManager"
	lane_manager.player = player
	player.lane_manager = lane_manager
	add_child(lane_manager)

func _setup_camera() -> void:
	camera_rig = preload("res://scripts/CameraRig.gd").new()
	camera_rig.name = "CameraRig"
	camera_rig.player = player
	add_child(camera_rig)
	camera_rig.snap()

func _setup_hud() -> void:
	hud = preload("res://scripts/HUD.gd").new()
	hud.name = "HUD"
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud)
	hud.main = self

func begin_new_run() -> void:
	lane_manager.reset()
	player.reset()
	camera_rig.snap()
	GameManager.start_run()
