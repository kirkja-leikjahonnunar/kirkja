class_name KeyBindButton
extends Button

var control_config
var waiting_for_input := false

var action : String
var action_index := 0
var device_type = 0 #ControlConfig.DeviceType.UNKNOWN
var device : int
var old_text : String


func _ready():
	toggle_mode = true
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	#toggled.connect(_toggled) <- _toggled() still gets called even when commented out!!
	button_up.connect(_on_button_up)
	#button_up.connect(_on_button_down)

# for absorbing events, need to get key+pad on the down stroke, otherwise press Down for instance leaks through
func _input(event):
	if not waiting_for_input: 
		if absorb_next_input_up:
			print ("trying to absorb next up")
			absorb_next_input_up = false
			get_viewport().set_input_as_handled()
		return
	
	if event is InputEventKey:
		if event.pressed:
			print ("key event, key: ", event.physical_keycode, ", pressed: ", event.pressed)
			if event.physical_keycode == KEY_ESCAPE: # canceled! we don't allow rebinding ESC
				text = old_text
			else:
				device = event.device
				action_index = event.physical_keycode
				device_type = ControlConfig.DeviceType.KEY
				text = event.as_text()
				control_config.SetBinding(action, device_type, action_index, event.device)
			ClickCleanup(false, false)
			absorb_next_input_up = true
		else: 
			if absorb_next_input_up:
				print ("trying to absorb next up")
				absorb_next_input_up = false
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton && not event.pressed:
		print ("mouse button event: ", event.pressed," ", event.button_index)
		device = event.device
		action_index = event.button_index
		device_type = ControlConfig.DeviceType.MOUSE
		text = "mouse: "+str(event.button_index)
		ClickCleanup(true, false)
	
	elif event is InputEventJoypadButton && event.pressed:
		print ("joypad button event: ", event.pressed," ", event.button_index)
		device = event.device
		action_index = event.button_index
		device_type = ControlConfig.DeviceType.PAD
		text = "pad: "+str(event.button_index)
		ClickCleanup(true, false)
	#elif event is InputEventMIDI:
		#TODO midi!


func ClickCleanup(do_binding: bool, absorb_up: bool):
	waiting_for_input = false
	button_pressed = false
	get_viewport().set_input_as_handled()
	#absorb_next_up = absorb_up
	if do_binding: control_config.SetBinding(action, device_type, action_index, device)

#var absorb_next_up := false
var absorb_next_input_up := false

#func _on_button_down(): # note this is called for ANYTHING that triggers the button going up
#	print ("_on_button_down on ", name)

func _on_button_up(): # note this is called for ANYTHING that triggers the button going up
	print ("_on_button_up on ", name)
#	if absorb_next_up:
#		absorb_next_up = false
#	elif waiting_for_input == false:
#		SetWaiting()
	#-----------------
	if waiting_for_input == false:
		SetWaiting()

func SetWaiting():
		print ("choose key activate _on_button_up, now waiting for input")
		waiting_for_input = true
		old_text = text
		text = control_config.PressAnyKey #"Press any key"
