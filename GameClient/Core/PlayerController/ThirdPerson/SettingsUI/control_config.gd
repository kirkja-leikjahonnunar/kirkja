@tool
class_name ControlConfig
extends Control

#TODO: settings UI
# - for joypad, need to record device number, see Input.get_connected_joypads()
# - try out InputEventMidi
# - keys to change focus, but can go offscreen when out of visible scroll area
# - if you click outside while prompt up, should cancel, not use mouse for it
# - press any key should be a different color
# - restore defaults option.. all at once? per item?
# - option to clear binding
# - don't clobber existing bind to other action
# - save to file on change of binding
# - UI should be updatable by a language flag somehow
# - key bindings should have saveable sets to/from file (done), maybe settings file is an array of settings?
# - need better styling, probably a "Settings" header (done) too
#
# - DONE joypad or keys should be able to navigate full menu, and not have "Press any key" snafu
# - DONE mouse down issue, also arrow keys move focus.. all input should be blocked until input
# - DONE keycode is 0?  <-  needed to use physical_keycode and button_index, not keycode and button_mask!
# - DONE use physical key, but display user keys?
#
# see:
#   OS.get_keycode_string
#   DisplayServer.keyboard_get_keycode_from_physical

signal setting_changed(action, value)


@export var grab_settings := false:
	get:
		return false
	set(value):
		if value == true:
			if Engine.is_editor_hint():
				SetBindingsFromCurrentEditor()
				SaveSettings(settings_file)



@export var display_physical := true


# these should be translatable, or do some UI gimmick to indicate nothing
var unassigned := "Unassigned"
var PressAnyKey := "Press any key"

# THESE NEED TO BE THE SAME AS IN KeyBindButton, otherwise mysterious errors about cyclic something or other
enum DeviceType { NONE = 0, KEY = 1, MOUSE = 2, PAD = 3 }


var properties := {
	"fov": 75.0,
	"aim_fov": 50.0,
	"mouse_sensitivity": 1.0,
	"invert_x": false,
	"invert_y": false,
}

# These must match your the InputMap actions:
var actions := {
		# index is physical key code, or mouse button number, or joypad button
		#"action": { "label": "Human Readable", "device": dev_type, "index": index } 
		"char_forward":      { "label": "Forward"     , "device": 0, "index": -1 },
		"char_backward":     { "label": "Backward"    , "device": 0, "index": -1 },
		"char_strafe_left":  { "label": "Left"        , "device": 0, "index": -1 },
		"char_strafe_right": { "label": "Right"       , "device": 0, "index": -1 },
		"char_rotate_left":  { "label": "Rotate Left" , "device": 0, "index": -1 },
		"char_rotate_right": { "label": "Rotate Right", "device": 0, "index": -1 },
		"char_rotate_up":    { "label": "Rotate Up"   , "device": 0, "index": -1 },
		"char_rotate_down":  { "label": "Rotate Down" , "device": 0, "index": -1 },
		"char_fly_up":       { "label": "Up"          , "device": 0, "index": -1 },
		"char_fly_down":     { "label": "Down"        , "device": 0, "index": -1 },
		"char_jump":         { "label": "Jump"        , "device": 0, "index": -1 },
		"char_sprint":       { "label": "Sprint"      , "device": 0, "index": -1 },
		"char_toggle_mouse": { "label": "Toggle mouse", "device": 0, "index": -1 },
		"char_crouch":       { "label": "Crouch"      , "device": 0, "index": -1 },
		"char_use1":         { "label": "Use 1"       , "device": 0, "index": -1 },
		"char_use2":         { "label": "Use 2"       , "device": 0, "index": -1 },
		"char_use3":         { "label": "Use 3"       , "device": 0, "index": -1 },
		"char_zoom_in":      { "label": "Zoom in"     , "device": 0, "index": -1 },
		"char_zoom_out":     { "label": "Zoom out"    , "device": 0, "index": -1 },
		"char_camera_hover": { "label": "Camera hover", "device": 0, "index": -1 }, # selects which side of player to hover camera 
	}

var settings := {
		"id": "Default",
		"fov_degrees": 75.0,
		"mouse_sensitivity": 1.0,
		"invert_x": false,
		"invert_y": false,
		"bindings": actions
	}
var settings_file = "user://TEST-SETTINGS-FILE.json"

var profile = {
	"name": "Default",
	"file": settings_file,
	"settings": settings
}
var profiles = [ profile ]


