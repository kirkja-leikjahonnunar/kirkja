extends PlayerController
class_name Voxeling

const VOXEL : PackedScene = preload("res://Worlds/Voxeland/VoxelVillage/Voxel/Voxel.tscn")
const voxel_size = .1

@onready var hang_detector : RayCast3D = $PlayerMesh/HangDetector
#@onready var tool_ui = preload("res://Worlds/Voxeland/Contexts/Voxeling/UI/VoxelingUI.tscn").instantiate()
@onready var VOXELING_UI = $VoxelingUI


enum InputModes { Wizard, Run, Sample }


var voxel_world : VoxelVillage

var current_voxel
var last_voxel_type := Voxel.Shapes.CUBE
#var last_voxel_rotation : Basis
var last_voxel_rotation : Vector3
var last_voxel_material : Material
var last_voxel_color : int = -1
var last_voxel_rgb : Color

var last_position : Vector3

var palette := [
				Color("#ff0000"),
				Color("#ffff00"),
				Color("#00ff00"),
				Color("#00ffff"),
				Color("#0000ff"),
				Color("#ff00ff"),
				Color("#ffffff"),
				Color("#000000")
				]


var input_mode := InputModes.Run
var last_input_mode = InputModes.Run

enum ToolModes { Create, Color, Shape, Rotate }
var tool_mode := ToolModes.Create
var is_sampling := false # whether we are trying to sample a voxel setting


func UpdateCompass():
	VOXELING_UI.UpdateCompass(Vector3(-$CameraRig.GetPitch(), -$CameraRig.GetYaw(), 0))




#-------------------------------------------------------------------------------------------
#--------------------------------------- main ----------------------------------------------
#-------------------------------------------------------------------------------------------

func _ready():
	super._ready()
	print ("Voxeling _ready()")
	
	click_captures_mouse = false # Overrides default PlayerController behavior
	
	wizard_ready()
	last_position = position
	

#	tool_ui.tool_selected.connect(ToolSelectedFromUI)
#	get_tree().root.call_deferred("add_child", tool_ui)


func _input(event):
	if not active: return
	
	if input_mode == InputModes.Wizard:
		wizard_input(event)
	
	if input_mode == InputModes.Sample:
		if event is InputEventMouseMotion:
			need_to_update_cast = true
	
	super._input(event)


func _process(delta):
	UpdateCompass()


func InitVoxelRealm():
	var pnt = get_parent()
	while pnt != null:
		if pnt is VoxelVillage:
			voxel_world = pnt
			break
		pnt = pnt.get_parent()


func SpawnVoxel():
	SpawnVoxelAt(global_position + Vector3(0,.05, 0), true)


func SpawnVoxelAt(pos: Vector3, use_self: bool):
	if voxel_world == null: InitVoxelRealm()
	if voxel_world == null:
		push_error("Trying to add voxel, but no voxel world, this shouldn't happen?")
		return
	
	print("Adding voxel at ", pos)
	var voxel = VOXEL.instantiate()
	voxel.position = pos
	voxel_world.AddVoxel(self if use_self else null, voxel)
	voxel.SwapShape(last_voxel_type) # this needs to happen AFTER voxel is inserted into tree because of setters!!!! arrrg!!
	if last_voxel_color < 0: last_voxel_color = 0
	voxel.SetColor(palette[last_voxel_color])
	voxel.get_node("Model").rotation = last_voxel_rotation
	voxel.target_rotation = last_voxel_rotation
	voxel.target_basis = Basis(Quaternion(last_voxel_rotation))
	SetCurrentVoxel(voxel)


func SetCurrentVoxel(voxel):
	if current_voxel == voxel: return
	
	print ("Set current voxel: ", voxel.name if voxel != null else "null")
	current_voxel = voxel
	if voxel == null:
		$ActiveBlock/CubeCage.visible = false
	else:
		$ActiveBlock/CubeCage.global_transform = current_voxel.global_transform
		$ActiveBlock/CubeCage.visible = true


var need_to_jump := false
func Jump():
	#OLD: velocity.y = JUMP_VELOCITY
	need_to_jump = true


