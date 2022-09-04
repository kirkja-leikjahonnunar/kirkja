@tool
extends Button

# 
@export var tool_name: String = "tool":
	set(value):
		#UpdateName(value)
#		tool_name = value
#		text = tool_name


@export var hotkey: String = "X":
	set(value):
		#hotkey = value
		#UpdateHotkey(value)
#		if hotkey_button.is_inside_tree():
#			hotkey_button.text = hotkey


@export var lmb_tip: String = "LBM\ntip"
@export var rmb_tip: String = "RMB\ntip" 

# Scene Nodes.
@onready var tooltips: HBoxContainer = $Tooltips
@onready var hotkey_button: Button = $HotkeyButton
@onready var lmb_label: Label = $Tooltips/PanelLMB/LabelLMB
@onready var rmb_label: Label = $Tooltips/PanelRMB/LabelRMB


func _ready():
	tooltips.hide()
	#update_tool_info(tool_name, lmb_tip, rmb_tip)
	#hotkey_button.text = ""


func UpdateName(new_name):
	tool_name = new_name

func UpdateHotkey(new_hotkey):
	hotkey = new_hotkey

func UpdateLabelLMB(new_lmb_tip):
	lmb_tip = new_lmb_tip

func UpdateLabelRMB(new_rmb_tip):
	rmb_tip = new_rmb_tip

func UpdateToolInfo(new_tool_name: String, new_hotkey: String, lmb_tip: String, rmb_tip: String):
	tool_name = new_tool_name
	hotkey = new_hotkey
	lmb_label.text = lmb_tip
	rmb_label.text = rmb_tip


func _on_tool_button_pressed():
	# TODO: Play sfx and other animation.
	pass # Replace with function body.


func _on_hotkey_pressed():
	# Open an interface to press the any key.
	pass # Replace with function body.


func _on_tool_button_mouse_entered():
	tooltips.show()


func _on_tool_button_mouse_exited():
	tooltips.hide()
