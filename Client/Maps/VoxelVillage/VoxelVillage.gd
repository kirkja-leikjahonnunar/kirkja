extends Node3D
class_name VoxelVillage


const VOXEL : PackedScene = preload("res://Maps/VoxelVillage/Voxel/Voxel.tscn")


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



func LoadLandscape(filename: String):
	var file = File.new()
	if file.open(filename, File.READ) == OK:
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
				var q : Quaternion = str2var(vdata.rotq)
				model.quaternion = q
				voxel.target_rotation = q.get_euler()
				voxel.target_basis = Basis(q)
				#vox.get_node("Model").rotation = voxel.rot
				#vox.get_node("Model").rotation = Vector3(voxel.rx, voxel.ry, voxel.rz)
				#vox.get_node("Model").rotation = vox.target_rotation
				#vox.target_rotation = str2var(voxel.rot)
				#vox.get_node("Model").quaternion 
				#vox.get_node("Model").quaternion = str2var(voxel.q)
				
				voxel.number = vdata.number
				voxel.SwapShape(vdata.shape) # this needs to happen AFTER voxel is inserted into tree because of setters!!!! arrrg!!
				#vox.SetColor(voxel.color)
				voxel.SetColor(Color(vdata.r, vdata.g, vdata.b))
				voxel.name = vdata.name
				print (voxel.name, " basis: ", voxel.basis)
				print (voxel.name, " basism: ", model.basis)
				print (voxel.name, " rotation: ", model.rotation)
		else: print ("Error parsing json")
		print ("Loading from ",filename," complete!")
	else:
		print ("Error opening ", filename)


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
							"rot": var2str(voxel.target_rotation),
							"rotq": var2str(Quaternion(voxel.target_rotation)),
							"q": var2str(model.quaternion),
							"basis": var2str(voxel.basis),
							"basism": var2str(model.basis),
							"basismq": var2str(model.quaternion),
							"rx": model.rotation.x,
							"ry": model.rotation.y,
							"rz": model.rotation.z,
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

func SaveLandscape(filename: String):
	#TODO: optimize this, text json really huge
	var voxels := DataifyVoxels($Landscape)
	var data := { "voxels": voxels }
	
	var file = File.new()
	if file.open(filename, File.WRITE) == OK:
		var json = JSON.new()
		var jstr := json.stringify(data)
		file.store_string(jstr)
		print ("Saved to ",filename,"! -> ", file.get_path_absolute())
		file.close()
	else:
		print ("Error saving to ", filename)


func ResetLandscape():
	push_error("IMPLEMENT ME!")
	pass


var max_number := 0
func ScanForMaxNumber():
	for child in $Landscape.get_children():
		if not child is Voxel: continue
		if child.number > max_number:
			max_number = child.number