# Return success (true) or failure (false).
func LoadSettings(file: String):
	var player_data_file = File.new()
	if player_data_file.open(file, File.READ) != OK:
		print_debug("Could not open settings file! ", file)
		return

	var json := JSON.new()
	var err = json.parse(player_data_file.get_as_text())
	player_data_file.close()
	if err == OK:
		print ("Settings loaded: ", settings)
		# *** Verify settings is not corrupted
		# *** install settings from json.get_data()
		ApplySettings()
	else:
		print_debug("Error parsing settings file ", file)


#TODO: settings needs to be sanitized
# Assuming settings is current, apply its values to various widgets.
func ApplySettings(with_bindings: bool = true):
	for key in settings:
		match key:
			"fov_degrees":
				$VBoxContainer/ScrollContainer/Settings/HBoxContainer/FOV.text = str(settings[key])
			"mouse_sensitivity":
				$VBoxContainer/ScrollContainer/Settings/HBoxContainer2/Sensitivity.text = str(settings[key])
			"invert_x":
				$VBoxContainer/ScrollContainer/Settings/HBoxContainer3/InvertX.button_pressed = settings[key]
			"invert_y":
				$VBoxContainer/ScrollContainer/Settings/HBoxContainer3/InvertX.button_pressed = settings[key]
			"bindings":
				if with_bindings:
					print_debug("TODO apply bindings")


# Return success (true) or failure (false).
func SaveSettings(filename: String) -> bool:
	var json := JSON.new()
	var json_string = json.stringify(settings, '  ')
	
	var file = File.new()
	var err = file.open(filename, File.WRITE)
	if err != OK:
		return false
	file.store_string(json_string)
	file.close()
	print ("Settings saved to file ", filename)
	return true # false would be database/sql error for instance


# Set the bindings based on what is currently in InputMap.
# Note these are different when you are running versus when you are in editor.
func SetBindingsFromCurrentLive():
	print ("SetBindingsFromCurrentLive()...")
	
	#print ("actions before: ", actions)
	var cur_actions = InputMap.get_actions()
	#print ("cur_actions: ", cur_actions)
	for action in cur_actions:
		#print ("check action: ", action)
		if action in actions:
			var evs = InputMap.action_get_events(action)
			if evs == null || evs.size() == 0:
				actions[action]["index"] = -1
			else:
				#actions[action] = evs[0] #.as_text()
				if evs[0] is InputEventKey:
					actions[action]["device"] = DeviceType.KEY
					actions[action]["index"] = evs[0].physical_keycode
					#print ("Grabbing key event: ", evs[0], ", keycode: ", evs[0].get_keycode(),
					#	", kkm: ", evs[0].get_keycode_with_modifiers(),
					#	#", kkstr: ", OS.get_keycode_string(evs[0])
					#	)
				elif evs[0] is InputEventMouseButton:
					actions[action]["device"] = DeviceType.MOUSE
					actions[action]["index"] = evs[0].button_index
					#print ("Grabbing mouse event: ", evs[0], ", button: ", evs[0].get_button_index())
				elif evs[0] is InputEventJoypadButton:
					actions[action]["device"] = DeviceType.PAD
					actions[action]["index"] = evs[0].button_index
					#print ("Grabbing pad event: ", evs[0], ", button: ", evs[0].button_index)
			#print (actions[action])


# Set the bindings based on what is currently in project settings. Editor only.
func SetBindingsFromCurrentEditor():
	print ("SetBindingsFromCurrentEditor()")
	for action in actions:
		print ("check action: ", action)
		if ProjectSettings.has_setting("input/"+action):
			var setting = ProjectSettings.get_setting("input/"+action)
			print (action, ": ", setting)
			var events = setting.events
			print ("events: ", typeof(events), " ",  events.size(), events)
			var found_key = null
			if events.size() != 0:
				print ("events[0]: ", events[0])
				if events[0] is InputEventKey:
					found_key = events[0].keycode #note :this will be 0 when event is physical and vice versa
					print ("key e0.keycode: ", events[0].keycode)
					var physical_code = events[0].physical_keycode
					print ("  found ", action, ": ", found_key, " ", physical_code, "  ", OS.get_keycode_string(found_key), 
							", mapped: ", OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(physical_code)))
					settings.bindings[action]["device"] = DeviceType.KEY
					settings.bindings[action]["index"] = physical_code
					settings.bindings[action]["cap"]   = OS.get_keycode_string(physical_code)
					settings.bindings[action]["local"] = OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(physical_code))
				elif events[0] is InputEventMouseButton:
					found_key = events[0].button_index
					print ("mouse: e0.button_index: ", events[0].button_index)
					#var is_physical = events[0].physical_keycode
					print ("  found ", action, ": ", found_key, "  ")
					settings.bindings[action]["device"] = DeviceType.MOUSE
					settings.bindings[action]["index"] = found_key
				elif events[0] is InputEventJoypadButton:
					found_key = events[0].button_index
					print ("pad: e0.button_index: ", events[0].button_index)
					#var is_physical = events[0].physical_keycode
					print ("  found ", action, ": ", found_key, "  ")
					settings.bindings[action]["device"] = DeviceType.PAD
					settings.bindings[action]["index"] = found_key
			else:
				print ("found ", action, ": Unassigned")
				settings.bindings[action]["device"] = DeviceType.NONE
				#settings.bindings[action]["index"] = physical_code
		else:
			print ("action ",action," not in ProjectSettings")