# Helper function called during _physics_process()
func HandleMovement(delta: float):
	if (input_mode == InputModes.Wizard || input_mode == InputModes.Sample) and need_to_update_cast:
		CastFromCamera()
		need_to_update_cast = false
	
	#print ("Hanging: ", hanging,"  looking for hang: ", looking_for_hang)
	if hanging:
		HandleMovementHanging(delta)
		return
	
	
	var target_velocity : Vector3
	var just_jumped: bool = false
	
	if not char_body.is_on_floor():
		#target_velocity -= (gravity * delta * 10) * up_direction
		char_body.velocity -= GRAVITY_MULTIPLIER * gravity * delta * char_body.up_direction
	else: #on floor
		# Handle Jump.
		if Input.is_action_just_pressed("char_jump") || need_to_jump:
			need_to_jump = false
			just_jumped = true
			# replace up velocity with jump velocity.. old should be 0 since on floor
			char_body.velocity = char_body.velocity - char_body.velocity.dot(char_body.up_direction) * char_body.up_direction + JUMP_VELOCITY * char_body.up_direction
			#target_velocity = JUMP_VELOCITY * 10 * up_direction
		else:
			# add a little downward to help stick to weird surfaces
			target_velocity = -char_body.up_direction
	
	# do input handling for camera rig
	#if camera_rig: camera_rig.custom_physics_process(delta)
#	
	# Get the input direction
	var input_dir = -Input.get_vector("char_strafe_left", "char_strafe_right", "char_forward", "char_backward")
	
	# special intercept for Left+Right to move player forward.... 
	input_dir = ModifyInputDirection(input_dir, delta)
	
	var speed = input_dir.length()
	var player_dir = camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y) # now in Player space
	#print (player_dir)
	var direction = (char_body.transform.basis * player_dir).normalized() # now in parent space
	
	if not looking_for_hang:
		var vertical_mv : float = direction.dot(up_direction)
		if vertical_mv < 0 && not $FallDetector.is_colliding():
			looking_for_hang = true
	
	var sprinting : bool = Input.is_action_pressed("char_sprint")
	speed = speed * (SPRINT_SPEED if sprinting else SPEED)
	SetCharTilt(player_dir * speed / SPEED)
	
	# Animation syncing
	SetSpeed(input_dir.length() * (2.0 if sprinting else 1.0) - 1.0)
	
	
	if direction:
		target_velocity += direction * speed
	else: # damp toward 0
		pass
	
	var vertical_v = (char_body.velocity.dot(char_body.up_direction)) * char_body.up_direction
	char_body.velocity = vertical_v + target_velocity.lerp(char_body.velocity - vertical_v, .1) #note: velocity can't move_toward like a normal vector3
	char_body.move_and_slide()
	
	UpdateHangDetector()
	
	if looking_for_hang:
		if char_body.is_on_floor():
			looking_for_hang = false
		else:
			if hang_detector.is_colliding():
				looking_for_hang = false
				StartToHang(hang_detector.get_collider())
	
	if just_jumped:
		if ! char_body.is_on_floor():
			if last_on_floor: # we jumped while on the floor
				JumpStart()
			else: #jumped while not on floor, just make sure we are falling?
				Falling()
	else: # not just jumped
		if last_on_floor && not char_body.is_on_floor(): # we probably walked off something
			Falling()
		elif not last_on_floor && char_body.is_on_floor(): # landed somewhere
			JumpEnd()
	
	last_on_floor = char_body.is_on_floor() # cache to help select proper animation when transitioning
	
	if char_body.global_transform.origin.y < world_min_height/2.0:
		char_body.position = spawn_position
	
	# # network sync
	# DefinePlayerState()

func UpdateHangDetector():
	var v = position - last_position
	if v.length() > 1e-5:
		## set detector based on actual movement
		v = (hang_detector.global_transform.basis.inverse() * get_parent().global_transform.basis * v).normalized()
		v = Vector3(0, v.y, -.5)
		hang_detector.target_position = voxel_size * v.normalized()
		#print ("Hang dir: ", v)
	last_position = position
	
	if input_mode == InputModes.Run && not hanging && hang_detector.is_colliding():
		SetCurrentVoxel(hang_detector.get_collider())

