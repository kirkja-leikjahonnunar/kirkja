extends Control

var graphics_settings = {
	"render_size": "1920x1080",
	"fullscreen" : false,
	"quality": "Medium"
}

var quality_keys := [ "Low", "Medium", "High", "Ultra" ] # these should correspond to the items in QualitySelector


var popup : PopupMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	popup = $VBoxContainer/Quality/QualitySelector.get_popup()
	popup.index_pressed.connect(_on_index_pressed)


func _on_index_pressed(index):
	print ("QualitySelector index: ", index)
	$VBoxContainer/Quality/QualitySelector.text = popup.get_item_text(index)
	graphics_settings["quality"] = quality_keys[index]


func _on_check_box_toggled(button_pressed):
	graphics_settings["fullscreen"] = button_pressed
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


