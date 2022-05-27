extends Node



func _unhandled_input(event):
#	print ("_input event", event)
#	if Input.is_action_pressed("Quit"): 
#		get_tree().quit()
		
	if event is InputEventKey:
		#print ("event: ", event)
		if event.physical_keycode == KEY_ESCAPE:
			get_tree().quit()
