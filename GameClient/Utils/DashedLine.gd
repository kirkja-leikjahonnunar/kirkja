@tool
#class_name DashedLine3D
extends MultiMeshInstance3D


@export var from_point := Vector3():
	set(value):
		from_point = value
		UpdateDash()
@export var to_point := Vector3(1,0,0):
	set(value):
		to_point = value
		UpdateDash()
@export var color := Color(1.0, 1.0, 1.0):
	set(value):
		color = value
		multimesh.mesh.surface_get_material(0).albedo_color = color
@export var dash_length := 0.1:
	set(value):
		dash_length = value
		UpdateDash()
@export var dash_width := 0.05:
	set(value):
		dash_width = value
		UpdateDash()

func SetDash(from: Vector3, to: Vector3):
	from_point = from
	to_point = to
	UpdateDash()

func UpdateDash():
	#print ("Update dash from ", from_point, " to ", to_point)
	var v := to_point - from_point
	var vlen = v.length()
	#if vlen < 1e-8: # zero length point
		
	var num_dashes : int = int(vlen / (dash_length*2))
	if num_dashes > multimesh.instance_count:
		multimesh.instance_count = num_dashes
	multimesh.visible_instance_count = num_dashes
	multimesh.mesh.size = Vector3(dash_length, dash_width, dash_width)
	
	var gap_length : float = (vlen - num_dashes * dash_length) / (num_dashes)
	#print ("len: ", vlen, ", num dash: ", num_dashes, ", dash: ", dash_length, ", gap: ", gap_length)
	
	v = v.normalized()
	var axis = v.cross(Vector3(1,0,0))
	var angle = asin(axis.length());
	var b : Basis
	if abs(angle) > 1e-8:
		b = Basis().rotated(axis.normalized(), -angle)
	else: b = Basis()
	for i in range(num_dashes):
		multimesh.set_instance_transform(i, Transform3D(b, from_point + v*(dash_length/2 + i * (dash_length+gap_length))))


