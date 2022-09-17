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
@export var tool_name: String = "tool"
@export var hotkey: String = "X"
@export var lmb_tip: String = "LBM tip."
@export var rmb_tip: String = "RMB tip."


func _ready():
	TOOLTIPS.hide()
	ANY_KEY_POPUP.hide()
	UpdateToolInfo()


func UpdateToolInfo():
	text = tool_name
	TOOL_NAME.text = tool_name + " Hotkey"
	HOTKEY_BUTTON.text = hotkey
	LMB_LABEL.text = lmb_tip
	RMB_LABEL.text = rmb_tip


func Activate(value: bool):
	if value: modulate = Color.WHITE
	else: modulate = Color.GRAY


func _on_hotkey_pressed():
	TOOLTIPS.hide()
	ANY_KEY_POPUP.show()


func _on_tool_button_mouse_entered():
	TOOLTIPS.show()


func _on_tool_button_mouse_exited():
	TOOLTIPS.hide()
	ANY_KEY_POPUP.hide()
