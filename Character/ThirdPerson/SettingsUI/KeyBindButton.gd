class_name KeyBindButton
extends Button

var control_config
var waiting_for_input := false

var action : String
var action_index := 0
var device_type = 0 #ControlConfig.DeviceType.UNKNOWN
var old_text : String


func _ready():
	toggle_mode = true
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	#toggled.connect(_toggled) <- _toggled() still gets called even when commented out!!
	button_up.connect(_on_button_up)


func _input(event):
	if not waiting_for_input: 
#		if event is InputEventMouseButton && event.pressed == true:
#			print ("button down, now waiting for input")
#			waiting_for_input = true
#			old_text = text
#			text = "Press any key"
		return
	
	if event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE: # canceled! we don't allow rebinding ESC
			text = old_text
		else:
			action_index = event.physical_keycode
			device_type = ControlConfig.DeviceType.KEY
			text = event.as_text()
		waiting_for_input = false
		button_pressed = false
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		print ("mouse button event: ", event.pressed," ", event.button_mask)
		if event.pressed:
			action_index = event.button_mask
			device_type = ControlConfig.DeviceType.MOUSE
			text = "mouse: "+str(event.button_mask)
			waiting_for_input = false
			button_pressed = false
			get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton:
		print ("joypad button event: ", event.pressed," ", event.button_index)
		if event.pressed:
			action_index = event.button_index
			device_type = ControlConfig.DeviceType.PAD
			text = "pad: "+str(event.button_index)
			waiting_for_input = false
			button_pressed = false
			get_viewport().set_input_as_handled()
	
	if not waiting_for_input: # we found a new key/button to bind to action
		print ("new action ", text, " new index: ", action_index, ", device_type: ", device_type) #ControlConfig.DeviceType.keys()[device_type])


#func _toggled(value):
#	print (".. toggled in ",name,": ", value, ", waiting: ", waiting_for_input, ", b is pressed: ", button_pressed)


func _on_button_up(): # note this is called for ANYTHING that triggers the button going up
	print ("_on_button_up on ", name)
	if waiting_for_input == false:
		print ("choose key activate _on_button_up, now waiting for input")
		waiting_for_input = true
		old_text = text
		text = control_config.PressAnyKey #"Press any key"
