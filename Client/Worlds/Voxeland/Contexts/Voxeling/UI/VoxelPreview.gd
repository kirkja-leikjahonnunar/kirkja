extends Control

@onready var voxel: Node3D = $SubViewportContainer/SubViewport/VoxelPreview3D/Voxel


func UpdateCompass(orientation: Vector3):
	voxel.rotation = orientation


func SwapMesh(node: Node3D):
	pass
