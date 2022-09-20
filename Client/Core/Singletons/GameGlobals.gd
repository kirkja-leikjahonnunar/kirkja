extends Node
#class_name GameGlobals


var main_camera: Camera3D

# The current player node, usually a CharacterBody3D, RigidBody3D, or sometimes a plain Node3D.
# Note, a PlayerContext will be a child of this object.
var current_player_object : Node3D


# The UI controller that holds all the hotkeys
var hotkey_manager : ControlConfig


# Low level function to update a binding for a Godot action.
# No UI is updated here, see ControlConfig for that.
func UpdateBinding(action: String, device, device_type, binding_index, button_index):
	push_error("IMPLEMENT ME")
