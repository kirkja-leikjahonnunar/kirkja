extends Button

#@export var tool_name: String = "tool":
#	set(value):
#		#UpdateName(value)
#		tool_name = value
#		text = tool_name


#@export var hotkey: String = "X":
#	set(value):
#		#hotkey = value
#		#UpdateHotkey(value)
##		if hotkey_button.is_inside_tree():
##			hotkey_button.text = hotkey

# Scene Nodes.
@onready var HOTKEY_BUTTON: Button = $HotkeyButton
@onready var TOOLTIPS: HBoxContainer = $Tooltips
@onready var LMB_LABEL: Label = $Tooltips/PanelLMB/LabelLMB
@onready var RMB_LABEL: Label = $Tooltips/PanelRMB/LabelRMB
@onready var ANY_KEY_POPUP: PanelContainer = $AnyKeyPopup
@onready var TOOL_NAME: Label = $AnyKeyPopup/PressAnyKey/ToolName

# TODO: Make into a @tool later.
@export var tool_label: String = "tool" # Should hook into translations
@export var tool_id: String = "tool"
@export var hotkey: String = "X"
@export var lmb_tip: String = "LBM tip."
@export var rmb_tip: String = "RMB tip."


func _ready():
	TOOLTIPS.hide()
	ANY_KEY_POPUP.hide()
	UpdateToolInfo()
	set_process_input(false)


func UpdateToolInfo():
	text = tool_label
	TOOL_NAME.text = tool_label + " Hotkey"
	HOTKEY_BUTTON.text = hotkey
	LMB_LABEL.text = lmb_tip
	RMB_LABEL.text = rmb_tip


func Activate(value: bool):
	if value: modulate = Color.WHITE
	else: modulate = Color.GRAY


#var waiting_for_input := false

# Scan for new hot key
func _input(event):
	#if not waiting_for_input: 
	#	return
	
	if event is InputEventKey:
		var action_index = event.physical_keycode
		var device_type = ControlConfig.DeviceType.KEY
		if event.pressed:
			print ("key event, key: ", event.physical_keycode, ", pressed: ", event.pressed)
			if event.physical_keycode == KEY_ESCAPE: # canceled! we don't allow rebinding ESC
				ANY_KEY_POPUP.hide()
			else:
				# Update hotkey text, but don't actually set until input up
				$AnyKeyPopup/PressAnyKey/AnyKey.text = event.as_text()
		else:
			UpdateBinding(device_type, action_index, event.device)
			StopWaitingForInput()
			
#	elif event is InputEventMouseButton:
#		if not event.pressed:
#			print ("mouse button event: ", event.pressed," ", event.button_index)
#			action_index = event.button_index
#			device_type = DeviceType.MOUSE
#			text = "mouse: "+str(event.button_index)
#			ClickCleanup(true)
	
	elif event is InputEventJoypadButton:
		var action_index = event.button_index
		var device_type = ControlConfig.DeviceType.PAD
		
		if event.pressed:
			print ("joypad button event: ", event.pressed," ", event.button_index)
			$AnyKeyPopup/PressAnyKey/AnyKey.text = "pad: "+str(event.button_index) # TOOD: make it show controller button icons
			#ClickCleanup(true)
		else:
			UpdateBinding(device_type, action_index, event.device)
			StopWaitingForInput()
		
	#elif event is InputEventMIDI:
		#TODO midi!


func UpdateBinding(device_type, action_index, device):
	HOTKEY_BUTTON.text = $AnyKeyPopup/PressAnyKey/AnyKey.text
	if GameGlobals.hotkey_manager != null:
		GameGlobals.hotkey_manager.SetBinding(tool_id, device_type, action_index, device)


func StartWaitingForInput():
	TOOLTIPS.hide()
	ANY_KEY_POPUP.show()
	set_process_input(true)
	#waiting_for_input = true

func StopWaitingForInput():
	ANY_KEY_POPUP.hide()
	#waiting_for_input = false
	set_process_input(false)
	get_viewport().gui_release_focus()


#---------------------------------- Signals --------------------------------------

# Callback to initiate listening for a new hotkey
func _on_hotkey_pressed():
	StartWaitingForInput()



func _on_tool_button_mouse_entered():
	TOOLTIPS.show()


func _on_tool_button_mouse_exited():
	TOOLTIPS.hide()
	ANY_KEY_POPUP.hide()
