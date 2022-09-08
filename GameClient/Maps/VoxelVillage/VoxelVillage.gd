extends Node3D
class_name VoxelVillage


const VOXEL : PackedScene = preload("res://Maps/VoxelVillage/Voxel/Voxel.tscn")

@export var save_path : String = "user://voxels/"
@export var current_save_file : String = "voxels0.vox"


# Note: these need to be in same order as Voxel.Shapes enum.
@export var base_meshes : Array[Mesh]
@export var flare_meshes : Array[Mesh]
@export var colliders : Array[Shape3D]


#------------------------------------- main --------------------------------------

func _ready():
	$SavePanel.save_pressed.connect(SavePressed)
	$SavePanel.visible = false


# Add voxel based on a character plopping down a block. Results in voxeling moving slightly.
func AddVoxel(voxeling, voxel):
	if voxeling:
		voxeling.position.y += 0.1 # Move the player before spawning a voxel.
	
	# Snap to grid or whatever.
	voxel.position.y = ceil((voxel.position.y - 0.05) * 10) / 10
	voxel.position.x = ceil((voxel.position.x - 0.05) * 10) / 10
	voxel.position.z = ceil((voxel.position.z - 0.05) * 10) / 10
	
	max_number += 1
	voxel.number = max_number
	
	$Landscape.add_child(voxel)


func AddVoxelAtGlobalPos(global_pos: Vector3, voxel: Voxel):
	# Snap to grid or whatever.
	voxel.position = voxel.to_local(global_pos)
	voxel.position.y = ceil((voxel.position.y - 0.05) * 10) / 10
	voxel.position.x = ceil((voxel.position.x - 0.05) * 10) / 10
	voxel.position.z = ceil((voxel.position.z - 0.05) * 10) / 10
	
	$Landscape.add_child(voxel)



func LoadLandscape() -> bool:
	var file_path = save_path + current_save_file
	var file = File.new()
	#if file.open(save_path + filename, File.READ) == OK:
	if file.open(file_path, File.READ) == OK:
		print ("file opened..")
		var json := JSON.new()
		var err = json.parse(file.get_as_text())
		file.close()
		if err == OK:
			var data = json.get_data()
			print ("json data: ", data)
			var voxels = data.voxels
			#voxels.sort_custom(func(a, b): return a.number < b.number)
			for vdata in voxels:
				print ("instantiate voxel:")
				var voxel = VOXEL.instantiate()
				print ("voxel instantiated")
				if vdata.number > max_number:
					max_number = vdata.number
				#vox.position = voxel.pos
				voxel.position = Vector3(vdata.x, vdata.y, vdata.z)
				AddVoxel(null, voxel) #note: increases max_number
				print ("after AddVoxel")
				
				var model = voxel.get_node("Model")
				var q : Quaternion = str_to_var(vdata.rotq)
				model.quaternion = q
				voxel.target_rotation = q.get_euler()
				voxel.target_basis = Basis(q)
				#vox.get_node("Model").rotation = voxel.rot
				#vox.get_node("Model").rotation = Vector3(voxel.rx, voxel.ry, voxel.rz)
				#vox.get_node("Model").rotation = vox.target_rotation
				#vox.target_rotation = str_to_var(voxel.rot)
				#vox.get_node("Model").quaternion 
				#vox.get_node("Model").quaternion = str_to_var(voxel.q)
				
				voxel.number = vdata.number
				voxel.SwapShape(vdata.shape) # this needs to happen AFTER voxel is inserted into tree because of setters!!!! arrrg!!
				#vox.SetColor(voxel.color)
				voxel.SetColor(Color(vdata.r, vdata.g, vdata.b))
				voxel.name = vdata.name
				#print (voxel.name, " basis: ", voxel.basis)
				#print (voxel.name, " basism: ", model.basis)
				#print (voxel.name, " rotation: ", model.rotation)
			
			print ("Loading from ",file_path," complete!")
			return true
		else:
			print ("Error parsing json")
	else:
		print ("Error opening ", file_path)
	return false


# Note, saved data currently will not preserve child tree
func DataifyVoxels(node: Node3D):
	var voxels := []
	for voxel in node.get_children():
		if voxel is Voxel:
			var model = voxel.get_node("Model")
			
			print (voxel.name, ", basism: ", model.basis, " target: ", voxel.target_rotation, " modelrot: ", model.rotation)
			voxels.append({ "x": voxel.position.x,
							"y": voxel.position.y,
							"z": voxel.position.z,
							#"rot": var_to_str(voxel.target_rotation),
							"rotq": var_to_str(Quaternion(voxel.target_rotation)),
							#"q": var_to_str(model.quaternion),
							#"basis": var_to_str(voxel.basis),
							#"basism": var_to_str(model.basis),
							#"basismq": var_to_str(model.quaternion),
							#"rx": model.rotation.x,
							#"ry": model.rotation.y,
							#"rz": model.rotation.z,
							"shape": voxel.shape,
							#"color": voxel.base_color,
							"r": voxel.base_color.r,
							"g": voxel.base_color.g,
							"b": voxel.base_color.b,
							"number": voxel.number,
							"rot_order": voxel.get_node("Model").rotation_order,
							"name": voxel.name
							})
		
		if voxel.get_child_count() > 0:
			var more = DataifyVoxels(voxel)
			voxels.append_array(more)
	return voxels


func SaveLandscape() -> bool:
	#TODO: optimize this, text json really huge
	var voxels := DataifyVoxels($Landscape)
	var data := { "voxels": voxels }
	
	var dir = Directory.new()
	if not dir.dir_exists(save_path):
		if dir.make_dir_recursive(save_path) != OK:
			push_error("Failed to make dir path: ", save_path)
			return false
	
	var file_path = save_path + current_save_file
	
	var file = File.new()
	if file.open(file_path, File.WRITE) == OK:
		var json = JSON.new()
		var jstr := json.stringify(data)
		file.store_string(jstr)
		print ("Saved to ",file_path,"! -> ", file.get_path_absolute())
		file.close()
		return true
	else:
		push_error ("Error saving to ", file_path)
		return false
		


func ResetLandscape():
	push_error("IMPLEMENT ME!")
	pass


#--------------------------------- Helper functions -------------------------------

var max_number := 0
func ScanForMaxNumber():
	for child in $Landscape.get_children():
		if not child is Voxel: continue
		if child.number > max_number:
			max_number = child.number


# Return a list of files (not directories) at the directory path that end with ending.
func GetSlots(path: String, ending: String):
	var dir = Directory.new()
	var elements = []
	
	if dir.open(path) != OK:
		print_debug ("Could not open directory ", path)
		return null
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			print("Found directory: " + file_name)
		else:
			print("Found file: " + file_name)
			if file_name.ends_with(ending):
				elements.appenD(file_name)
		file_name = dir.get_next()
	
	return elements


#----------------------------- Signals / Interface ------------------------------

var old_mouse_capture

func InitiateSave():
	old_mouse_capture = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$SavePanel.visible = true


func SavePressed():
	$SavePanel.visible = false
	Input.set_mouse_mode(old_mouse_capture)
	SaveLandscape()

