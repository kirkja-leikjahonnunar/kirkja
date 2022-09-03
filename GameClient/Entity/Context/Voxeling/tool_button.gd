@tool
extends Button

@export var tool_name : String = "tool":
	set(value):
		tool_name = value
		update_tool_name(value)


@export var hotkey : String = "X"

@onready var tooltips : HBoxContainer = $tooltips
@onready var hotkey_button : Button = $hotkey_button
@onready var lmb_tip : Label = $tooltips/lmb_tip
@onready var rmb_tip : Label = $tooltips/rmb_tip


func _ready():
	update_tool_name(tool_name)
	update_hotkey(hotkey)


func update_tool_name(new_tool_name : String):
	tool_name = new_tool_name
	text = tool_name


func update_hotkey(new_key : String):
	hotkey = new_key
	hotkey_button.text = hotkey


func _on_tool_button_pressed():
	# TODO: Play sfx and other animation.
	pass # Replace with function body.


func _on_hotkey_pressed():
	# Open an interface to press any key.
	pass # Replace with function body.


func _on_tool_button_mouse_entered():
	tooltips.show()


func _on_tool_button_mouse_exited():
	tooltips.hide()
