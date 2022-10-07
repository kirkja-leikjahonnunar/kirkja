extends Control

var parent_menu = null

@export var node_components : Array[NodePath] = []
#@export var node_array_test : Array[Node] = []

var settings := {}

func _ready():
	if node_components != null:
		for component in node_components:
			if component.is_empty(): continue
			print("found options component: ", component)
			var node = get_node(component)
			if node != null && node.has_method("GetSettingsDictionary"):
				var stuff = node.GetSettingsDictionary()
				if stuff != null:
					settings[node.name] = stuff
	print ("found settings: ", settings)


func GetControllerOptionsNode():
	return $TabContainer/Controls


# Return success (true) or failure (false).
func SaveSettings(filename: String) -> bool:
	var json := JSON.new()
	var json_string = json.stringify(settings, '  ')
	
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file.get_error() != OK:
		return false
	file.store_string(json_string)
	file = null #file.close()
	print ("Settings saved to file ", filename)
	return true # false would be database/sql error for instance


# Return success (true) or failure (false).
func LoadSettings(file: String) -> bool:
	var player_data_file = FileAccess.open(file, FileAccess.READ)
	if player_data_file.get_error() != OK:
		print_debug("Could not open settings file! ", file)
		return false

	var json := JSON.new()
	var err = json.parse(player_data_file.get_as_text())
	player_data_file = null #player_data_file.close()
	if err != OK:
		print_debug("Error parsing settings file ", file)
		return false
	
	var new_settings = json.get_data()
	print ("Loaded settings: ", new_settings)
	# *** Verify settings is not corrupted
	#ApplySettings()
	return true

