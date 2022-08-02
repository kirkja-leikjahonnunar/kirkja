@tool
extends EditorPlugin

const GizmoPlugin = preload("res://addons/camera_placements/CameraPlacementGizmos.gd")


var gizmo_plugin = GizmoPlugin.new()

var eds = get_editor_interface().get_selection()


func _enter_tree():
	add_spatial_gizmo_plugin(gizmo_plugin)
	
	eds.selection_changed.connect(_on_selection_changed)
	#eds.connect("selection_changed", self, "_on_selection_changed")


func _on_selection_changed():
	var selected = eds.get_selected_nodes() 
	#print("cam place plugin: selection changed: ", selected)
	if not selected.is_empty():
		# Always pick first node in selection
		gizmo_plugin.SetCurrentSelected(selected[0])
	else:
		gizmo_plugin.SetCurrentSelected(null)


func _exit_tree():
	remove_spatial_gizmo_plugin(gizmo_plugin)
