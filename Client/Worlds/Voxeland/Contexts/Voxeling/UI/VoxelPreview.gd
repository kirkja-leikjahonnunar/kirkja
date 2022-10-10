extends Control

@onready var voxel: Node3D = $SubViewportContainer/SubViewport/VoxelPreview3D/Voxel



func UpdateCompass(orientation: Vector3):
	voxel.rotation = orientation


func SwapVoxel(last_voxel_rgb, last_voxel_color, last_voxel_type, last_voxel_rotation):
	voxel.shape = last_voxel_type
	voxel.SetColor(last_voxel_rgb)
	voxel.SetRotation(last_voxel_rotation)

