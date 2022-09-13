@tool
extends Node3D


@export var base_color : Color = Color("999666"):
	set(value):
		base_color = value
		if Engine.is_editor_hint():
			$MeshInstance3D.get_surface_override_material(0).albedo_color = base_color


@export var message : String = "!!!":
	set(value):
		message = value
		if Engine.is_editor_hint():
			UpdateText(message)


func UpdateText(new_text : String):
	var mesh = $MeshInstance3D.get_mesh()
	if mesh is TextMesh:
		mesh.text = new_text
