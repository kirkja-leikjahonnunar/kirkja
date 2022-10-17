extends Node3D
class_name VoxelVillage


const VOXEL : PackedScene = preload("res://Worlds/Voxeland/VoxelVillage/Voxel/Voxel.tscn")

@export var save_path : String = "user://voxels/"
@export var save_extension : String = "vox"

var current_save_file_path : String # this should have save_path inside it, for now we assume we don't change save_path at runtime


# Note: these need to be in same order as Voxel.Shapes enum.
@export var base_meshes : Array[Mesh]
@export var flare_meshes : Array[Mesh]
@export var colliders : Array[Shape3D]

#TODO: this needs to coordinate with Voxeling
@export_flags_3d_physics var block_collision_mask := 0
@export_flags_3d_physics var occupied_mask := 0

#----------------------------------------------------------------------------------
#------------------------------------- main ---------------------------------------
#----------------------------------------------------------------------------------

func _ready():
	$SavePanel.save_pressed.connect(SavePressed)
	$SavePanel.load_pressed.connect(LoadPressed)
	$SavePanel.canceled.connect(SavePanelCanceled)
	$SavePanel.visible = false


func UpdateDebugOverlay():
	if has_node("DebugOverlay"):
		var overlay = get_node("DebugOverlay")
		overlay.Update("hanging", str($Voxeling.hanging))
		overlay.Update("looking_for_hang", str($Voxeling.looking_for_hang))
		overlay.Update("hang_det", str($Voxeling.hang_detector.is_colliding()))

func _process(delta):
	UpdateDebugOverlay()


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
	voxel.position = $Landscape.to_local(global_pos)
	voxel.position.y = ceil((voxel.position.y - 0.05) * 10) / 10
	voxel.position.x = ceil((voxel.position.x - 0.05) * 10) / 10
	voxel.position.z = ceil((voxel.position.z - 0.05) * 10) / 10
	
	$Landscape.add_child(voxel)



func LoadLandscape() -> bool:
	var file_path = current_save_file_path
	var file := FileAccess.open(file_path, FileAccess.READ)
	#if file.open(save_path + filename, File.READ) == OK:
	if file.get_error() == OK:
		print ("file opened..")
		var json := JSON.new()
		var err = json.parse(file.get_as_text())
		file = null #file.close()
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
	
	var dir = DirAccess.open(save_path)
	if dir == null: #not dir.dir_exists(save_path):
		if DirAccess.make_dir_recursive_absolute(save_path) != OK:
			push_error("Failed to make dir path: ", save_path)
			return false
	
	var file_path = current_save_file_path
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file.get_error() == OK:
		var json = JSON.new()
		var jstr := json.stringify(data)
		file.store_string(jstr)
		print ("Saved to ",file_path,"! -> ", file.get_path_absolute())
		file = null #file.close()
		return true
	else:
		push_error ("Error saving to ", file_path)
		return false
		


func ResetLandscape():
	push_error("IMPLEMENT ME!")
	pass


#----------------------------------------------------------------------------------
#--------------------------------- Helper functions -------------------------------
#----------------------------------------------------------------------------------

var max_number := 0
func ScanForMaxNumber():
	for child in $Landscape.get_children():
		if not child is Voxel: continue
		if child.number > max_number:
			max_number = child.number



# This should be called during physics_process to ensure raycasts function properly.
func VoxelAtPositionViaPoint(world_pos: Vector3) -> Voxel:
	var local_pos = $Landscape.to_local(world_pos)
	var space = get_world_3d().direct_space_state
	var params := PhysicsPointQueryParameters3D.new()
	params.position = world_pos
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = block_collision_mask
	var intersect = space.intersect_point(params)
	if intersect.size() > 0:
		#print ("point intersecting with array:" )
		for hit in intersect:
			print ("  ", hit.collider.name)
			if hit.collider != null && hit.collider is Voxel:
				print ("voxel at ", world_pos,": ", hit.collider.name)
				return hit.collider
	
	print ("voxel at ", world_pos,": null")
	return null

# This should be called during physics_process to ensure raycasts function properly.
# This is a raycast hack because intersect_point() doesn't seem to work.
func VoxelAtPosition(world_pos: Vector3) -> Voxel:
	var local_pos = $Landscape.to_local(world_pos)
	var space = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = world_pos + Vector3(.1, 0, 0)
	params.to = world_pos
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = occupied_mask
	params.hit_from_inside = false
	var hit = space.intersect_ray(params)
	if hit.size() != 0:
		if hit.collider != null: 
			print ("voxel at ", world_pos,": ", hit.collider.get_parent().name, " at ", hit.collider.global_position)
			return hit.collider.get_parent()
	
	print ("voxel at ", world_pos,": null")
	return null


func VoxelPositionFromWorldPoint(world_pos: Vector3) -> Vector3:
	var local_pos = $Landscape.to_local(world_pos)
	local_pos.y = ceil((local_pos.y - 0.05) * 10) / 10
	local_pos.x = ceil((local_pos.x - 0.05) * 10) / 10
	local_pos.z = ceil((local_pos.z - 0.05) * 10) / 10
	return local_pos


#----------------------------------------------------------------------------------
#----------------------------- Signals / Interface ------------------------------
#----------------------------------------------------------------------------------

var old_mouse_capture: int

func InitiateSave():
	old_mouse_capture = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$SavePanel.FlushSlots()
	$SavePanel.UpdateSaveSlots(save_path, save_extension)
	$SavePanel.SetForSaving()
	$SavePanel.Activate()

# signal callback when save triggered from SavePanel
func SavePressed(path):
	current_save_file_path = path
	$SavePanel.Deactivate()
	Input.set_mouse_mode(old_mouse_capture)
	SaveLandscape()
	$Voxeling.ShowUI()


func InitiateLoad():
	old_mouse_capture = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$SavePanel.FlushSlots()
	$SavePanel.UpdateSaveSlots(save_path, save_extension)
	$SavePanel.SetForLoading()
	$SavePanel.Activate()

# signal callback when load triggered from SavePanel
func LoadPressed(path):
	current_save_file_path = path
	$SavePanel.Deactivate()
	Input.set_mouse_mode(old_mouse_capture)
	LoadLandscape()
	$Voxeling.ShowUI()


func SavePanelCanceled():
	print ("Save panel canceled")
	$SavePanel.Deactivate()
	Input.set_mouse_mode(old_mouse_capture)
	$Voxeling.ShowUI()


