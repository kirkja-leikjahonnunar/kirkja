extends Node3D
class_name VoxelObject

# This class codes for a clump of a small number of voxels, meaning not vast landscapes.


#var blocks := [] # array of VoxelBlock
var palette := [] # limit number of colors?
var min_index := Vector3i()
var max_index := Vector3i()
var size := Vector3() # gets computed on change from max_index - min_index + 1

var block_resource = "res://Worlds/Voxeland/VoxelVillage/VoxelTool/Objects/VoxelBlock.tscn"


# min_index and max_index must be set already
func ComputeSize():
	#if blocks.size() == 0:
	if get_child_count() == 0:
		size = Vector3()
	else:
		size = max_index - min_index + Vector3i(1,1,1)


func GetBlock(index) -> VoxelBlock:
	for block in get_children():
		if block.index == index: return block
	return null


func AddBlock(to_block, dir, color: Color) -> bool:
	var new_block
	if get_child_count() == 0:
		new_block = VoxelBlock.new()
		new_block = load(block_resource).instantiate()
	else:
		var i = to_block.index
		match dir:
			VoxelBlock.Dir.x_plus: i.x += 1
			VoxelBlock.Dir.x_minus: i.x -= 1
			VoxelBlock.Dir.y_plus: i.y += 1
			VoxelBlock.Dir.y_minus: i.y -= 1
			VoxelBlock.Dir.z_plus: i.z += 1
			VoxelBlock.Dir.z_minus: i.z -= 1
		var b = GetBlock(i)
		if b:
			print("Block exists at ", i, ", not adding")
			return false
		new_block = load(block_resource).instantiate()
		new_block.index = i
		var block_size = new_block.get_node("Area3D/CollisionShape3D").shape.size.x
		match dir:
			VoxelBlock.Dir.x_plus:
				to_block.x_plus = new_block
				new_block.x_minus = to_block
				new_block.position = to_block.position + Vector3(block_size,0,0)
			VoxelBlock.Dir.x_minus:
				to_block.x_minus = new_block
				new_block.x_plus = to_block
				new_block.position = to_block.position - Vector3(block_size,0,0)
			VoxelBlock.Dir.y_plus:
				to_block.y_plus = new_block
				new_block.y_minus = to_block
				new_block.position = to_block.position + Vector3(0,block_size,0)
			VoxelBlock.Dir.y_minus:
				to_block.x_minus = new_block
				new_block.x_plus = to_block
				new_block.position = to_block.position - Vector3(0,block_size,0)
			VoxelBlock.Dir.z_plus:
				to_block.z_plus = new_block
				new_block.z_minus = to_block
				new_block.position = to_block.position + Vector3(0,0,block_size)
			VoxelBlock.Dir.z_minus:
				to_block.z_minus = new_block
				new_block.z_plus = to_block
				new_block.position = to_block.position - Vector3(0,0,block_size)
	#blocks.append(new_block)
	var mat = new_block.get_surface_override_material(0)
	mat.albedo_color = color
	add_child(new_block)
	Connect(new_block)
	min_index = min(min_index, new_block.index)
	max_index = max(max_index, new_block.index)
	return true


func Connect(new_block):
	var adjacent = GetBlock(Vector3i(new_block.index.x-1, new_block.index.y, new_block.index.z))
	if adjacent && adjacent.x_plus != new_block:
		adjacent.x_plus = new_block
		new_block.x_minus = adjacent
	adjacent = GetBlock(Vector3i(new_block.index.x+1, new_block.index.y, new_block.index.z))
	if adjacent && adjacent.x_minus != new_block:
		adjacent.x_minus = new_block
		new_block.x_plus = adjacent
	
	adjacent = GetBlock(Vector3i(new_block.index.x, new_block.index.y-1, new_block.index.z))
	if adjacent && adjacent.y_plus != new_block:
		adjacent.y_plus = new_block
		new_block.y_minus = adjacent
	adjacent = GetBlock(Vector3i(new_block.index.x, new_block.index.y+1, new_block.index.z))
	if adjacent && adjacent.y_minus != new_block:
		adjacent.y_minus = new_block
		new_block.y_plus = adjacent
	
	adjacent = GetBlock(Vector3i(new_block.index.x, new_block.index.y, new_block.index.z-1))
	if adjacent && adjacent.z_plus != new_block:
		adjacent.z_plus = new_block
		new_block.z_minus = adjacent
	adjacent = GetBlock(Vector3i(new_block.index.x, new_block.index.y, new_block.index.z+1))
	if adjacent && adjacent.z_minus != new_block:
		adjacent.z_minus = new_block
		new_block.z_plus = adjacent


func RemoveBlock(block: VoxelBlock) -> bool:
	if block.get_parent() != self:
		push_error("RemoveBlock called with block of some other object")
		return false
	if block.x_plus:
		block.x_plus.x_minus = null
		block.x_plus = null
	if block.x_minus:
		block.x_minus.x_plus = null
		block.x_minus = null
	if block.y_plus:
		block.y_plus.y_minus = null
		block.y_plus = null
	if block.y_minus:
		block.y_minus.y_plus = null
		block.y_minus = null
	if block.z_plus:
		block.z_plus.z_minus = null
		block.z_plus = null
	if block.z_minus:
		block.z_minus.z_plus = null
		block.z_minus = null
	block.Terminate()
	return true


#-------------------------- Meshing -------------------------------------------

# Marching cubes?

#TODO:  Make a consolidated mesh
#func Meshify() -> Mesh:
#	push_error("IMPLEMENT ME")
#	return null


#-------------------------- I/O -------------------------------------------

# return a json string 
func Serialize() -> String:
	var data = {}
	data["palette"] = palette
	var bb = []
	for i in range(palette.size()): bb.append([])
	data["blocks"] = bb
	for child in get_children():
		bb.append(child.index)
	var json = JSON.new()
	var jstr := json.stringify(data)
	return jstr

func SetFromString(_data): push_error("IMPLEMENT ME")
