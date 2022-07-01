extends Control


var audio_settings := {
	"volume": 75,
	"voice": 100,
	"effects": 100,
	"music": 100
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_volume_value_changed(value):
	print ("volume cahnge: ", value)
	audio_settings["volume"] = value


func _on_voice_volume_value_changed(value):
	audio_settings["voice"] = value


func _on_effects_volume_value_changed(value):
	audio_settings["effects"] = value


func _on_music_volume_value_changed(value):
	audio_settings["music"] = value
