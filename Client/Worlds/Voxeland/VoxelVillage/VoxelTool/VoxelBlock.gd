extends MeshInstance3D
class_name VoxelBlock


enum Dir {
	None,
	x_minus,
	x_plus,
	y_minus,
	y_plus,
	z_minus,
	z_plus
}


var index = Vector3i()
var active := false

# links to adjacent:
var x_minus: VoxelBlock
var x_plus: VoxelBlock
var y_minus: VoxelBlock
var y_plus: VoxelBlock
var z_minus: VoxelBlock
var z_plus: VoxelBlock


func is_hidden():
	return x_minus != null && x_plus != null && y_minus != null && y_plus != null && z_minus != null && z_plus != null



func NearestSide(world_point : Vector3):
	var size = $Area3D/CollisionShape3D.shape.extents

	var closest = VoxelBlock.Dir.None
	var dist = 10000.0
	var d

	var point = to_local(world_point)
	#print ("find nearest: world: ", world_point, ", local: ", point)
	
	d = abs(point.x - size.x)
	dist = d
	closest = VoxelBlock.Dir.x_plus

	d = abs(point.x + size.x)
	if d < dist:
		closest = VoxelBlock.Dir.x_minus
		dist = d

	d = abs(point.z - size.z)
	if d < dist:
		closest = VoxelBlock.Dir.z_plus
		dist = d

	d = abs(point.z + size.z)
	if d < dist:
		closest = VoxelBlock.Dir.z_minus
		dist = d

	d = abs(point.y - size.y)
	if d < dist:
		closest = VoxelBlock.Dir.y_plus
		dist = d

	d = abs(point.y + size.y)
	if d < dist:
		closest = VoxelBlock.Dir.y_minus
		dist = d

	return closest

func Terminate():
	queue_free()

