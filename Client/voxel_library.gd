extends Resource
class_name VoxelLibrary

# Note: these need to be in same order as Voxel.Shapes enum.

@export var voxel_size := 0.1

@export var base_meshes : Array[Mesh] = []
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_cube_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_wedge_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_corner_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_valley_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_cap_base.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_slope_base.res"),
#]

@export var flare_meshes : Array[Mesh] = []
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_cube_flare.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_wedge_flare.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_corner_flare.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_valley_flare.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_cap_flare.res"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/shapes_slope_flare.res"),
#]

@export var colliders : Array[Shape3D] = []
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/cube_shape.tres"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/wedge_shape.tres"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/corner_shape.tres"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/valley_shape.tres"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/cap_shape.tres"),
#	preload("res://Maps/VoxelVillage/Voxel/assets/Shapes/slope_shape.tres"),
#]
