extends Control

@onready var toolbar : VBoxContainer = $toolbar
@onready var tool_create : Button = $toolbar/tool_create
@onready var tool_rotate : Button = $toolbar/tool_rotate
@onready var tool_color : Button = $toolbar/tool_color
@onready var tool_shape : Button = $toolbar/tool_shape

var current_tool : Button


func _ready():
	current_tool = tool_create

func _on_tool_create_pressed():
	current_tool = tool_create

func _on_tool_rotate_pressed():
	current_tool = tool_rotate
