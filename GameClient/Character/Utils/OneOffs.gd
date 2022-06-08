@tool
extends EditorScript


func _run():
	AddEditorResourcePicker()


# Add an EditorResourcPicker to the currently selected node.
func AddEditorResourcePicker():
	var picker = EditorResourcePicker.new()
	picker.name = "EditorResourcePicker"
	picker.minimum_size = Vector2(100,0)
	
	var plugin = EditorPlugin.new()
	var edi = plugin.get_editor_interface() # now you always have the interface
	var sel = edi.get_selection().get_selected_nodes()
	
	var dest
	if sel.size() > 0:
		dest = sel[0]
	else:
		dest = edi.get_edited_scene_root()
		print ("dest child name: ", dest.get_child(0).name)
	var new_owner = dest.get_tree().edited_scene_root
	
	#var scene_root = get_tree().edited_scene_root
	#var new_owner = get_tree().edited_scene_root
	
	
	dest.add_child(picker)
	dest.set_owner(new_owner)
	
	print ("Resource picker added")
