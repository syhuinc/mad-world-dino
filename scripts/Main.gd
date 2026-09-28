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
	light.light_energy = 1.1
	light.shadow_enabled = true
	add_child(light)

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.55, 0.78, 0.95)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.7, 0.75, 0.8)
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)

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