func PopulateMenuWithBindings():
	for action in actions:
		var def = actions[action]
		var hbox := HBoxContainer.new()
		hbox.name = action
		var label := Label.new()
		label.name = action+"-Label"
		hbox.add_child(label)
		var button := KeyBindButton.new()
		button.control_config = self
		button.name = action+"-Button"
		button.action = action
		if def == null:
			label.text = action
			button.text = unassigned
		else:
			label.text = def["label"]
			match def.device:
				DeviceType.KEY:
					if def.index <= 0: button.text = unassigned
					else:
						#button.text = "key: "+OS.get_keycode_string(def.index)
						if display_physical:
							button.text = OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(def.index))
						else:
							button.text = OS.get_keycode_string(def.index)
				DeviceType.MOUSE:
					if def.index <= 0: button.text = unassigned
					else: button.text = "mouse: "+str(def.index)
				DeviceType.PAD:
					if def.index <= 0: button.text = unassigned
					else: button.text = "pad: "+str(def.index)
				_: #default
					button.text = unassigned
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(button)
		$VBoxContainer/ScrollContainer/Settings.add_child(hbox)


func SetBinding(action: String, device_type: int, index: int, device: int):
	print("Setting binding for ", action, ": type: ", device_type, ", index: ", index, ", device: ", device, ", devname: ", Input.get_joy_name(device))
	if not InputMap.has_action(action):
		push_error("Trying to set unknown action ", action)
		return
	InputMap.action_erase_events(action)
	var ev
	settings.bindings[action].device = device_type
	settings.bindings[action].index = index
	match device_type:
		DeviceType.KEY:
			ev = InputEventKey.new()
			ev.physical_keycode = index
		DeviceType.MOUSE:
			ev = InputEventMouseButton.new()
			ev.button_index = index
		DeviceType.PAD:
			ev = InputEventJoypadButton.new()
			ev.button_index = index
			ev.device = device
	InputMap.action_add_event(action, ev)


# This function is called from ui changes, not for changes at arbitrary times
# It is assumed value has already been sanitized before here.
func SetPropertyFromUI(property: String, value):
	if not (property in properties):
		push_error("Trying to set non-existent property ", property)
	match property:
		"fov":
			settings["fov"] = value
		"aim_fov":
			settings["aim_fov"] = value
		"mouse_sensitivity":
			settings["mouse_sensitivity"] = value
		"invert_x":
			settings["invert_x"] = value
		"invert_y":
			settings["invert_y"] = value
	
	setting_changed.emit(property, value)
	SaveSettings(settings_file)


func _ready():
	print ("ControlConfig ready")
	if not Engine.is_editor_hint():
		#LoadSettings(settings_file)
		SetBindingsFromCurrentLive()
		#SaveSettings(settings_file)
		PopulateMenuWithBindings()
		ApplySettings(false)


func _on_fov_text_changed(new_text):
	var value = new_text.to_float()
	if value > 30 && value < 120:
		SetPropertyFromUI("fov", value)


func _on_sensitivity_text_changed(new_text):
	var value = new_text.to_float()
	if value > 0.0:
		SetPropertyFromUI("mouse_sensitivity", value)


func _on_invert_x_toggled(button_pressed):
	SetPropertyFromUI("invert_x", button_pressed)


func _on_invert_y_toggled(button_pressed):
	SetPropertyFromUI("invert_y", button_pressed)
