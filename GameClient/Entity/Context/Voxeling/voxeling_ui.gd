extends Control

@onready var toolbar := $toolbar
@onready var tool_create : Button = $toolbar/tool_create
@onready var tool_rotate : Button = $toolbar/tool_rotate
@onready var tool_color = $toolbar/tool_color
@onready var tool_shape = $toolbar/tool_shape

var current_tool : Button


func _ready():
	current_tool = tool_create


func _on_tool_create_pressed():
	pass # Replace with function body.


func _on_tool_rotate_pressed():
	pass # Replace with function body.
