extends Node3D
class_name RainbowAnalyzer

enum StereoEnum
{
	STEREO,
	SOLO_LEFT,
	SOLO_RIGHT
}

const MAX_HZ = 11050.0 # 10,000 Hz.
const MIN_DB = 60.0 # 60 dB SPL? How loud is 60 dB SPL? The lowest a person can detect so we'll make that our min volume.

const KNOB: PackedScene = preload("res://Worlds/Audioland/Jamming/HzKnob.tscn")

@export var analyzer_length: float = 12.0
@export var vu_count: int = 64 # Volume Units?
@export var knob_radius: float = 0.05
@export var stereo_enum: StereoEnum = StereoEnum.STEREO

var spectrum: AudioEffectSpectrumAnalyzerInstance
var knobs: Array


#------------------------------------------------------------------------------
# NOTES
# Humans can detect sounds in a frequency range from about 20 Hz to 20 kHz.
#------------------------------------------------------------------------------
# Hz RANGE:
# 	[20 Hz - 20,000 Hz]
#	BespokeSynth > synths: > signalgenerator > freq: range[1 - 4000]
#
# MIN RANGE:
#		print(db2linear(60))
#		print(linear_to_db(100))
#
# MAX RANGE:
#		print(db2linear(120))
#		print(linear_to_db(1000000.0))
#
#		Linear Range [100.0 to 1,000,000.0]
#		dB     Range [60.0  to 120.0]
#
#------------------------------------------------------------------------------

# Calculator log().
func Log(value: float):
	return log(value) / log(10)


# Calculator log().
func iLog(value: float):
	return exp(value)


func _ready():
#	for i in 100:
#		print("Log(%s): %s" % [i, Log(i)])
	
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(0.9))
	spectrum = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("Master"), 0)
	var delta_x: float = analyzer_length / float(vu_count)
	
	for i in vu_count:
		var knob = KNOB.instantiate()
		knob.position.x = delta_x * i
		knobs.append(knob)
		add_child(knob)


func _process(_delta):
	var prev_hz: float = 0.0
	
	# Loop through all the frequencies
	for i in range(1, vu_count + 1):
		var magnitude: float = 0.0
		var linear_hz = i * (MAX_HZ / vu_count)
		print(MAX_HZ / vu_count)
#		var hz = linear_hz
		var hz = exp(i) * MAX_HZ / exp(vu_count)
#		var hz = Log(linear_hz)
#		var hz = linear_to_db(linear_hz)
		
		#print("log(%s): %s" % [linear_hz, hz])
		#print(log(10))
		
		#var hz = db_to_linear(linear_hz)
		#var stereo_decibels: Vector2 = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0)
		var mag = 5
		match stereo_enum:
			StereoEnum.STEREO:
				magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0).length()
			StereoEnum.SOLO_LEFT:
				magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0).x
			StereoEnum.SOLO_RIGHT:
				magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0).y
		
		knobs[i - 1].SetMagnatude(((MIN_DB + linear_to_db(magnitude)) / MIN_DB) * mag, knob_radius)
		prev_hz = hz
