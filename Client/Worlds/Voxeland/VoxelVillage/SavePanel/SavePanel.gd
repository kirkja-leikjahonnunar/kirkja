extends Control

#TODO: Use ItemList instead ??

#const var item_object = preload("")

@export var normal_fg := Color("ffffff")
@export var normal_bg := Color("cccccc")

@export var hover_fg := Color("aaffaa")
@export var hover_bg := Color("dddddd")


signal save_pressed(path: String)
signal load_pressed(path: String)
signal canceled


var slot_template = preload("res://Worlds/Voxeland/VoxelVillage/SavePanel/SaveSlot.tscn")

var current_hovered #: SaveSlot
var current_item
@onready var add_button = $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/AddNew

var save_path : String
var save_extension : String


enum DialogMode { Saving, Loading }
var dialog_mode : int = DialogMode.Saving


#---------------------------- Slot list maintenance ------------------------------------

func Activate():
	visible = true

func Deactivate():
	visible = false


func SetForSaving():
	add_button.visible = true
	$VBoxContainer/Label.text = "Save"
	dialog_mode = DialogMode.Saving
	$BG.color = Color("#8154ff70")


func SetForLoading():
	add_button.visible = false
	$VBoxContainer/Label.text = "Load"
	dialog_mode = DialogMode.Loading
	$BG.color = Color("#88888870")


func FlushSlots():
	for child in $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer.get_children():
		if child.name == "AddNew" : continue
		child.queue_free()


# Return a list of files (not directories) at the directory path that end with ending.
func UpdateSaveSlots(path: String, ending: String):
	if not path.ends_with("/"):
		path = path + "/"
	if not ending.begins_with("."):
		ending = "."+ending
	save_path = path
	save_extension = ending
	
	var dir = Directory.new()
	var elements := []
	
	if dir.open(path) != OK:
		print_debug ("Could not open directory ", path)
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			print("Found directory: " + file_name)
		else:
			print("Found file: " + file_name)
			if file_name.ends_with(ending):
				elements.append(path + file_name)
		file_name = dir.get_next()
	
	for i in range(elements.size()):
		var slot = slot_template.instantiate()
		slot.path = elements[i]
		slot.name = str(i)
		slot.SetText("Slot "+str(i))
		$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer.add_child(slot)
		$VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer.move_child(slot, i)
		slot.mouse_entered.connect(_on_item_mouse_entered.bind(slot.name))
		slot.mouse_exited.connect(_on_item_mouse_exited.bind(slot.name))
		slot.gui_input.connect(_on_item_gui_input.bind(slot.name))



#---------------------------------- main -------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	#var test_file := "/one/two/three.txt"
	#print ("TEST basename: ", test_file.get_basename())
	#print ("TEST extension: ", test_file.get_extension())
	#print ("TEST file: ", test_file.get_file())
	pass


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
	print ("over ", which)
	var node = get_node("VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/"+str(which))
	current_hovered = node #as ColorRect
	current_hovered.SetColor(hover_bg)

func SetItemUnhovered(which):
	print ("left ", which)
	var node = get_node("VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/"+str(which))
	node.SetColor(normal_bg)
	if node == current_hovered:
		current_hovered = null



#--------------------------------- Signals ----------------------------------------

func _on_add_new_mouse_entered():
	print ("over AddNew")
	current_hovered = add_button
	SetAddHovered()

func _on_add_new_mouse_exited():
	print ("left AddNew")
	if current_hovered == add_button:
		SetAddUnhovered()

func UniquePath() -> String:
	var slot_parent = $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer
	var i = slot_parent.get_child_count()-1
	var new_path = save_path + str(i) + save_extension
	var flag : bool = true
	while flag:
		flag = false
		for child in slot_parent.get_children():
			if child.name == "AddNew": continue
			if child.path == new_path:
				flag = true
				break
		if not flag:
			break
		flag = true
		i += 1
		new_path = save_path + str(i) + save_extension
	return new_path

func _on_add_new_gui_input(event):
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		if event.pressed:
			print ("mouse down on add item")
			
			# Maybe do this instead of allowing infinite new slots at once?
			#   add new slot
			#   replace add button with an item
			#   hide add button
			#   reset add new button after dialog deactivated
			
			var new_path : String = UniquePath()
			var slot = slot_template.instantiate()
			slot.path = new_path
			slot.name = new_path.get_file().get_basename()
			slot.SetText("Slot "+str(slot.name)) #TODO "Slot" needs hook into internationalization
			var slot_parent = $VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer
			slot_parent.add_child(slot)
			slot_parent.move_child(slot, slot_parent.get_child_count()-2)
			
			slot.mouse_entered.connect(_on_item_mouse_entered.bind(slot.name))
			slot.mouse_exited.connect(_on_item_mouse_exited.bind(slot.name))
			slot.gui_input.connect(_on_item_gui_input.bind(slot.name))
			


func _on_item_gui_input(event, which):
	var node = get_node("VBoxContainer/MarginContainer/ScrollContainer/HFlowContainer/"+str(which))
	
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		if event.pressed:
			print ("mouse down on item ", which)
			current_item = node
			if event.double_click:
				if dialog_mode == DialogMode.Saving:
					save_pressed.emit(current_item.path)
				else:
					load_pressed.emit(current_item.path)

func _on_item_mouse_entered(which):
	SetItemHovered(which)

func _on_item_mouse_exited(which):
	SetItemUnhovered(which)


func _on_save_button_pressed():
	if current_item == null:
		push_error("trying to save but null item. save button should have been grayed when none selected..") # button should be gray when no current item
		#return
	
	if dialog_mode == DialogMode.Saving:
		save_pressed.emit(current_item.path)
	else:
		load_pressed.emit(current_item.path)




func _on_save_panel_gui_input(event):
	if event is InputEventKey:
		if event.pressed and event.physical_keycode == KEY_ESCAPE:
			print ("Canceled!")
			canceled.emit()
			get_viewport().set_input_as_handled()