# Helper function for running around mode, used during _physics_process()
func HandleActions():
	super.HandleActions()
	
	if Input.is_action_just_pressed("voxel_sample"):
		SwitchInputMode(InputModes.Sample)
	elif Input.is_action_just_released("voxel_sample"):
		SwitchInputMode(last_input_mode)
	
	if Input.is_action_just_released("Save"):
		if voxel_world == null: InitVoxelRealm()
		#voxel_world.SaveLandscape()
		voxel_world.InitiateSave()
	
	if Input.is_action_just_released("Load"):
		if voxel_world == null: InitVoxelRealm()
		voxel_world.InitiateLoad()
		#voxel_world.LoadLandscape()
	
	if Input.is_action_just_released("tool1"): SwitchToolMode(ToolModes.Create)
	if Input.is_action_just_released("tool2"): SwitchToolMode(ToolModes.Rotate)
	if Input.is_action_just_released("tool3"): SwitchToolMode(ToolModes.Shape)
	if Input.is_action_just_released("tool4"): SwitchToolMode(ToolModes.Color)
	
	if input_mode == InputModes.Wizard && hovered_object == null:
		return
	
	if input_mode == InputModes.Run:
		hovered_object = current_voxel
		if current_voxel == null:
			if tool_mode == ToolModes.Create && CurrentActionValid("voxeling_add_voxel"):
				SpawnVoxel()
			return
	
	match tool_mode:
		ToolModes.Create:
			#print ("create, add_voxel: ", CurrentActionValid("voxeling_add_voxel"))
			if CurrentActionValid("voxeling_add_voxel"):
				if input_mode == InputModes.Wizard:
					SpawnVoxelAt($Indicator/Potential.global_position, false)
					need_to_update_cast = true
				else:
					SpawnVoxel()
			elif CurrentActionValid("voxeling_eraser_mode"):
				hovered_object.call_deferred("SelfDestruct")
				if hovered_object == current_voxel:
					SetCurrentVoxel(null)
				hovered_object = null
				call_deferred("NeedToCast") # we must defer since collider is still in physics engine(?)
		ToolModes.Color:
			SetCurrentVoxel(hovered_object)
			
			if CurrentActionValid("voxeling_add_voxel"):
				if last_voxel_color < 0 || last_voxel_color >= palette.size():
					last_voxel_color = 0
				current_voxel.SetColor(palette[last_voxel_color])
			elif CurrentActionValid("voxeling_eraser_mode"):
				last_voxel_color = (last_voxel_color + 1) % palette.size()
				current_voxel.SetColor(palette[last_voxel_color])
		ToolModes.Shape:
			SetCurrentVoxel(hovered_object)
			if CurrentActionValid("voxeling_add_voxel") || CurrentActionValid("voxeling_eraser_mode"):
				last_voxel_type = current_voxel.NextType()
		ToolModes.Rotate:
			SetCurrentVoxel(hovered_object)
			if CurrentActionValid("voxeling_add_voxel"):
				last_voxel_rotation = current_voxel.RotateAroundY(PI/2)
			elif CurrentActionValid("voxeling_eraser_mode"):
				var axis = GetCameraDirection(current_voxel, hovered_point, true)
				match axis:
					Voxel.Dir.x_plus:  current_voxel.RotateAroundZ(PI/2)
					Voxel.Dir.x_minus: current_voxel.RotateAroundZ(-PI/2)
					Voxel.Dir.y_plus:  current_voxel.RotateAroundY(PI/2)
					Voxel.Dir.y_minus: current_voxel.RotateAroundY(-PI/2)
					Voxel.Dir.z_plus:  current_voxel.RotateAroundX(PI/2)
					Voxel.Dir.z_minus: current_voxel.RotateAroundX(-PI/2)


# Overrides PlayerController, swap between wizard mode and run around mode.
func HandleToggleMouse(on):
	print ("Voxeling.HandleToggleMouse: ", on)
	
	if on:
		input_mode = InputModes.Wizard
		need_to_update_cast = true
		SwitchToolMode(tool_mode)
	else:
		input_mode = InputModes.Run
		$Indicator/Potential.visible = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	SetMouseVisible(on)




# the collider underneath player
func _on_drill_body_entered(body):
	if input_mode != InputModes.Run: return
	
	if Input.is_action_pressed("voxeling_eraser_mode"):
		if not is_on_floor():
			if body is Voxel:
				Jump()
				body.call_deferred("SelfDestruct")
				if body == hovered_object:
					hovered_object = null


# Colliders left, right, forward, back from player
func _on_bump_body_entered(body):
	if input_mode != InputModes.Run: return
	
	print ("bump entered ", body.name, ", ", body.get_parent().name)
	if Input.is_action_pressed("voxeling_eraser_mode"):
		if body is Voxel:
			print ("destroy block ")
			body.call_deferred("SelfDestruct")
			if body == hovered_object:
					hovered_object = null
#	else:
#		if looking_for_hang:
#			if not $FallDetector.is_colliding():
#				print ("HANG on ", body.name)
#				StartToHang(body)
#				looking_for_hang = false


#-------------------------------------------------------------------------------------------
#---------------------------------- UI Coordination ----------------------------------------
#-------------------------------------------------------------------------------------------

# UI Callback
func ToolSelectedFromUI(tool):
	match tool:
		"CREATE":
			SwitchToolMode(ToolModes.Create)
		"ROTATE":
			SwitchToolMode(ToolModes.Rotate)
		"COLOR":
			SwitchToolMode(ToolModes.Shape)
		"SHAPE":
			SwitchToolMode(ToolModes.Color)


