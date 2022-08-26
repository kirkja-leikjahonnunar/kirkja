extends PlayerController
class_name Voxeling


const VOXEL : PackedScene = preload("res://Maps/VoxelVillage/Voxel/Voxel.tscn")
const voxel_size = .1


var voxel_world

var current_voxel
var last_voxel_type := Voxel.Shapes.CUBE
#var last_voxel_rotation : Basis
var last_voxel_rotation : Vector3
var last_voxel_material : Material
var last_voxel_color : int = -1

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


func _ready():
	super._ready()
	print ("Voxeling _ready()")
	
	click_captures_mouse = false
	
	wizard_ready()
	
	#SPRINT_SPEED = 0.8
	#SPEED = 0.4
	#JUMP_VELOCITY = 2.3


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
	
	var voxel = VOXEL.instantiate()
	voxel.position = pos
	voxel.rotation = last_voxel_rotation
	voxel_world.AddVoxel(self if use_self else null, voxel)
	voxel.SwapShape(last_voxel_type) # this needs to happen AFTER voxel is inserted into tree because of setters!!!! arrrg!!
	if last_voxel_color < 0: last_voxel_color = 0
	voxel.SetColor(palette[last_voxel_color])
	current_voxel = voxel


var need_to_jump := false
func Jump():
	#OLD: velocity.y = JUMP_VELOCITY
	need_to_jump = true


# Helper function called during _physics_process()
func HandleMovement(delta: float):
	if wizard_mode_active and need_to_update_cast:
		CastFromCamera()
		need_to_update_cast = false
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && CurrentActionValid("voxeling_add_voxel"):
		print("Adding voxel.")
		SpawnVoxel()
	
	
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
#	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
#		if input_dir.length() == 0:
#			input_dir.y = 1
#			override_left_up = true
#			override_right_up = true
	
	var speed = input_dir.length()
	var player_dir = camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y) # now in Player space
	#print (player_dir)
	var direction = (char_body.transform.basis * player_dir).normalized() # now in parent space
	
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


# Helper function used during _physics_process()
func HandleActions():
	super.HandleActions()
	
	if wizard_mode_active:
		HandleWizardModeActions()
		return
	
	if current_voxel == null: return
	
	if Input.is_action_just_released("voxel_rotate_left"):
		last_voxel_rotation = current_voxel.RotateAroundY(PI/2)
	
	if Input.is_action_just_released("voxel_rotate_right"):
		last_voxel_rotation = current_voxel.RotateAroundY(-PI/2)
	
	if Input.is_action_just_released("voxel_rotate_up"): #TODO: this should adapt to camera direction? facing forward?
		last_voxel_rotation = current_voxel.RotateAroundX(PI/2)
	
	if Input.is_action_just_released("voxel_rotate_down"):
		last_voxel_rotation = current_voxel.RotateAroundX(-PI/2)
	
	if Input.is_action_just_released("voxel_next_type"):
		last_voxel_type = current_voxel.NextType()
	
	if Input.is_action_just_released("voxel_color"):
		last_voxel_color = (last_voxel_color + 1) % palette.size()
		current_voxel.SetColor(palette[last_voxel_color])


# Overrides PlayerController, swap between wizard mode and run around mode.
func HandleToggleMouse(on):
	print ("Voxeling.HandleToggleMouse: ", on)
	wizard_mode_active = on
	need_to_update_cast = true
	if on:
		SwitchToolMode(wizard_tool_mode)
	else:
		$Indicator/Potential.visible = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	SetMouseVisible(on)


func _input(event):
	if not active: return
	
	if wizard_mode_active:
		wizard_input(event)
	
	super._input(event)


func _on_drill_body_entered(body):
	if wizard_mode_active: return
	
	if Input.is_action_pressed("voxeling_eraser_mode"):
		if not is_on_floor():
			if body is Voxel:
				Jump()
				body.call_deferred("SelfDestruct")
				if body == hovered_object:
					hovered_object = null


