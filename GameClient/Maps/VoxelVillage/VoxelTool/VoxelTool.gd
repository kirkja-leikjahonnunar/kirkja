extends Node3D

# TODO
# - add blocks
#    - when added, need to check ALL adjacent blocks and connect if necessary, OR work from grid
#    - implement bounds update on add
#    - DONE mouse down+up needs to be on same place
# - erase blocks
#   - when removing, must we check for disconnected domains?
# - select color of blocks to add
# - change color of existing blocks (paint)
# - rotate voxel arrangement
#   - ball inside cylinder
#   - lock to axes?
# - save to player inventory?
# - save to map?
# - beveling, marching cubes?



@export var main_camera : Camera3D

#TODO Settings for input controller integration
#var uses_visible_mouse := true
#var has_camera_target := true
#overrides_player_controls


var active := true
var hovered_object
var hovered_point
var hovered_side = VoxelBlock.Dir.None

@export var current_object: Node3D
@export_flags_3d_physics var block_collision_mask

@export var palette : Array[Color]
@export var current_color := 0


func _ready():
	call_deferred("SetCurrentColor", current_color)


# spawn editing at edit_location, and move player to kind of behind, so camera
# view is primarily the voxel object.
func Activate(edit_location, player, camera):
	active = true

func Deactivate():
	active = false
	$RotatorPlatform/PotentialBlock.visible = false


# index is for the palette arary.
func SetCurrentColor(index):
	if index >= 0 && index < palette.size():
		current_color = index
		var mat = $RotatorPlatform/PotentialBlock/Cube.get_surface_override_material(0)
		mat.set_shader_param("albedo", palette[current_color])


func NewVoxelObject():
	return load("res://Maps/VoxelVillage/VoxelTool/Objects/VoxelObject.tscn").instantiate()


func AddBlock():
	if !hovered_object: return
	print ("Add block")
	var side = hovered_object.NearestSide(hovered_point)
	#print (".. to obj: ", hovered_object, ", side: ", side)
	hovered_object.get_parent().AddBlock(hovered_object, side, palette[current_color])
	need_to_update_cast = true

func RemoveBlock():
	if !hovered_object: return
	print ("Remove block")
	hovered_object.get_parent().RemoveBlock(hovered_object)
	$RotatorPlatform/PotentialBlock.visible = false
	hovered_object = null
	#need_to_update_cast = true


var need_to_update_cast := true

func _physics_process(delta):
	if need_to_update_cast:
		CastFromCamera()
		need_to_update_cast = false

func CastFromCamera():
	#print ("recasting)
	var projected: Vector3 = main_camera.project_position(get_viewport().get_mouse_position(), 10.0)
	
	var direct_space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = main_camera.global_transform.origin
	params.to = projected
	params.collide_with_areas = true
	params.collide_with_bodies = false
	#params.collision_mask = get_layer_from_name("ContextBit1")
	params.collision_mask = block_collision_mask
	var collision = direct_space.intersect_ray(params)
	var hover = null
	var point = Vector3()
	if collision:
		#print (collision)
		var vblock = collision.collider.get_parent()
		if vblock.name == "RotatorPlatform":
			#print ("over platform")
			mouse_over_platform = true
		else:
			#if mouse_over_platform: print ("exiting platform")
			mouse_over_platform = false
		if vblock.is_in_group("VoxelBlock"):
			hover = vblock
			point = collision.position
	else:
		hover = null
		mouse_over_platform = false
		
	if hover != hovered_object:
		hovered_object = hover
	
	if hover != null:
		hovered_side = hover.NearestSide(point)
		hovered_point = point
		
		# update potential block position
		var ppos = hover.get_parent().to_global(hover.position + .25 * DirVector(hovered_side))
		print ("hovered lpos: ", hover.position, 
				", wpos: ", hover.global_transform.origin, 
				", diff: ", DirVector(hovered_side), 
				", ppos: ", ppos)
		
		$RotatorPlatform/PotentialBlock.visible = true
		$RotatorPlatform/PotentialBlock.global_transform.origin = ppos
		$RotatorPlatform/PotentialBlock.global_transform.basis = hover.global_transform.basis
	else:
		$RotatorPlatform/PotentialBlock.visible = false


func DirVector(dir) -> Vector3:
	match dir:
		VoxelBlock.Dir.None: return Vector3()
		VoxelBlock.Dir.x_plus: return Vector3(1,0,0)
		VoxelBlock.Dir.x_minus: return Vector3(-1,0,0)
		VoxelBlock.Dir.y_plus: return Vector3(0,1,0)
		VoxelBlock.Dir.y_minus: return Vector3(0,-1,0)
		VoxelBlock.Dir.z_plus: return Vector3(0,0,1)
		VoxelBlock.Dir.z_minus: return Vector3(0,0,-1)
	return Vector3()

#------------- layer name queries
#TODO: put this in utils or something, or better yet this should be a Godot level capability:

var collision_layer_names := []

func InitCollisionLayerLookup():
	collision_layer_names.append("")
	for i in range(1, 21):
		collision_layer_names.append(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(i)))

func get_layer_from_name(layer_name):
	return collision_layer_names.find(layer_name)


var mouse_over_platform := false
var mouse_rotate_down := false
var mouse_down_on
var mouse_down_on_side

func _input(event):
	if mouse_rotate_down:
		if event is InputEventMouseButton:
			if event.pressed == false:
				mouse_rotate_down = false
		elif event is InputEventMouseMotion:
			var angle = event.relative.x * .01
			$RotatorPlatform/RotatorPlatform.rotate_y(angle)
			current_object.rotate_y(angle)
			angle = event.relative.y * .01
			var axis = current_object.global_transform.basis.inverse() * main_camera.global_transform.basis.x
			current_object.rotate_object_local(axis, angle)
	
	if event is InputEventMouseMotion:
		need_to_update_cast = true
	elif event is InputEventMouseButton:
		if event.pressed == false:
			print ("mouse button up, hovered: ", hovered_object)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				SetCurrentColor((current_color + 1) % palette.size())
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				SetCurrentColor((current_color + palette.size() - 1) % palette.size())
			elif mouse_down_on == hovered_object && mouse_down_on_side == hovered_side:
				if event.button_index == MOUSE_BUTTON_LEFT:
					AddBlock()
				elif event.button_index == MOUSE_BUTTON_RIGHT:
					RemoveBlock()
		else: # mouse pressed
			if hovered_object == null:
				mouse_rotate_down = true
			#if mouse_over_platform:
			#	mouse_rotate_down = true
			else:
				mouse_down_on = hovered_object
				if hovered_object: #FIXME: if block goes away, it needs to clear this in tool
					mouse_down_on_side = hovered_object.NearestSide(hovered_point)



#FIXME for some reason, if the area is inside another area, we are
#  not getting these signals, no matter how the collision masks are set:

#func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
#	print ("_on_area_3d_input_event ", event, " ", position)
	#if event is InputEventMouseButton:
	#	mouse_rotate_down = event.pressed


func _on_area_3d_mouse_entered():
	print ("platform area entered")
	mouse_over_platform = true


func _on_area_3d_mouse_exited():
	print ("platform area exited")
	mouse_over_platform = false


