extends Control

#TODO: Use ItemList instead ??


@export var normal_fg := Color("ffffff")
@export var normal_bg := Color("cccccc")

@export var hover_fg := Color("aaffaa")
@export var hover_bg := Color("dddddd")


var current_hovered : ColorRect
var current_item


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/ScrollContainer/HFlowContainer/ColorRect.mouse_entered.connect(_on_item_mouse_entered.bind("ColorRect"))
	$VBoxContainer/ScrollContainer/HFlowContainer/ColorRect.mouse_exited.connect(_on_item_mouse_exited.bind("ColorRect"))
	$VBoxContainer/ScrollContainer/HFlowContainer/ColorRect.gui_input.connect(_on_item_gui_input.bind("ColorRect"))


func SetAddHovered():
	$VBoxContainer/ScrollContainer/HFlowContainer/AddNew.color = hover_bg
	$VBoxContainer/ScrollContainer/HFlowContainer/AddNew/PlusH.color = hover_fg
	$VBoxContainer/ScrollContainer/HFlowContainer/AddNew/PlusV.color = hover_fg
	current_hovered = $VBoxContainer/ScrollContainer/HFlowContainer/AddNew

func SetAddUnhovered():
	$VBoxContainer/ScrollContainer/HFlowContainer/AddNew.color = normal_bg
	$VBoxContainer/ScrollContainer/HFlowContainer/AddNew/PlusH.color = normal_fg
	$VBoxContainer/ScrollContainer/HFlowContainer/AddNew/PlusV.color = normal_fg
	if $VBoxContainer/ScrollContainer/HFlowContainer/AddNew == current_hovered:
		current_hovered = null


func SetItemHovered(which):
	var node = get_node("VBoxContainer/ScrollContainer/HFlowContainer/"+which)
	current_hovered = node as ColorRect
	current_hovered.color = hover_bg

func SetItemUnhovered(which):
	var node = get_node("VBoxContainer/ScrollContainer/HFlowContainer/"+which)
	node.color = normal_bg
	if node == current_hovered:
		current_hovered = null


func _on_add_new_mouse_entered():
	current_hovered = $VBoxContainer/ScrollContainer/HFlowContainer/AddNew
	SetAddHovered()

func _on_add_new_mouse_exited():
	if current_hovered == $VBoxContainer/ScrollContainer/HFlowContainer/AddNew:
		SetAddUnhovered()

func _on_item_gui_input(event, which):
	var node = get_node("VBoxContainer/ScrollContainer/HFlowContainer/"+which)
	
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		if event.pressed:
			print ("mouse down on item ", which)
			current_item = node


func _on_item_mouse_entered(which):
	SetItemHovered(which)

func _on_item_mouse_exited(which):
	SetItemUnhovered(which)


func _on_save_button_pressed():
	if current_item == null:
		push_error("trying to save but null item. SHOULDN'T HAPPEN") # button should be gray when no current item
		return
	print ("NEED TO IMPLEMENT SAVE BUTTON")
