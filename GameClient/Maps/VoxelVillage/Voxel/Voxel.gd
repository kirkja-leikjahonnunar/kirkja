@tool # @tool needs to be above the enum.
extends StaticBody3D
class_name Voxel

@onready var BASE = preload("res://Maps/VoxelVillage/Voxel/assets/base.material")
@onready var FLARE = preload("res://Maps/VoxelVillage/Voxel/assets/flare.material")

enum Shapes # enum needs to be before using it in @export.
{
	CUBE,
	WEDGE,
	CORNER,
	VALLEY
}

var target_rotation : Basis
#var target_shape


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
				#print("CUBE")
			Shapes.WEDGE:
				SwapShape(Shapes.WEDGE)
				#print("WEDGE")
			Shapes.CORNER:
				SwapShape(Shapes.CORNER)
				#print("CORNER")
			Shapes.VALLEY:
				SwapShape(Shapes.VALLEY)
			
		print(Shapes.keys()[value])

#@export var texture : Texture2D


func _ready():
	target_rotation = basis


func SetColor(color : Color):
	base_color = color


func RotateHorizontal(amount) -> Basis:
	#rotate_y(amount)
	target_rotation = target_rotation.rotated(Vector3(0,1,0), amount)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "basis", target_rotation, 0.15)
	return target_rotation


func RotateVertical(amount) -> Basis:
	#rotate_x(amount)
	target_rotation = target_rotation.rotated(Vector3(1,0,0), amount)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "basis", target_rotation, 0.15)
	return target_rotation


func SwapShape(new_shape : Shapes) -> int:
	for mesh in $Model/shapes.get_children(true):
		mesh.hide()
	
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
		Shapes.VALLEY:
			$Model/shapes/valley_base.show()
			$Model/shapes/valley_flare.show()
	
	return new_shape


func NextType() -> int:
	if $Model/shapes/cube_base.visible:
		$Model/shapes/cube_base.visible = false
		$Model/shapes/cube_flare.visible = false
		$Model/shapes/wedge_base.visible = true
		$Model/shapes/wedge_flare.visible = true
		return Shapes.WEDGE
	elif $Model/shapes/wedge_base.visible:
		$Model/shapes/wedge_base.visible = false
		$Model/shapes/wedge_flare.visible = false
		$Model/shapes/corner_base.visible = true
		$Model/shapes/corner_flare.visible = true
		return Shapes.CORNER
	elif $Model/shapes/corner_base.visible:
		$Model/shapes/corner_base.visible = false
		$Model/shapes/corner_flare.visible = false
		$Model/shapes/valley_base.visible = true
		$Model/shapes/valley_flare.visible = true
		return Shapes.VALLEY
	else: # was valley
		$Model/shapes/valley_base.visible = false
		$Model/shapes/valley_flare.visible = false
		$Model/shapes/cube_base.visible = true
		$Model/shapes/cube_flare.visible = true
		return Shapes.VALLEY
	

