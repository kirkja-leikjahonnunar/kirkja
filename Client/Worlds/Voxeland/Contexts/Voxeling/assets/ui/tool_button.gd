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
@onready var TOOLTIPS: PanelContainer = $Tooltips
@onready var HOTKEY_BUTTON: Button = $HotkeyButton
@onready var MOUSE_TIPS: HBoxContainer = $Tooltips/MouseTips
@onready var ANY_KEY_POPUP: Label = $Tooltips/AnyKey
@onready var LMB_LABEL: Label = $Tooltips/PanelLMB/LabelLMB
@onready var RMB_LABEL: Label = $Tooltips/PanelRMB/LabelRMB

# TODO: Make into a @tool later.
@export var tool_name: String = "tool"
@export var hotkey: String = "X"
@export var lmb_tip: String = "LBM\ntip"
@export var rmb_tip: String = "RMB\ntip" 


func _ready():
	TOOLTIPS.hide()
	UpdateToolInfo()


func Initialize(new_tool_name: String, new_hotkey: String, new_lmb_tip: String, new_rmb_tip: String):
	tool_name = new_tool_name
	hotkey = new_hotkey
	lmb_tip = new_lmb_tip
	rmb_tip = new_rmb_tip


func UpdateToolInfo():
	text = tool_name
	HOTKEY_BUTTON.text = hotkey
	LMB_LABEL.text = lmb_tip
	RMB_LABEL.text = rmb_tip


func _on_tool_button_pressed():
	TOOLTIPS.show()
	MOUSE_TIPS.hide()
	
	# TODO: Play sfx and other animation.
	pass # Replace with function body.


func _on_hotkey_pressed():
	# Open an interface to press the any key.
	pass # Replace with function body.


func _on_tool_button_mouse_entered():
	TOOLTIPS.show()


func _on_tool_button_mouse_exited():
	TOOLTIPS.hide()
