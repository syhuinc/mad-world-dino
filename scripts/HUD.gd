extends CanvasLayer

var main: Node3D

var title_layer: Control
var hud_layer: Control
var pause_layer: Control
var game_over_layer: Control

var coin_label: Label
var distance_label: Label
var final_distance_label: Label
var final_coins_label: Label
var best_label: Label

func _ready() -> void:
	layer = 10
	_build_title()
	_build_hud()
	_build_pause()
	_build_game_over()

	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.distance_changed.connect(_on_distance_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.state_changed.connect(_on_state_changed)

	coin_label.text = str(GameManager.total_coins)
	_on_state_changed(GameManager.state)

func _full_rect_control() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

func _build_title() -> void:
	title_layer = _full_rect_control()
	title_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(title_layer)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.35)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_layer.add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	title_layer.add_child(vbox)

	var title := Label.new()
	title.text = "MAD WORLD"
	title.add_theme_font_size_override("font_size", 56)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "WORLD 01 - DINO"
	sub.add_theme_font_size_override("font_size", 24)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)

	var play_btn := Button.new()
	play_btn.text = "PLAY"
	play_btn.custom_minimum_size = Vector2(180, 60)
	play_btn.add_theme_font_size_override("font_size", 28)
	play_btn.pressed.connect(_on_play_pressed)
	vbox.add_child(play_btn)

func _build_hud() -> void:
	hud_layer = _full_rect_control()
	add_child(hud_layer)

	var coin_box := HBoxContainer.new()
	coin_box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	coin_box.position = Vector2(20, 20)
	hud_layer.add_child(coin_box)

	var coin_icon := Label.new()
	coin_icon.text = "*"
	coin_icon.add_theme_font_size_override("font_size", 26)
	coin_icon.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	coin_box.add_child(coin_icon)

	coin_label = Label.new()
	coin_label.text = "0"
	coin_label.add_theme_font_size_override("font_size", 26)
	coin_box.add_child(coin_label)

	distance_label = Label.new()
	distance_label.text = "0m"
	distance_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	distance_label.position = Vector2(-120, 20)
	distance_label.add_theme_font_size_override("font_size", 26)
	hud_layer.add_child(distance_label)

	var pause_btn := Button.new()
	pause_btn.text = "||"
	pause_btn.custom_minimum_size = Vector2(50, 50)
	pause_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_btn.position = Vector2(-70, 70)
	pause_btn.pressed.connect(func(): GameManager.set_paused(true))
	hud_layer.add_child(pause_btn)

func _build_pause() -> void:
	pause_layer = _full_rect_control()
	pause_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_layer)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_layer.add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	pause_layer.add_child(vbox)

	var label := Label.new()
	label.text = "PAUSED"
	label.add_theme_font_size_override("font_size", 40)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	var resume_btn := Button.new()
	resume_btn.text = "RESUME"
	resume_btn.custom_minimum_size = Vector2(180, 55)
	resume_btn.pressed.connect(func(): GameManager.set_paused(false))
	vbox.add_child(resume_btn)

func _build_game_over() -> void:
	game_over_layer = _full_rect_control()
	game_over_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(game_over_layer)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_layer.add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	game_over_layer.add_child(vbox)

	var title := Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_size_override("font_size", 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	final_distance_label = Label.new()
	final_distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(final_distance_label)

	final_coins_label = Label.new()
	final_coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(final_coins_label)

	best_label = Label.new()
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(best_label)

	var retry_btn := Button.new()
	retry_btn.text = "RETRY"
	retry_btn.custom_minimum_size = Vector2(180, 55)
	retry_btn.pressed.connect(_on_play_pressed)
	vbox.add_child(retry_btn)

func _on_play_pressed() -> void:
	main.begin_new_run()

func _on_coins_changed(total: int) -> void:
	coin_label.text = str(total)

func _on_distance_changed(meters: int) -> void:
	distance_label.text = "%dm" % meters

func _on_game_over(final_distance: int, coins_run: int) -> void:
	final_distance_label.text = "Distance: %dm" % final_distance
	final_coins_label.text = "Coins: %d" % coins_run
	best_label.text = "Best: %dm" % GameManager.best_distance

func _on_state_changed(state: int) -> void:
	title_layer.visible = state == GameManager.State.TITLE
	hud_layer.visible = state == GameManager.State.PLAYING or state == GameManager.State.PAUSED
	pause_layer.visible = state == GameManager.State.PAUSED
	game_over_layer.visible = state == GameManager.State.GAME_OVER
