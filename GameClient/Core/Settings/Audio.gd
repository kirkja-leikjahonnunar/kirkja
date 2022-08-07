extends Control


var audio_settings := {
	"volume": 75,
	"voice": 100,
	"effects": 100,
	"music": 100
}


enum Boop { main, voice, effects, music }
var current_boop = Boop.main

var boop_timeout := 0.3
var last_boop_time := 0.0
var last_boop_value := 0.0
var last_value := 0.0


func GetSettingsDictionary():
	return audio_settings


# Make sure boop timers act on the proper bus.
func SetBoop(which):
	if which == current_boop: return
	
	var value
	match which:
		Boop.main:
			value = audio_settings["volume"]
			$AudioStreamPlayer2D.bus = "Master"
		Boop.voice:
			value = audio_settings["voice"]
			$AudioStreamPlayer2D.bus = "Voice"
		Boop.effects:
			value = audio_settings["effects"]
			$AudioStreamPlayer2D.bus = "Effects"
		Boop.music:
			value = audio_settings["music"]
			$AudioStreamPlayer2D.bus = "Music"
	last_boop_value = value
	last_value = value
	last_boop_time = 0.0
	current_boop = which


# Can be called anytime to set the volume on particular buses.
func SetVolume(which_bus, value):
	match which_bus:
		Boop.main:    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -35 + value/100.0*35.0)
		Boop.voice:   AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"),  -35 + value/100.0*35.0)
		Boop.effects: AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"),-35 + value/100.0*35.0)
		Boop.music:   AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),  -35 + value/100.0*35.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	last_boop_value = audio_settings["volume"]
	
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if last_boop_time > 0: # we do this in lieu of detecting mouse up (which would probably be better TODO)
		last_boop_time -= delta
		if last_boop_time <= 0 && not $AudioStreamPlayer2D.playing:
			$AudioStreamPlayer2D.play()
			last_boop_value = last_value
			set_process(false)


#--------------------- Signal Functions -----------------------------

func UpdateBoop(value):
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -35 + value/100.0*35.0)
	SetVolume(current_boop, value)
	
	#print ("volume change: ", value)
	
	# boop if we drag far enough
	if value != last_value:
		if value == 0 || value == 100 || abs(last_boop_value - value) >= 10:
			$AudioStreamPlayer2D.play()
			last_boop_value = value
			last_boop_time = 0.0
			last_value = value
			return
	
	# start boop timeout
	last_boop_time = boop_timeout
	last_value = value
	set_process(true)


func _on_volume_value_changed(value):
	audio_settings["volume"] = value
	SetBoop(Boop.main)
	UpdateBoop(value)


func _on_voice_volume_value_changed(value):
	audio_settings["voice"] = value
	SetBoop(Boop.voice)
	UpdateBoop(value)


func _on_effects_volume_value_changed(value):
	audio_settings["effects"] = value
	SetBoop(Boop.effects)
	UpdateBoop(value)


func _on_music_volume_value_changed(value):
	audio_settings["music"] = value
	SetBoop(Boop.music)
	UpdateBoop(value)
