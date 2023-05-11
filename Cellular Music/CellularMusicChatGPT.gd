extends AudioStreamPlayer

var sample_rate = 44100
var channels = 2
var buffer_size = 4096

var array = PoolIntArray()

func _ready():
	init_array(array)
	set_stream(AudioStreamGenerator.new())
	set_process(true)

func _process(delta):
	var generator = get_stream() as AudioStreamGenerator
	var buffer = generator.get_buffer(buffer_size)
	mix(buffer)
	generator.set_buffer(buffer)
	generator.set_format(AudioStream.FORMAT_S16_LE)
	generator.set_channel_count(channels)
	generator.set_sample_rate(sample_rate)
	generator.play()

func generate_automaton(rule: int, initial_state: Array, iterations: int) -> PoolIntArray:
	var state = initial_state.duplicate()
	var next_state := []
	for i in state:
		next_state.append(0)
	for i in range(iterations):
		for j in range(state.size()):
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

func init_array(array):
	array.append(1)
	for i in range(1, 63):
		array.append(0)
	array.append(1)

func mix(buffer):
	var generator = get_stream() as AudioStreamGenerator
	var automaton = generate_automaton(30, array, buffer.get_buffer_size() / channels / 2)
	var scale = [
		0, 1, 2, 3, 4, 5, 6, 7,
		8, 9, 10, 11, 12, 13, 14, 15,
		16, 17, 18, 19, 20, 21, 22, 23,
		24, 25, 26, 27, 28, 29, 30, 31,
		32, 33, 34, 35, 36, 37, 38, 39,
		40, 41, 42, 43, 44, 45, 46, 47,
		48, 49, 50, 51, 52, 53, 54, 55,
		56, 57, 58, 59, 60, 61, 62, 63
	]
	var notes = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71]
	var index = 0
	for i in range(buffer.get_buffer_size() / channels / 2):
		var note = notes[scale[automaton[i]]]
		var freq = pow(2, (note - 69) / 12) * 440
		var sample = sin(i * 2 * PI / sample_rate * freq)
		buffer.set_float(index, 0, sample)
		buffer.set_float(index, 1, sample)
		index += channels

