extends RayCast3D

@export var spray_image : Resource
@export var MainCamera : NodePath

@onready var main_camera = get_node(MainCamera) if !MainCamera.is_empty() else null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(is_colliding())
	
	# make sprayer point at position currently gazed at
	if main_camera != null:
		var gaze : RayCast3D = main_camera.get_node("SelectorCast")
		if gaze == null:
			printerr("missing gaze raycaster on main camera")
		else:
			if gaze.is_colliding():
				var hit_point = gaze.get_collision_point()
				var new_tr = AlignTransformY(global_transform.origin, hit_point, global_transform, Vector3(0,1,0))
				global_transform = new_tr
	
	if is_colliding() && Input.is_action_just_pressed("char_use1"):
		#FIXME: this should integrate with player controller input piping
		Spray()


# return a transform with origin at from_point that has its Y axis toward to_point
func AlignTransformY(from_point: Vector3, to_point: Vector3, 
					_trans: Transform3D, up: Vector3) -> Transform3D:
	var new_y := -(to_point - from_point).normalized()
	var new_x := new_y.cross(up)
	var new_z := new_x.cross(new_y)
	return Transform3D(new_x, new_y, new_z, from_point)


func Spray():
	print ("Spray!")
	
	var decal = Decal.new()
	decal.texture_albedo = spray_image
	
	get_tree().root.get_node("TestArea/Environment").add_child(decal)
	
	decal.global_transform.origin = get_collision_point()
	#get_collision_normal() -> must be the y axis
#	decal.global_transform.basis = Basis(global_transform.basis.x,
#										global_transform.basis.y,
#										global_transform.basis.z)
	
	decal.global_transform.basis = global_transform.basis

