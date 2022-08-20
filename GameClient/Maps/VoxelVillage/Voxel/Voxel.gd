@tool # @tool needs to be above the enum.
extends StaticBody3D
class_name Voxel

#@onready var BASE = preload("res://Maps/VoxelVillage/Voxel/assets/base.material")
#@onready var FLARE = preload("res://Maps/VoxelVillage/Voxel/assets/flare.material")


# Note: these need to be in same order as mesh_list.
enum Shapes # enum needs to be before using it in @export.
{
	CUBE,
	WEDGE,
	CORNER,
	VALLEY
}

@export var base_color : Color = Color("999666"):
	set(value):
		print ("-----------")
		print ("Voxel.base_color setter = ", value, "  ready_done: ", ready_done, "  in tree: ", is_inside_tree())
		base_color = value
		
		if !is_inside_tree(): return
		
		if Engine.is_editor_hint():
			InitMats(false)
		
		if not has_node("Model/shape_base"):
			print ("no Model/shape_base, skip base_color setter")
			return
		
		print ("baseo: ", $Model/shape_base.get_surface_override_material(0), ", basemo: ", $Model/shape_base.material_override)
		print ("flareo: ", $Model/shape_flare.get_surface_override_material(0), ", flaremo: ", $Model/shape_flare.material_override)
		
		var mesh_base = $Model/shape_base
		var mesh_flare = $Model/shape_flare
		var mat_base = $Model/shape_base.get_surface_override_material(0)
		var mat_flare = $Model/shape_flare.get_surface_override_material(0)
		
		if mat_base == mat_flare:
			print ("ARRR! mat_base == mat_flare! BASE: ", BASE, "  FLARE: ", FLARE)
			mat_base = BASE
			mesh_base.set_surface_override_material(0, mat_base)
			mat_flare = FLARE
			mesh_flare.set_surface_override_material(0, mat_flare)
		
		if mat_base == null:
			print ("surface override was null, setting base to ", BASE)
			mat_base = BASE
			mesh_base.set_surface_override_material(0, mat_base)
		#else:
		mat_base.albedo_color = base_color
		mesh_base.material_override = mat_base #TODO: THIS IS A HACK!!! the set_surface_override_material doesn't seem to work at runtime
		print ("base get_surface_override: ", mesh_base.get_surface_override_material(0))
		
		if mat_flare == null:
			print ("surface override was null, setting flare to ", FLARE)
			mat_flare = FLARE
			mesh_flare.set_surface_override_material(0, mat_flare)
		#else:
		mat_flare.albedo_color = base_color * 0.60
		mesh_flare.material_override = mat_flare
		print ("flare get_surface_override ", mesh_flare.get_surface_override_material(0))
		
		print ("BASE: ", BASE, ", basemat: ", mat_base, ", baseo: ", $Model/shape_base.get_surface_override_material(0), ", basemo: ", $Model/shape_base.material_override)
		print ("FLARE: ", FLARE, ", flaremat: ", mat_flare, ", flareo: ", $Model/shape_flare.get_surface_override_material(0), ", flaremo: ", $Model/shape_flare.material_override)
		

func SetColor(color : Color):
	base_color = color


@export var shape : Shapes = Shapes.CUBE:
	set(value):
		print ("Voxel.shape setter: ", value, " = ", Shapes.keys()[value])
		shape = value
		
		if !is_inside_tree(): return # we rely on SetInitial() to properly initialize after _ready()
		
		$Model/shape_base.mesh = mesh_list[value*2]
		$Model/shape_flare.mesh = mesh_list[value*2+1]


@export var BASE : Material
@export var FLARE : Material

#TODO: this could be simplified by having single mesh with two surfaces
# Note: these need to be in same order as Shapes enum.
@export var mesh_list : Array[Mesh]

#const const_mesh_list = [
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_cube_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_cube_flare.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_wedge_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_wedge_flare.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_corner_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_corner_flare.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_valley_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_valley_flare.res")
#]


#------------------------------- Main --------------------------------------

# we cache this, since the actual basis will be flipping around a lot
var target_rotation : Basis
#var target_shape


# Hack to try to reduce editor errors
func InitMats(force : bool):
	if BASE == null || force:
		print ("BASE material was null, loading")
		BASE = load("res://Maps/VoxelVillage/Voxel/assets/base.material")
	if FLARE == null || force:
		print ("FLARE material was null, loading")
		FLARE = load("res://Maps/VoxelVillage/Voxel/assets/flare.material")


var ready_done := false
func _ready():
	target_rotation = basis
	
	if BASE == FLARE:
		print ("voxel_ready AAAAAAAA BASE: ", BASE, ", FLARE: ", FLARE)
		InitMats(true)
	else: print ("voxel_ready diff BASE: ", BASE, ", FLARE: ", FLARE)
	
	ready_done = true
	
	call_deferred("SetInitial")

func SetInitial():
	print ("voxel ready deferred")
	print ("    BASE: ", BASE, ", FLARE: ", FLARE)
	base_color = base_color # these have setters, and in Godot 4 unlike 3, script usage triggers setters
	shape = shape


#----------------------- Interface -----------------------------



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
	shape = new_shape
	return new_shape


func NextType() -> int:
	var new_shape = 0
	for i in range(0, mesh_list.size(), 2):
		if $Model/shape_base.mesh == mesh_list[i]:
			new_shape = ((i+2) % mesh_list.size()) / 2
			break
	
	shape = new_shape
	#SwapShape(new_shape)
	return new_shape


