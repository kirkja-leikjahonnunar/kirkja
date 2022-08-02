@tool
extends EditorNode3DGizmoPlugin


const CameraPlacementsObj = preload("res://addons/camera_placements/CameraPlacements.gd")
const gizmo_mat = preload("res://addons/camera_placements/gizmo.material")
const gizmo_mat2 = preload("res://addons/camera_placements/gizmocam.material")
#const gizmo_icon = preload("res://addons/camera_placements/camera_icon.png")

var mesh
var cam_mesh

var moving := false
var z_depth := 0.0


func _init():
	print ("Initing EditorNode3DGizmoPlugin")
	create_material("main", Color(1,0,0), false, true)
	create_material("handles", Color(0,1,0))
	# create_icon_material("handle_icon", gizmo_icon, true)  <- only one per node!!
	
	#mesh = QuadMesh.new()
	#mesh.size = Vector2(.5,.5)
	#mesh.surface_set_material(0, gizmo_mat)
	
	cam_mesh = CylinderMesh.new()
	cam_mesh.radial_segments = 4
	cam_mesh.bottom_radius = 0
	cam_mesh.top_radius = .03
	cam_mesh.height = .06
	
	mesh = cam_mesh



func _get_gizmo_name():
	return "CameraPlacements"

func _get_handle_name(gizmo, handle_id, secondary):
	match handle_id:
		0: return "fps"
		1: return "over"
		2: return "right"
		3: return "left"
		4: return "back"

func _has_gizmo(node3d):
	#print ("gizmo node check on ", node3d.name, ": ", node3d is CameraPlacements)
	return node3d is CameraPlacements


func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, restore: Variant, cancel: bool):
	print ("commit handle: ", handle_id, ", secondary: ", secondary,", restore: ", restore, ", cancel: ", cancel)
	moving = false

# This is called during drag of a handle.
func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2):
	print ("set handle ", handle_id, ", secondary: ", secondary, ", screen_pos: ", screen_pos)
	
	var node = gizmo.get_spatial_node()
	var old_pos
	match handle_id:
		0: old_pos = node.proxy_fps
		1: old_pos = node.proxy_over
		2: old_pos = node.proxy_right
		3: old_pos = node.proxy_left
		4: old_pos = node.proxy_back

	#if not moving:
	#	moving = true
	#	z_depth = (node.to_global(old_pos) - camera.global_transform.origin).length()
	#var new_pos = node.to_local(camera.project_position(screen_pos, z_depth))
	#-------
	var new_pos = node.to_local(_intersect_screen_space(camera, screen_pos, node.to_global(old_pos)))
	print ("new pos: ", new_pos)
	
	match handle_id:
		0: node.proxy_fps = new_pos
		1: node.proxy_over = new_pos
		2: node.proxy_right = new_pos
		3: node.proxy_left = new_pos
		4: node.proxy_back = new_pos
	
	_redraw(gizmo)


func _intersect_screen_space(camera: Camera3D, screen_point: Vector2, from_origin_world: Vector3) -> Vector3:
	var from = camera.project_ray_origin(screen_point)
	var dir = camera.project_ray_normal(screen_point)
	
	var camera_basis: Basis = camera.global_transform.basis
	var plane := Plane(from_origin_world, from_origin_world + camera_basis.x, from_origin_world + camera_basis.y)
	
	return plane.intersects_ray(from, dir)


var current_selected
var last_gizmo: EditorNode3DGizmo

func SetCurrentSelected(node):
	current_selected = node
	if last_gizmo: _redraw(last_gizmo)



func _redraw(gizmo: EditorNode3DGizmo):
	print ("gizmo redraw ", Time.get_unix_time_from_system())
	
	last_gizmo = gizmo
	gizmo.clear()
	
	#EditorInterface.get_selection()
	
	var node = gizmo.get_spatial_node()
	if current_selected != node: return
	
	#var lines = PackedVector3Array()
	#lines.append(Vector3(2,2,2))
	#lines.append(Vector3(5,5,5))
	
	#if gizmo._is_handle_highlighted(5, false) or gizmo._is_handle_highlighted(6, false):
	#if gizmo.is_subgizmo_selected(5) or gizmo.is_subgizmo_selected(6):
	#	gizmo.add_lines(lines, get_material("main", gizmo), false, Color(1,1,1))
	#else:
	#	gizmo.add_lines(lines, get_material("main", gizmo), false, Color(0,1,0))
	
	#gizmo.add_mesh(mesh, gizmo_mat, Transform3D(Basis(), Vector3(2,2,2)))
	#gizmo.add_mesh(mesh, gizmo_mat, Transform3D(Basis(), Vector3(5,5,5)))
	
	var handles = PackedVector3Array()
#	for key in node.proxies:
#		handles.append(node.to_global(node.proxies[key]))
#		gizmo.add_mesh(mesh, gizmo_mat, Transform3D(Basis(), node.to_global(node.proxies[key])))
	handles.append(node.to_global(node.proxy_fps))
	handles.append(node.to_global(node.proxy_over))
	handles.append(node.to_global(node.proxy_right))
	handles.append(node.to_global(node.proxy_left))
	handles.append(node.to_global(node.proxy_back))
	
	var bas = Basis().scaled(Vector3(5.05,5.05,5.05)).rotated(Vector3(0,1,0),deg2rad(45)).rotated(Vector3(1,0,0),deg2rad(90))
	gizmo.add_mesh(mesh, gizmo_mat2, Transform3D(bas, node.to_global(node.proxy_fps)))
	gizmo.add_mesh(mesh, gizmo_mat2, Transform3D(bas, node.to_global(node.proxy_over)))
	gizmo.add_mesh(mesh, gizmo_mat2, Transform3D(bas, node.to_global(node.proxy_right)))
	gizmo.add_mesh(mesh, gizmo_mat2, Transform3D(bas, node.to_global(node.proxy_left)))
	gizmo.add_mesh(mesh, gizmo_mat2, Transform3D(bas, node.to_global(node.proxy_back)))
	
	#handles.append(Vector3(2,2,2))
	#handles.append(Vector3(5,5,5))
	gizmo.add_handles(handles, get_material("handles", gizmo), PackedInt32Array())
	
	node.get_viewport()
	
	# draw the gizmo icon for the custom node:
	#gizmo.add_unscaled_billboard(get_material("handle_icon"), .05) #, default_scale: float = 1, modulate: Color = Color(1, 1, 1, 1))
