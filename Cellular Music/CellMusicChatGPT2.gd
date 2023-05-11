extends AudioStreamPlayer

var automaton = []
var scale = []
var notes = []
var buffer_size = 1024
var sample_rate = 44100

func generate_automaton(rule: int, initial_state: Array, iterations: int) -> Array:
	var state = initial_state.duplicate()
	var next_state := []
	for i in state:
		next_state.append(0)
	for i in range(iterations):
		for j in range(state.size()-1):
			var left
			if j == 0:
				left = state[state.size() - 1]
			else:
				left = state[j - 1]
			var center = state[j]
			var right
			if j == state.size() - 1:
				right = state[0]
			else:
				right = state[j + 1]
			var pattern = left * 4 + center * 2 + right
			next_state[j] = (rule >> pattern) & 1
		state = next_state.duplicate()
	return state

func mix_audio(buffer, frames: int) -> void:
	for i in range(frames):
		var note = notes[scale[automaton[i]]]
		var freq = pow(2, (note - 69) / 12) * 440
		var sample = sin(i * 2 * PI / sample_rate * freq)
		buffer.set_frame(i, 0, sample)
		buffer.set_frame(i, 1, sample)

func _ready():
	var array = []
	array.resize(64)
	array[0] = 1
	array[63] = 1
	automaton = generate_automaton(30, array, buffer_size)
	scale = [0, 2, 3, 5, 7, 8, 10]
	notes = []
	for i in range(12):
		for j in scale:
			notes.append(60 + i * 12 + j)
	var audio_stream = AudioStreamGenerator.new()
	audio_stream.set_process_callback(self, "mix_audio")
	audio_stream.set_format(AudioStream.FORMAT_S16_LE)
	audio_stream.set_channel_count(2)
	audio_stream.set_sample_rate(sample_rate)
	set_stream(audio_stream)
	play()

#: AudioStreamBuffer
