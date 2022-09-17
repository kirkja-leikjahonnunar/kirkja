extends Control

@onready var TOOL_CREATE: Button = $Toolbar/ToolCreate
@onready var TOOL_COLOR: Button = $Toolbar/ToolColor
@onready var TOOL_SHAPE: Button = $Toolbar/ToolShape
@onready var TOOL_ROTATE: Button = $Toolbar/ToolRotate


func _ready():
	# Listen for tool button clicks.
	TOOL_CREATE.pressed.connect(SelectTool.bind(TOOL_CREATE))
	TOOL_COLOR.pressed.connect(SelectTool.bind(TOOL_COLOR))
	TOOL_SHAPE.pressed.connect(SelectTool.bind(TOOL_SHAPE))
	TOOL_ROTATE.pressed.connect(SelectTool.bind(TOOL_ROTATE))
	
	SelectTool(TOOL_CREATE)


func SelectTool(tool: Button):
	for child in $Toolbar.get_children():
		child.Activate(false)
	
	# TODO: Possible to emit custom signal to listen for key strokes?
	
	tool.Activate(true)
