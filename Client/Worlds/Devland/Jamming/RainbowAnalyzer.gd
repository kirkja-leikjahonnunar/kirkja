extends Node3D
class_name RainbowAnalyzer

enum StereoEnum
{
	STEREO,
	SOLO_LEFT,
	SOLO_RIGHT
}

#const VU_COUNT = 64 # Volume Units?
const FREQ_MAX = 1000 # Hz BespokeSynth > synths: > signalgenerator > freq: range[1 - 4000] hz? # 11050.0 # hz? That seems like a lot?
const MIN_DB = 60 # 60 dB SPL? How loud is 60 dB SPL? The lowest a person can detect so we'll make that our 0.0 volume.

@onready var KNOB : PackedScene = preload("res://Worlds/Devland/Jamming/HzKnob.tscn")

@export var analyzer_length : float = 12.0
@export var vu_count : int = 64
@export var knob_radius : float = 0.05
@export var stereo_enum : StereoEnum = StereoEnum.STEREO

var spectrum : AudioEffectSpectrumAnalyzerInstance
var knobs : Array


func _ready():
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(0.9))
	spectrum = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("Master"), 0)
	var delta_x : float = analyzer_length / float(vu_count)
	
	for i in vu_count:
		var knob : Node3D = KNOB.instantiate()
		knob.position.x = delta_x * i
		knobs.append(knob)
		add_child(knob)


func _process(_delta):
	var prev_hz : float = 0.0
	
	for i in range(1, vu_count + 1):
		var magnitude : float = 0.0
		var hz = i * FREQ_MAX / vu_count
		var stereo_decibels : Vector2 = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0)
		
		match stereo_enum:
			StereoEnum.STEREO:
				magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0).length()
			StereoEnum.SOLO_LEFT:
				magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0).x
			StereoEnum.SOLO_RIGHT:
				magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0).y
			
#		var magnitude : float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0).length() # MagnitudeMode.
		
		knobs[i - 1].SetMagnatude(((MIN_DB + linear_to_db(magnitude)) / MIN_DB) * 10, knob_radius)
		prev_hz = hz


#------------------------------------------------------------------------------
# Notes
#------------------------------------------------------------------------------
# MIN RANGE:
#		print(db2linear(60))
#		print(db2linear(100))

# MAX RANGE:
#		print(db2linear(120))
#		print(linear2db(1000000.0)) # 

#		Linear Range [100.0 to 1,000,000.0]
#		dB     Range [60.0  to 120.0]

# Hz RANGE:
# [20 Hz - 20,000 Hz]
