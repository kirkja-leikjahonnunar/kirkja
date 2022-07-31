extends Node3D


# Probably where to handle voxel addition.
func AddVoxel(voxel):
	$Voxeling.position.y += 0.1 # Move the player before spawning a voxel.
	voxel.position.y += 0.05 # Raise voxel.
	
	# Snap to grid or whatever.
	voxel.position.x = ceil((voxel.position.x - 0.05) * 10) / 10
	voxel.position.z = ceil((voxel.position.z - 0.05) * 10) / 10
	
	$Landscape.add_child(voxel)


func SaveLandscape():
	pass


func ResetLandscape():
	pass
