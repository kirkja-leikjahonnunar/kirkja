extends Node

# Catch ESC key on key up. use get_viewport().set_input_as_handled() to prevent an ESC press from quiting.
func _unhandled_input(event):
	if event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE && event.pressed == false:
			get_tree().quit()
