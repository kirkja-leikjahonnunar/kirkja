@tool # @tool needs to be above the enum.
extends StaticBody3D
class_name Voxel


# Note: these need to be in same order as mesh_list.
enum Shapes # enum needs to be before using it in @export.
{
	CUBE,
	WEDGE,
	CORNER,
	VALLEY,
	CAP,
	SLOPE
}

enum Dir {
	None,
	x_minus,
	x_plus,
	y_minus,
	y_plus,
	z_minus,
	z_plus
}


@export var base_color : Color = Color("999666"):
	set(value):
		#print ("-----------")
		#print ("Voxel.base_color setter = ", value, "  ready_done: ", ready_done, "  in tree: ", is_inside_tree())
		base_color = value
		
		if !is_inside_tree(): return
		
		if Engine.is_editor_hint():
			InitMats(false)
		
		if not has_node("Model/shape_base"):
			#print ("no Model/shape_base, skip base_color setter")
			return
		
		#print ("baseo: ", $Model/shape_base.get_surface_override_material(0), ", basemo: ", $Model/shape_base.material_override)
		#print ("flareo: ", $Model/shape_flare.get_surface_override_material(0), ", flaremo: ", $Model/shape_flare.material_override)
		
		var mesh_base = $Model/shape_base
		var mesh_flare = $Model/shape_flare
		var mat_base = $Model/shape_base.get_surface_override_material(0)
		var mat_flare = $Model/shape_flare.get_surface_override_material(0)
		
		if mat_base == mat_flare: #TODO FIXME *** why does this happen 100% of the time?
			#print ("ARRR! mat_base == mat_flare! BASE: ", BASE, "  FLARE: ", FLARE, ", base: ", mat_base, ", flare: ", mat_flare)
			mat_base = BASE.duplicate()
			mesh_base.set_surface_override_material(0, mat_base)
			mat_flare = FLARE.duplicate()
			mesh_flare.set_surface_override_material(0, mat_flare)
		
		if mat_base == null:
			#print ("surface override was null, setting base to ", BASE)
			mat_base = BASE
			mesh_base.set_surface_override_material(0, mat_base)
		#else:
		mat_base.albedo_color = base_color
		mesh_base.material_override = mat_base #TODO: THIS IS A HACK!!! the set_surface_override_material doesn't seem to work at runtime
		#print ("base get_surface_override: ", mesh_base.get_surface_override_material(0))
		
		if mat_flare == null:
			#print ("surface override was null, setting flare to ", FLARE)
			mat_flare = FLARE
			mesh_flare.set_surface_override_material(0, mat_flare)
		#else:
		mat_flare.albedo_color = base_color * 0.60
		mesh_flare.material_override = mat_flare
		#print ("flare get_surface_override ", mesh_flare.get_surface_override_material(0))
		
		#print ("BASE: ", BASE, ", basemat: ", mat_base, ", baseo: ", $Model/shape_base.get_surface_override_material(0), ", basemo: ", $Model/shape_base.material_override)
		#print ("FLARE: ", FLARE, ", flaremat: ", mat_flare, ", flareo: ", $Model/shape_flare.get_surface_override_material(0), ", flaremo: ", $Model/shape_flare.material_override)


func SetColor(color : Color):
	base_color = color


func SetRotation(new_euler: Vector3):
	target_rotation = new_euler
	target_basis = Basis.from_euler(new_euler)
	$Model.basis = target_basis
	$CollisionShape3D.basis = target_basis


@export var shape : Shapes = Shapes.CUBE:
	set(value):
		#print ("Voxel.shape setter: ", value, " = ", Shapes.keys()[value])
		shape = value
		
		if !is_inside_tree(): return # we rely on SetInitial() to properly initialize after _ready()
		
		$Model/shape_base.mesh  = shape_list.base_meshes[value]
		$Model/shape_flare.mesh = shape_list.flare_meshes[value]
		$CollisionShape3D.shape = shape_list.colliders[value]
		$CollisionShape3D.basis = target_basis


@export var BASE : Material
@export var FLARE : Material

# Note: these need to be in same order as Shapes enum.
@export var shape_list : Resource


#------------------------------- Variables --------------------------------------

# Spawn number that can be used to animatedly spawn areas.
var number: int = -1


#------------------------------- Main --------------------------------------

# we cache this, since the actual basis will be flipping around a lot
@export var target_rotation : Vector3 # Basis
var target_basis : Basis
#var target_quaternion : Quaternion


# Hack to try to reduce editor errors
func InitMats(force : bool):
	if BASE == null || force:
		#print ("BASE material was null, loading")
		BASE = load("res://Worlds/Voxeland/VoxelVillage/Voxel/assets/base.material")
	if FLARE == null || force:
		#print ("FLARE material was null, loading")
		FLARE = load("res://Worlds/Voxeland/VoxelVillage/Voxel/assets/flare.material")


var ready_done := false
func _ready():
	if not Engine.is_editor_hint():
		if basis != Basis():
			$Model.basis = basis * $Model.basis
			#target_basis = basis
			basis = Basis()
	
	#print ("voxel ready")
	#rotation = target_rotation
	target_rotation = $Model.rotation
	target_basis = $Model.basis
	
	add_to_group("VoxelBlock")
	
	if BASE == FLARE: #TODO: Why does this ever happen!?
		#print ("voxel_ready AAAAAAAA BASE: ", BASE, ", FLARE: ", FLARE)
		InitMats(true)
	#else: print ("voxel_ready diff BASE: ", BASE, ", FLARE: ", FLARE)
	
	ready_done = true
	
	call_deferred("SetInitial")

