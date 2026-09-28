extends Node

signal coins_changed(total: int)
signal distance_changed(meters: int)
signal game_over(final_distance: int, coins_run: int)
signal state_changed(new_state: int)
signal muted_changed(is_muted: bool)

enum State { TITLE, PLAYING, PAUSED, GAME_OVER }

const SAVE_PATH := "user://savegame.json"

var state: int = State.TITLE
var total_coins: int = 0
var best_distance: int = 0
var muted: bool = false

var run_coins: int = 0
var run_distance: int = 0

func _ready() -> void:
	_load()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)

func set_muted(m: bool) -> void:
	muted = m
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
	muted_changed.emit(muted)
	_save()

func start_run() -> void:
	run_coins = 0
	run_distance = 0
	state = State.PLAYING
	state_changed.emit(state)

func set_paused(paused: bool) -> void:
	if state == State.PLAYING and paused:
		state = State.PAUSED
		state_changed.emit(state)
		get_tree().paused = true
	elif state == State.PAUSED and not paused:
		state = State.PLAYING
		state_changed.emit(state)
		get_tree().paused = false

func add_coin() -> void:
	run_coins += 1
	total_coins += 1
	coins_changed.emit(total_coins)
	_save()

func update_distance(meters: int) -> void:
	if meters > run_distance:
		run_distance = meters
		distance_changed.emit(run_distance)

func end_run() -> void:
	if run_distance > best_distance:
		best_distance = run_distance
	state = State.GAME_OVER
	state_changed.emit(state)
	get_tree().paused = false
	_save()
	game_over.emit(run_distance, run_coins)

func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"total_coins": total_coins, "best_distance": best_distance, "muted": muted}))
		f.close()

func _load() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			var data = JSON.parse_string(f.get_as_text())
			f.close()
			if typeof(data) == TYPE_DICTIONARY:
				total_coins = data.get("total_coins", 0)
				best_distance = data.get("best_distance", 0)
				muted = data.get("muted", false)
