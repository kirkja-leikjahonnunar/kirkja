@tool # @tool needs to be above the enum.
extends StaticBody3D
class_name Voxel

@onready var BASE = preload("res://Maps/VoxelVillage/Voxel/assets/base.material")
@onready var FLARE = preload("res://Maps/VoxelVillage/Voxel/assets/flare.material")

enum Shapes # enum needs to be before using it in @export.
{
	CUBE,
	WEDGE,
	CORNER
}


@export var base_color : Color = Color("999666"):
	set(value):
		base_color = value
		#if Engine.is_editor_hint():
		for mesh in $Model/shapes.get_children(true):
			if "base" in mesh.name:
				if mesh.get_surface_override_material(0) == null:
					mesh.set_surface_override_material(0, BASE)
				else:
					mesh.get_surface_override_material(0).albedo_color = base_color
			elif "flare" in mesh.name:
				if mesh.get_surface_override_material(0) == null:
					mesh.set_surface_override_material(0, FLARE)
				else:
					mesh.get_surface_override_material(0).albedo_color = base_color * 0.60


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


func SwapShape(new_shape : Shapes):
	$Model/shapes/cube_base.hide()
	$Model/shapes/cube_flare.hide()
	$Model/shapes/wedge_base.hide()
	$Model/shapes/wedge_flare.hide()
	$Model/shapes/corner_base.hide()
	$Model/shapes/corner_flare.hide()
	
	match new_shape:
		Shapes.CUBE:
			$Model/shapes/cube_base.show()
			$Model/shapes/cube_flare.show()
		Shapes.WEDGE:
			$Model/shapes/wedge_base.show()
			$Model/shapes/wedge_flare.show()
		Shapes.CORNER:
			$Model/shapes/corner_base.show()
			$Model/shapes/corner_flare.show()


func RotateHorizontal(amount):
	rotate_y(amount)


func RotateVertical(amount):
	rotate_x(amount)


func NextType():
	if $Model/shapes/corner_base.visible:
		$Model/shapes/corner_base.visible = false
		$Model/shapes/corner_flare.visible = false
		$Model/shapes/cube_base.visible = true
		$Model/shapes/cube_flare.visible = true
	elif $Model/shapes/cube_base.visible:
		$Model/shapes/cube_base.visible = false
		$Model/shapes/cube_flare.visible = false
		$Model/shapes/wedge_base.visible = true
		$Model/shapes/wedge_flare.visible = true
	else:
		$Model/shapes/wedge_base.visible = false
		$Model/shapes/wedge_flare.visible = false
		$Model/shapes/corner_base.visible = true
		$Model/shapes/corner_flare.visible = true
	

