extends Control

#TODO: Use ItemList instead ??

#const var item_object = preload("")

@export var normal_fg := Color("ffffff")
@export var normal_bg := Color("cccccc")

@export var hover_fg := Color("aaffaa")
@export var hover_bg := Color("dddddd")


signal save_pressed


var current_hovered : ColorRect
var current_item
var add_button

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/ColorRect.mouse_entered.connect(_on_item_mouse_entered.bind("ColorRect"))
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/ColorRect.mouse_exited.connect(_on_item_mouse_exited.bind("ColorRect"))
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/ColorRect.gui_input.connect(_on_item_gui_input.bind("ColorRect"))
	add_button = $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew


func SetAddHovered():
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew.color = hover_bg
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew/PlusH.color = hover_fg
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew/PlusV.color = hover_fg
	current_hovered = $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew

func SetAddUnhovered():
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew.color = normal_bg
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew/PlusH.color = normal_fg
	$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew/PlusV.color = normal_fg
	if $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew == current_hovered:
		current_hovered = null


func SetItemHovered(which):
	var node = get_node("VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/"+which)
	current_hovered = node as ColorRect
	current_hovered.color = hover_bg

func SetItemUnhovered(which):
	var node = get_node("VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/"+which)
	node.color = normal_bg
	if node == current_hovered:
		current_hovered = null


func _on_add_new_mouse_entered():
	current_hovered = $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew
	SetAddHovered()

func _on_add_new_mouse_exited():
	if current_hovered == $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew:
		SetAddUnhovered()

func _on_add_new_gui_input(event):
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		if event.pressed:
			print ("mouse down on add item")
			# add new slot
			# replace add button with an item
			# hide add button


func _on_item_gui_input(event, which):
	var node = get_node("VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/"+which)
	
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
		push_error("trying to save but null item. save button should have been grayed when none selected..") # button should be gray when no current item
		#return
	#print ("NEED TO IMPLEMENT SAVE BUTTON")
	save_pressed.emit()