func SyncShortcutsWithUI():
	push_error ("IMPLEMENT ME")


#-------------------------------------------------------------------------------------------
#-------------------------------- Hanging Controller ---------------------------------------
#-------------------------------------------------------------------------------------------

var hanging := false
var looking_for_hang := false
var last_hang : Voxel
var last_hang_side : int
var hang_lerping : bool
var hanging_tween : Tween

func StartToHang(on_this: Voxel):
	last_hang = on_this
	hanging = true
	last_hang_side = on_this.NearestSide(global_position)
	var v_size = on_this.shape_list.voxel_size
	var hang_point = on_this.to_global(Vector3(0,-v_size/2,0) + v_size * DirVector(last_hang_side))
	
	hang_lerping = true
	hanging_tween = get_tree().create_tween()
	hanging_tween.tween_property(self, "global_position", hang_point, .25).finished.connect(FinishHangLerp)

func FinishHangLerp():
	hang_lerping = false


func HandleMovementHanging(_delta: float):
	if hang_lerping: return
	
	if Input.is_action_just_pressed("char_jump"):
		hanging = false
		#looking_for_hang = true
		return
	
	
	# Get the input direction
	var input_dir = -Input.get_vector("char_strafe_left", "char_strafe_right", "char_forward", "char_backward")
	
	var speed = input_dir.length()
	
#	var player_dir = camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y) # now in player space
#	var direction = (char_body.transform.basis * player_dir).normalized() # now in player parent space
	var player_dir = input_dir.x * GameGlobals.main_camera.global_transform.basis.x
	
	if last_hang_side == Voxel.Dir.z_minus: # we are hanging onto a ceiling
		player_dir += input_dir.y * (GameGlobals.main_camera.global_transform.basis * up_direction)
	else:
		player_dir += input_dir.y * (char_body.global_transform.basis * up_direction)
	
	player_dir = voxel_size * (char_body.get_parent().global_transform.basis.inverse() * player_dir).normalized()



#-------------------------------------------------------------------------------------------
#-------------------------- Wizard mode (mouse controller) ---------------------------------
#-------------------------------------------------------------------------------------------

var voxel_camera : Camera3D
var hovered_object
var hovered_point : Vector3
var hovered_side = VoxelBlock.Dir.None
var need_to_update_cast := true

#@export_group("Wizard Mode")
@export_flags_3d_physics var block_collision_mask := 0


func wizard_ready():
	voxel_camera = GameGlobals.main_camera
	$Indicator/Potential.visible = false
	
	# cache some things so we can force an override of an action on certain mouse activity
	InitActionOverrideTest("voxeling_add_voxel")
	InitActionOverrideTest("voxeling_eraser_mode")
	print ("action_binds: ", action_override_binds)


func wizard_input(event):
	if input_mode != InputModes.Wizard: return
	
	if event is InputEventMouseMotion:
		#print ("at wizard_input, will cast")
		need_to_update_cast = true
		
#	elif event is InputEventMouseButton:
#		if event.pressed:
#			if event.button_index == MOUSE_BUTTON_LEFT:
#				override_left_up = false
#			elif event.button_index == MOUSE_BUTTON_RIGHT:
#				override_right_up = false


# Helper deferred function so that physics collision info gets updated before we 
# try to cast again after adding or removing things.
func NeedToCast():
	need_to_update_cast = true


func SwitchInputMode(mode):
	if mode == InputModes.Sample:
		if input_mode != InputModes.Sample:
			last_input_mode = input_mode
	input_mode = mode
	

# Update state about current wizard tool mode.
func SwitchToolMode(mode):
	tool_mode = mode
	VOXELING_UI.SelectToolById(ToolModes.keys()[mode])
	match tool_mode:
		ToolModes.Create: Input.set_default_cursor_shape(Input.CursorShape.CURSOR_POINTING_HAND)
		ToolModes.Color:  Input.set_default_cursor_shape(Input.CursorShape.CURSOR_BUSY)
		ToolModes.Shape:  Input.set_default_cursor_shape(Input.CursorShape.CURSOR_DRAG)
		ToolModes.Rotate: Input.set_default_cursor_shape(Input.CursorShape.CURSOR_WAIT)
		#CURSOR_BUSY CURSOR_DRAG


