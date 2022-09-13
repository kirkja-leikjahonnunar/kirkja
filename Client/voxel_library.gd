extends Resource
class_name VoxelLibrary

# Note: these need to be in same order as Voxel.Shapes enum.

@export var voxel_size := 0.1

@export var base_meshes : Array[Mesh] = []

@export var flare_meshes : Array[Mesh] = []

@export var colliders : Array[Shape3D] = []
