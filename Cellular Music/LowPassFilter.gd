extends Reference

var cutoff_freq = 2000.0
var sample_rate = 22050

var output = 0.0
var alpha = 0.0

func _init():
	update_alpha()

func update_alpha():
	var dt = 1.0 / sample_rate
	var rc = 1.0 / (2.0 * PI * cutoff_freq)
	alpha = dt / (rc + dt)

func process_sample(input: float) -> float:
	output = (1.0 - alpha) * output + alpha * input
	return output

func set_cutoff_freq(freq: float):
	cutoff_freq = freq
	update_alpha()

