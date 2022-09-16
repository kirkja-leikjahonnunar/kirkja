extends Node

const VU_COUNT = 64 # Volume Units?
const FREQ_MAX = 11050.0 / 4.0 # hz? That seems like a lot?
const MIN_DB = 60 # How loud is 60 dB SPF? The lowest a person can detect so we'll make that our 0.0 volume.


@onready var KNOB : PackedScene = preload("res://Worlds/Devland/Jamming/HzKnob.tscn")
@onready var music : AudioStreamPlayer = $Music


@export_range(0.0, 1.0)
var master_volume : float = 1.0:
	set(value):
		master_volume = value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))


var spectrum : AudioEffectSpectrumAnalyzerInstance
var knobs : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.2))
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	var delta_x : float = 16.0 / float(VU_COUNT)
	
	for i in VU_COUNT:
		var knob = KNOB.instantiate()
		knob.position.x = delta_x * i
		knobs.append(knob)
		add_child(knob)


func _process(_delta):
	var prev_hz = 0
	
	for i in range(1, VU_COUNT + 1):
		var hz = i * FREQ_MAX / VU_COUNT
		var magnitude : float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0).length() # MagnitudeMode. 
#		var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
#		var height = energy * HEIGHT
		
		#draw_rect(Rect2(w * i, HEIGHT - height, w, height), Color.white)
		
		#knobs[i - 1].position.y = magnitude * 1000
#		knobs[i - 1].magnitude = 1.0 # magnitude * 1000 # log(magnitude * 1000)
#		knobs[i - 1].SetMagnatude(db2linear(magnitude * 1000))
		knobs[i - 1].SetMagnatude(((MIN_DB + linear_to_db(magnitude)) / MIN_DB) * 10)
		prev_hz = hz
		
#		print(db2linear(magnitude))
#		print(db2linear(magnitude * 1000))
		
# MIN RANGE:
#		print(db2linear(60))
#		print(db2linear(100))

# MAX RANGE:
#		print(db2linear(120))
#		print(linear2db(1000000.0)) # 

#		Linear Range [100.0 to 1,000,000.0]
#		dB     Range [60.0  to 120.0]

