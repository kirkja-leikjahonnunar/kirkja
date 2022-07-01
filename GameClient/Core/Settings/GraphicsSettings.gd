extends Control

var graphics_settings = {
	"render_size": "1920x1080",
	"fullscreen" : false,
	"quality": "Medium"
}

var quality_keys := [ "Low", "Medium", "High", "Ultra" ] # these should correspond to the items in QualitySelector

# see size/aspect discussion: https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
var screen_sizes := [ "1280 x 720", "1920 x 1080", "2550 x 1440", "1920 x 1200" ]

var quality_popup : PopupMenu
var size_popup : PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	quality_popup = $VBoxContainer/Quality/QualitySelector.get_popup()
	quality_popup.index_pressed.connect(_on_quality_selected)
	
	size_popup = $VBoxContainer/Quality/QualitySelector.get_popup()
	size_popup.index_pressed.connect(_on_size_selected)


func SettingsChanged():
	print ("IMPLEMENT save settings")


func _on_quality_selected(index):
	print ("QualitySelector index: ", index)
	$VBoxContainer/Quality/QualitySelector.text = quality_popup.get_item_text(index)
	graphics_settings["quality"] = quality_keys[index]
	SettingsChanged()


func _on_size_selected(index):
	print ("Render size index: ", index)
	$VBoxContainer/Quality/QualitySelector.text = size_popup.get_item_text(index)
	graphics_settings["render_size"] = screen_sizes[index]
	SettingsChanged()


func _on_fullscreen_toggled(button_pressed):
	graphics_settings["fullscreen"] = button_pressed
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SettingsChanged()


