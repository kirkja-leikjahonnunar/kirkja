@tool # @tool needs to be above the enum.
extends StaticBody3D
class_name Voxel

enum Shapes # enum needs to be before using it in @export.
{
	CUBE,
	WEDGE,
	CORNER
}

@export var base_color : Color = Color("999666"):
	set(value):
		base_color = value
		if Engine.is_editor_hint():
			$Model/shapes/cube_base.get_surface_override_material(0).albedo_color = base_color

@export var shape : Shapes = Shapes.CUBE:
	set(value):
		shape = value
		
		match shape:
			Shapes.CUBE:
				SwapShape(Shapes.CUBE)
				print("CUBE")
			Shapes.WEDGE:
				SwapShape(Shapes.WEDGE)
				print("WEDGE")
			Shapes.CORNER:
				SwapShape(Shapes.CORNER)
				print("CORNER")

#@export var texture : Texture2D


func _init():
	SwapShape(Shapes.WEDGE)


func SwapShape(shape : Shapes):
	$Model/shapes/cube_base.hide()
	$Model/shapes/cube_flare.hide()
	$Model/shapes/wedge_base.hide()
	$Model/shapes/wedge_flare.hide()
	$Model/shapes/corner_base.hide()
	$Model/shapes/corner_flare.hide()
	
	match shape:
		Shapes.CUBE:
			$Model/shapes/cube_base.show()
			$Model/shapes/cube_flare.show()
		Shapes.WEDGE:
			$Model/shapes/wedge_base.show()
			$Model/shapes/wedge_flare.show()
		Shapes.CORNER:
			$Model/shapes/corner_base.show()
			$Model/shapes/corner_flare.show()
