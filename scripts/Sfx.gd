extends Node

var _streams: Dictionary = {}

func _ready() -> void:
	_streams["hop"] = _make_tone(420.0, 420.0, 0.06, 0.25, 0.0)
	_streams["coin"] = _make_tone(700.0, 1100.0, 0.12, 0.35, 0.02)
	_streams["death"] = _make_tone(260.0, 70.0, 0.35, 0.4, 0.0)

func play(sound_name: String) -> void:
	if not _streams.has(sound_name):
		return
	var player := AudioStreamPlayer.new()
	player.stream = _streams[sound_name]
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _make_tone(freq_start: float, freq_end: float, duration: float, volume: float, attack: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var sample_count := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase := 0.0
	for i in range(sample_count):
		var t := float(i) / sample_rate
		var freq: float = lerp(freq_start, freq_end, float(i) / float(max(sample_count - 1, 1)))
		phase += freq / sample_rate
		var envelope := 1.0
		if attack > 0.0 and t < attack:
			envelope = t / attack
		else:
			var decay_t = t - attack
			var decay_len = max(duration - attack, 0.001)
			envelope = pow(1.0 - clamp(decay_t / decay_len, 0.0, 1.0), 1.5)
		var sample := sin(phase * TAU) * volume * envelope
		var sample_i16 := int(clamp(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample_i16)

	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	return stream