func _on_bump_body_entered(body):
	if wizard_mode_active: return
	
	print ("bump entered ", body.name, ", ", body.get_parent().name)
	if Input.is_action_pressed("voxeling_eraser_mode"):
		if body is Voxel:
			print ("destroy block ")
			body.call_deferred("SelfDestruct")
			if body == hovered_object:
					hovered_object = null


#-------------------------------------------------------------------------------------------
#-------------------------- Wizard mode (mouse controller) ---------------------------------
#-------------------------------------------------------------------------------------------

var wizard_mode_active := false

enum ToolModes { AddRemove, SetColor, SetShape, Rotate }
var wizard_tool_mode := ToolModes.AddRemove

var voxel_camera : Camera3D
var hovered_object
var hovered_point
var hovered_side = VoxelBlock.Dir.None
var need_to_update_cast := true

@export var current_object: Node3D
@export_flags_3d_physics var block_collision_mask := 0


func wizard_ready():
	voxel_camera = GameGlobals.main_camera
	$Indicator/Potential.visible = false
	
	# cache some things so we can force an override of an action on certain mouse activity
	InitActionOverrideTest("voxeling_add_voxel")
	InitActionOverrideTest("voxeling_eraser_mode")
	print ("action_binds: ", action_override_binds)


func wizard_input(event):
	if not wizard_mode_active: return
	
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

# This gets called at some point during _physics_process()
func HandleWizardModeActions():
	if Input.is_action_just_released("tool1"): SwitchToolMode(ToolModes.AddRemove)
	if Input.is_action_just_released("tool2"): SwitchToolMode(ToolModes.Rotate)
	if Input.is_action_just_released("tool3"): SwitchToolMode(ToolModes.SetShape)
	if Input.is_action_just_released("tool4"): SwitchToolMode(ToolModes.SetColor)
	
	match wizard_tool_mode:
		ToolModes.AddRemove:
			if CurrentActionValid("voxeling_add_voxel"):
				SpawnVoxelAt($Indicator/Potential.global_position, false)
				need_to_update_cast = true
			elif CurrentActionValid("voxeling_eraser_mode"):
				hovered_object.call_deferred("SelfDestruct")
				hovered_object = null
				call_deferred("NeedToCast") # we must defer since collider is still in physics engine(?)
		ToolModes.SetColor:
			current_voxel = hovered_object
			if CurrentActionValid("voxeling_add_voxel"):
				if last_voxel_color < 0 || last_voxel_color >= palette.size():
					last_voxel_color = 0
				current_voxel.SetColor(palette[last_voxel_color])
			elif CurrentActionValid("voxeling_eraser_mode"):
				last_voxel_color = (last_voxel_color + 1) % palette.size()
				current_voxel.SetColor(palette[last_voxel_color])
		ToolModes.SetShape:
			current_voxel = hovered_object
			if CurrentActionValid("voxeling_add_voxel") || CurrentActionValid("voxeling_eraser_mode"):
				last_voxel_type = current_voxel.NextType()
		ToolModes.Rotate:
			current_voxel = hovered_object
			if CurrentActionValid("voxeling_add_voxel"):
				last_voxel_rotation = current_voxel.RotateAroundY(PI/2)
			elif CurrentActionValid("voxeling_eraser_mode"):
				last_voxel_rotation = current_voxel.RotateAroundX(PI/2)


# Update state about current wizard tool mode.
func SwitchToolMode(mode):
	wizard_tool_mode = mode
	match wizard_tool_mode:
		ToolModes.AddRemove: Input.set_default_cursor_shape(Input.CursorShape.CURSOR_POINTING_HAND)
		ToolModes.SetColor:  Input.set_default_cursor_shape(Input.CursorShape.CURSOR_BUSY)
		ToolModes.SetShape:  Input.set_default_cursor_shape(Input.CursorShape.CURSOR_DRAG)
		ToolModes.Rotate:    Input.set_default_cursor_shape(Input.CursorShape.CURSOR_WAIT)
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
	var point = Vector3()
	
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