# Used after _ready() to ensure that shape and color are properly initialized.
func SetInitial():
	#print ("voxel ready deferred")
	#print ("    BASE: ", BASE, ", FLARE: ", FLARE)
	base_color = base_color # these have setters, and in Godot 4 unlike 3, script usage triggers setters
	shape = shape
	$CollisionShape3D.basis = target_basis
	#print (name, ", basism: ", $Model.basis)


#---------------------- Information Functions ----------------------------

func NearestSide(world_point : Vector3):
	var size = Vector3(shape_list.voxel_size, shape_list.voxel_size, shape_list.voxel_size)
	#var size = $CollisionShape3D.shape.extents

	var closest = Dir.None
	var dist = 10000.0
	var d

	var point = to_local(world_point)
	#print ("find nearest: world: ", world_point, ", local: ", point)
	
	d = abs(point.x - size.x)
	dist = d
	closest = Dir.x_plus

	d = abs(point.x + size.x)
	if d < dist:
		closest = Dir.x_minus
		dist = d

	d = abs(point.z - size.z)
	if d < dist:
		closest = Dir.z_plus
		dist = d

	d = abs(point.z + size.z)
	if d < dist:
		closest = Dir.z_minus
		dist = d

	d = abs(point.y - size.y)
	if d < dist:
		closest = Dir.y_plus
		dist = d

	d = abs(point.y + size.y)
	if d < dist:
		closest = Dir.y_minus
		dist = d

	return closest


#----------------------- Interface -----------------------------

var main_rot_scale := .8
var off_rot_scale := .5

func RotateAroundY(amount) -> Vector3:
	target_basis = target_basis.rotated(Vector3(0,1,0), amount)
	target_rotation = target_basis.get_euler()
	var tween : Tween = get_tree().create_tween().parallel()
	tween.tween_property($Model, "scale", Vector3(off_rot_scale,main_rot_scale,off_rot_scale), .095)
	tween.tween_method(lerp_quat.bind($Model.basis.get_rotation_quaternion(), target_basis), 0.0, 0.5, 0.075).set_delay(.02)
	
	tween.tween_method(lerp_quat.bind($Model.basis.get_rotation_quaternion(), target_basis), 0.5, 1.0, 0.075).set_delay(.02)
	tween.tween_property($Model, "scale", Vector3(1.0,1.0,1.0), .075).set_delay(.02)
	$CollisionShape3D.basis = target_basis
	return target_basis.get_euler()

func RotateAroundX(amount) -> Vector3:
	target_basis = target_basis.rotated(Vector3(1,0,0), amount)
	target_rotation = target_basis.get_euler()
	var tween : Tween = get_tree().create_tween().parallel()
	tween.tween_property($Model, "scale", Vector3(main_rot_scale,off_rot_scale,off_rot_scale), .095)
	tween.tween_method(lerp_quat.bind($Model.basis.get_rotation_quaternion(), target_basis), 0.0, 0.5, 0.075).set_delay(.02)
	
	tween.tween_method(lerp_quat.bind($Model.basis.get_rotation_quaternion(), target_basis), 0.5, 1.0, 0.075).set_delay(.02)
	tween.tween_property($Model, "scale", Vector3(1.0,1.0,1.0), .075).set_delay(.02)
	$CollisionShape3D.basis = target_basis
	return target_basis.get_euler()

func RotateAroundZ(amount) -> Vector3:
	target_basis = target_basis.rotated(Vector3(0,0,1), amount)
	target_rotation = target_basis.get_euler()
	var tween : Tween = get_tree().create_tween().parallel()
	tween.tween_property($Model, "scale", Vector3(off_rot_scale,off_rot_scale,main_rot_scale), .095)
	tween.tween_method(lerp_quat.bind($Model.basis.get_rotation_quaternion(), target_basis), 0.0, 0.5, 0.075).set_delay(.02)
	
	tween.tween_method(lerp_quat.bind($Model.basis.get_rotation_quaternion(), target_basis), 0.5, 1.0, 0.075).set_delay(.02)
	tween.tween_property($Model, "scale", Vector3(1.0,1.0,1.0), .075).set_delay(.02)
	$CollisionShape3D.basis = target_basis
	return target_basis.get_euler()

# Tweening function to help smooth out rotation lerping across large angles
func lerp_quat(value, start_quat: Quaternion, end_quat: Quaternion):
	$Model.quaternion = start_quat.slerp(end_quat, value)


func SwapShape(new_shape : Shapes) -> int:
	shape = new_shape
	return new_shape


func NextType() -> int:
	var new_shape = 0
	for i in range(0, shape_list.base_meshes.size()):
		if $Model/shape_base.mesh == shape_list.base_meshes[i]:
			new_shape = ((i+1) % shape_list.base_meshes.size())
			break
	
	shape = new_shape
	return new_shape


# Initiate destruction of this block. Block is ultimately freed after some animated destruction.
func SelfDestruct():
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(.0001,.0001,.0001), .095)
	
	queue_free()