# Update object mouse is hovering over.
func CastFromCamera():
	#print ("recasting")
	var projected: Vector3 = voxel_camera.project_position(get_viewport().get_mouse_position(), 10.0)
	
	var direct_space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = voxel_camera.global_transform.origin
	params.to = projected
	params.collide_with_areas = false
	params.collide_with_bodies = true
	#params.collision_mask = get_layer_from_name("ContextBit1")
	params.collision_mask = block_collision_mask
	var collision = direct_space.intersect_ray(params)
	var hover = null
	var point := Vector3()
	
	if collision:
		#print (collision)
		var vblock = collision.collider #.get_parent()
		if vblock.is_in_group("VoxelBlock"):
			hover = vblock
			point = collision.position
	else:
		#print ("no collision")
		hover = null
		
	if hover != hovered_object:
		hovered_object = hover
	
	if hover != null:
		hovered_side = hover.NearestSide(point)
		hovered_point = point
		
		# update potential block position
		var normal = DirVector(hovered_side)
		#var ppos = hover.get_parent().to_global(hover.position + .1 * normal)
		var ppos = hover.to_global(voxel_size * .55 * normal)
		var cbas = hover.global_transform.basis * BasisFromYVector(normal)
#		print ("hovered lpos: ", hover.position, 
#				", wpos: ", hover.global_transform.origin, 
#				", diff: ", DirVector(hovered_side), 
#				", ppos: ", ppos)
		
		$Indicator/Potential.visible = true
		$Indicator/Potential.global_transform.origin = ppos
		$Indicator/Potential.global_transform.basis = cbas #hover.global_transform.basis
	else:
		$Indicator/Potential.visible = false
	
	if input_mode == InputModes.Sample && hovered_object != null:
		last_voxel_rgb = hovered_object.base_color
		last_voxel_color = FindNearestPalette(last_voxel_rgb)
		$PlayerMesh/voxeling/ctrl_rig/Skeleton3D/skin.get_surface_override_material(0).albedo_color = palette[last_voxel_color]
		last_voxel_type = hovered_object.shape
		last_voxel_rotation = hovered_object.target_rotation
		print ("new sample: ", last_voxel_color, "==", last_voxel_rgb," ", Voxel.Shapes.keys()[last_voxel_type], " ", last_voxel_rotation)
		VOXELING_UI.SwapVoxel(last_voxel_rgb, last_voxel_color, last_voxel_type, last_voxel_rotation)

# Return a direction vector corresponding to the direction enum.
func DirVector(dir) -> Vector3:
	match dir:
		Voxel.Dir.None: return Vector3()
		Voxel.Dir.x_plus: return Vector3(1,0,0)
		Voxel.Dir.x_minus: return Vector3(-1,0,0)
		Voxel.Dir.y_plus: return Vector3(0,1,0)
		Voxel.Dir.y_minus: return Vector3(0,-1,0)
		Voxel.Dir.z_plus: return Vector3(0,0,1)
		Voxel.Dir.z_minus: return Vector3(0,0,-1)
	return Vector3()


# Using this y, return an otherwise random orthonormal Basis with the given y direction.
func BasisFromYVector(y: Vector3) -> Basis:
	y = y.normalized()
	var x = Vector3(1,0,0)
	if abs(y.dot(x))>.9: x = Vector3(0,1,0)
	var z = x.cross(y)
	x = y.cross(z)
	
	return Basis(x,y,z)

func GetCameraDirection(voxel: Node3D, point: Vector3, ignore_y: bool) -> int:
	var cam_ray = (voxel.get_parent().to_local(point) - voxel.get_parent().to_local(voxel_camera.global_position)).normalized()
	
	var closest := Voxel.Dir.None
	var dist : float = abs(cam_ray.x)
	closest = Voxel.Dir.x_plus
	if -cam_ray.x > dist:
		dist = -cam_ray.x
		closest = Voxel.Dir.x_minus
	if not ignore_y:
		if cam_ray.y > dist:
			closest = Voxel.Dir.y_plus
			dist = cam_ray.y
		if -cam_ray.y > dist:
			closest = Voxel.Dir.y_minus
			dist = -cam_ray.y
	if cam_ray.z > dist:
		closest = Voxel.Dir.z_plus
		dist = cam_ray.z
	if -cam_ray.z > dist:
		closest = Voxel.Dir.z_minus
		dist = -cam_ray.z
	print ("found camera direction: ", Voxel.Dir.keys()[closest])
	return closest


func FindNearestPalette(color : Color) -> int:
	var closest_i := -1
	var d := 10000.0
	for i in range(palette.size()):
		var dd : float = Vector4(color.r - palette[i].r, color.g - palette[i].g, color.b - palette[i].b, color.a - palette[i].a).length()
		if dd < d:
			d = dd
			closest_i = i
	return closest_i

