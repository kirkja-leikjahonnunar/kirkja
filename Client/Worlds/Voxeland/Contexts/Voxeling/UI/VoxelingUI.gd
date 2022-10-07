extends Control

@onready var TOOL_CREATE: Button = $Toolbar/ToolCreate
@onready var TOOL_COLOR: Button = $Toolbar/ToolColor
@onready var TOOL_SHAPE: Button = $Toolbar/ToolShape
@onready var TOOL_ROTATE: Button = $Toolbar/ToolRotate


signal tool_selected(which: String)


func _ready():
	# Listen for tool button clicks.
	TOOL_CREATE.pressed.connect(SelectTool.bind(TOOL_CREATE))
	TOOL_COLOR.pressed.connect(SelectTool.bind(TOOL_COLOR))
	TOOL_SHAPE.pressed.connect(SelectTool.bind(TOOL_SHAPE))
	TOOL_ROTATE.pressed.connect(SelectTool.bind(TOOL_ROTATE))
	
	SelectTool(TOOL_CREATE)
	
#	call_deferred("VerifyControlConfig")
#
#func VerifyControlConfig():
#	if GameGlobals.hotkey_manager == null:
#		options = 


# Callback for tool button presses.
func SelectTool(tool: Button):
	for child in $Toolbar.get_children():
		child.Activate(false)
	
	# TODO: Possible to emit custom signal to listen for key strokes?
	
	tool.Activate(true)
	tool_selected.emit(tool.tool_id)


func SelectToolById(mode):
	match mode:
		"Create": SelectTool(TOOL_CREATE)
		"Rotate": SelectTool(TOOL_ROTATE)
		"Color":  SelectTool(TOOL_COLOR)
		"Shape":  SelectTool(TOOL_SHAPE)


func UpdateCompass(orientation):
	$VoxelPreview.UpdateCompass(orientation)
