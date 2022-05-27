#
# Mixed third and first person character controller.
#

extends CharacterBody3D
class_name CharacterController


@export var SPEED := 5.0
@export var SPRINT_SPEED := 10.0
@export var ROTATION_SPEED := .03
@export var JUMP_VELOCITY := 8.5
@export var GRAVITY_MULTIPLIER := 2.0

@export var allow_fp : bool = true # allow First Person mode
@export var min_camera_distance := 0.5  # below this, switch to 1st person
@export var max_camera_distance := 5.0  # below this, switch to 1st person
@export var zoom_amount := .2 #amound to zoom each wheel click

@export var mouse_sensitivity := .02
@export var invert_y := false
@export var invert_x := true
@export var allow_mouse_toggle := true

@export var SettingsOverlay : NodePath
@onready var settings_overlay = get_node(SettingsOverlay) if !SettingsOverlay.is_empty() else null


# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# to help smooth out the player movement:
#var target_velocity := Vector3()
var velocity_damp := .1

@onready var camera_rig    = $CameraRig
@onready var camera_target = $CameraRig/Target
@onready var camera_pitch  = $CameraRig/Target/SpringArm3D
@onready var camera_boom   = $CameraRig/Target/SpringArm3D
@onready var player_model  = $PlayerMesh
var camera_gamma := 0.0  # applied to camera_pitch node, rotation around player x axis
var min_camera_pitch := -PI/2
var max_camera_pitch := PI/2
var cam_h_shift := 0.0   # shift left or right off the player
var cam_v_shift := 0.0   # shift front or back
var cam_vv_shift := 0.0  # shift vertically to avoid head
var cam_v_offset := 0.0  # distance from player base to optimal camera height

enum CameraHover { Left, Right, Over } # How to center player in 3rd person view
var camera_hover := CameraHover.Over

enum CameraMode { Default, First, Third, VR } # TODO: VR!
#@export_enum(CameraMode) var camera_mode : int = CameraMode.Third <- how to export named enum??
var camera_mode = CameraMode.Default

@onready var spawn_position := position

##--------------------------- Run Loop Functions -----------------------------

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera_mode == CameraMode.First: SetFirstPerson()
	else: SetThirdPerson()
	cam_v_shift = abs($Proxy_Back.position.z)


func _physics_process(delta):
	# Add the gravity.
	UpdateGravity()
	
	var target_velocity : Vector3
	
	if not is_on_floor():
		#target_velocity -= (gravity * delta * 10) * up_direction
		velocity -= GRAVITY_MULTIPLIER * gravity * delta * up_direction
	else: #on floor
		# Handle Jump.
		if Input.is_action_just_pressed("char_jump"):
			# replace up velocity with jump velocity.. old should be 0 since on floor
			velocity = velocity - velocity.dot(up_direction) * up_direction + JUMP_VELOCITY * up_direction
			#target_velocity = JUMP_VELOCITY * 10 * up_direction
		else:
			# add a little downward to help stick to weird surfaces
			target_velocity = -up_direction
	
	
	# rotate camera rig in response to input
	var rotate_amount = 1.0 if Input.is_action_pressed("char_rotate_right") else 0.0 \
						- 1.0 if Input.is_action_pressed("char_rotate_left") else 0.0
	if abs(rotate_amount) > 1e-5: camera_rig.rotate(Vector3(0,-1,0), delta * 60 * ROTATION_SPEED * rotate_amount)
	
	# Get the input direction
	var input_dir = -Input.get_vector("char_strafe_left", "char_strafe_right", "char_forward", "char_backward")
	var player_dir = camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y) # now in Player space
	#print (player_dir)
	var direction = (transform.basis * player_dir).normalized() # now in world space
	
	var speed = SPRINT_SPEED if Input.is_action_pressed("char_sprint") else SPEED
	SetCharTilt(player_dir * speed / SPEED)
	
	# if no weird gravity stuff:
#	if direction:
#		velocity.x = direction.x * speed
#		velocity.z = direction.z * speed
#	else: # damp toward 0
#		velocity.x = move_toward(velocity.x, 0, speed)
#		velocity.z = move_toward(velocity.z, 0, speed)
	# if yes weird gravity stuff:
	if direction:
		target_velocity += direction * speed
	else: # damp toward 0
		#target_velocity.x = move_toward(velocity.x, 0, speed)
		pass

	AlignPlayerToUp()
	
	
	var dpos = position
	#velocity.move_toward(target_velocity, .5)
	var vertical_v = (velocity.dot(up_direction)) * up_direction
	velocity = vertical_v + target_velocity.lerp(velocity - vertical_v, .1) #note: velocity can't move_toward like a normal vector3
	#print ("velocity: ", velocity, ",  target velocity: ", target_velocity)
	#velocity.move_toward(global_transform.basis * target_velocity, .5)
	move_and_slide()
	dpos -= position # this is world coordinates change in position
	


func AlignPlayerToUp():
	var axis : Vector3 = global_transform.basis.y.cross(up_direction)
	var dot = global_transform.basis.y.dot(up_direction)
	var amount = asin(axis.length())
	if dot < 0:
		if abs(amount) < 1e-6: # we are trying to flip a 180
			axis = global_transform.basis.z
		amount = PI - amount
		#axis = -axis
	#print ("gravity check up amount: ", amount, ", dot: ", dot)
	if abs(amount) < 1e-6 && dot >= 0: return #without 0 check, errors about axis not being normalized, since it's 0 length
		
	axis = axis.normalized()
	if amount  > PI/24:
		# damp down extreme rotations
		global_transform.basis = global_transform.basis.rotated(axis.normalized(), PI/24 + (amount-PI/24)*.1)
	else:
		#print ("axis len: ", axis.length(), " ",axis.length_squared())
		global_transform.basis = global_transform.basis.rotated(axis, amount)
	
	#global_transform.basis = global_transform.basis.rotated(axis, amount)

func _process(_delta):
	pass

func _input(event):
	if settings_overlay && settings_overlay.visible:
		if event is InputEventKey:
			if event.physical_keycode == KEY_ESCAPE:
				print ("Escaped during menu")
				settings_overlay.visible = false
				get_tree().root.set_input_as_handled()


func _unhandled_input(event):
	# turn off mouse if you click
	if event is InputEventMouseButton:
		SetMouseVisible(false)
	
	# pan camera with mouse
	elif event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			HandleCameraMove(-event.relative.x * mouse_sensitivity,
							event.relative.y * mouse_sensitivity)
							
	# toggle mouse on/off
	if allow_mouse_toggle && Input.is_action_just_pressed("char_toggle_mouse"):
		SetMouseVisible(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	
	# camera zoom in and out
	if Input.is_action_just_pressed("char_zoom_in"):    HandleZoom(-zoom_amount)
	elif Input.is_action_just_pressed("char_zoom_out"): HandleZoom(zoom_amount)
	
	# change if camera hovers off to left, right, or center of player
	if camera_mode == CameraMode.Third && Input.is_action_just_pressed("char_camera_hover"):
		HandleHoverToggle()
	
	if Input.is_action_just_pressed("char_use1"):
		Use1(null)
	
	if Input.is_action_just_pressed("char_use2"):
		Use2(null)


##--------------------------- Handler Functions -----------------------------

# lerping machinery:
var target_rotation := 0.0
var target_tilt := 0.0
var tilt_damp := .2
var rotation_damp := .3

# Make player mesh point z in the provided direction (in player space), and also lean in that direction
func SetCharTilt(direction: Vector3):
	if direction.length() != 0: 
		var amount = sqrt(direction.x*direction.x + direction.z*direction.z)
		target_rotation = -atan2(-direction.x, direction.z)
		player_model.rotation.y = lerp_angle(player_model.rotation.y, target_rotation, rotation_damp)
		#print ("angle: ", atan2(-direction.x, direction.z))
		target_tilt = amount * .1 #* sign(direction.y)
		player_model.rotation.x = lerp_angle(player_model.rotation.x, target_tilt, tilt_damp)
		#print ("tilt: ", rad2deg(amount * tilt_damp))
	else:
		player_model.rotation.x = lerp_angle(player_model.rotation.x, 0, tilt_damp)


# Update camera yaw based on mouse movement x,y.
func HandleCameraMove(x,y):
	if invert_x: x = -x
	if invert_y: y = -y
	#camera_rig.rotation.y += x
	camera_rig.rotate(Vector3(0,1,0), x)
	camera_gamma = clamp(camera_gamma + y, min_camera_pitch, max_camera_pitch)
	SetCameraHoverTarget()


# Handle mouse visibility
func SetMouseVisible(yes: bool):
	if yes:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if settings_overlay: settings_overlay.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if settings_overlay: settings_overlay.visible = false


# Detect zoom related events and set camera boom distance
func HandleZoom(amount):
	if amount < 0:
		print("zoom in")
		if camera_boom.spring_length + amount < min_camera_distance:
			SetFirstPerson()
		else:
			camera_boom.spring_length = clamp(camera_boom.spring_length+amount,
											min_camera_distance, max_camera_distance)
	elif amount > 0:
		print("zoom out")
		if camera_mode == CameraMode.First:
			SetThirdPerson()
		else:
			camera_boom.spring_length = clamp(camera_boom.spring_length+amount,
											min_camera_distance, max_camera_distance)


# According to camera_hover, set the correct camera position
func HandleHoverToggle():
	match camera_hover:
		CameraHover.Left:  camera_hover = CameraHover.Right
		CameraHover.Right: camera_hover = CameraHover.Over
		CameraHover.Over:  camera_hover = CameraHover.Left
	SetHoverVars()
	SetCameraHoverTarget()


# According to camera_mode, set cam_v* offset variables.
func SetHoverVars():
	if camera_mode == CameraMode.First:
		cam_v_offset = $Proxy_FPS.position.y 
		cam_v_shift  = 0
		cam_vv_shift = 0
		
	elif camera_mode == CameraMode.Third:
		match camera_hover:
			CameraHover.Right:
				cam_h_shift = $Proxy_Right.position.x
				cam_v_offset = $Proxy_Right.position.y
			CameraHover.Over:
				cam_h_shift = 0
				cam_v_offset = $Proxy_FPS.position.y
			CameraHover.Left:
				cam_h_shift = $Proxy_Left.position.x
				cam_v_offset = $Proxy_Left.position.y
		cam_v_shift = abs($Proxy_Back.position.z)


# Set the camera_target position to point to the proper target. 
# Note camera_gamma, and cam_* need to be set beforehand.
func SetCameraHoverTarget():
	camera_pitch.rotation.x = camera_gamma
	var cosg = cos(camera_gamma) # note: will be 0..1..0
	var sing = sin(camera_gamma) # note: will be -1..0..1
	
	#print ("hoff: ", cam_h_shift, ", voff: ", cam_v_offset, ", v: ", cam_v_shift, ", vv: ", cam_vv_shift, " target.pos: ", camera_target.global_transform.origin)
	#print ("cam_v_shift: ", cam_v_shift)
	camera_target.position = Vector3(cam_h_shift * cosg,
								cam_v_offset + cam_vv_shift * cosg,
								-cam_v_shift * sing)


# Turn on the 3rd person player mesh, and move camera to minimum distance if necessary.
func SetThirdPerson():
	#if camera_mode == CameraMode.Third: return
	print ("Set 3rd person")
	camera_mode = CameraMode.Third
	if camera_boom.spring_length < min_camera_distance: 
		camera_boom.spring_length = min_camera_distance
	#cam_v_offset = $Proxy_Over.position.y
	#cam_v_shift  = $Proxy_FPS.position.y
	#cam_vv_shift = $Proxy_Over.position.y - cam_v_shift # gets added to cam_v_offset
	SetHoverVars()
	SetCameraHoverTarget()
	$PlayerMesh.visible = true


# Turn off the player mesh, and move camera to Proxy_FPS position.
#TODO: replace other player meshes with first person hands
func SetFirstPerson():
	if !allow_fp: return
	print ("Set 1st person")
	#if camera_mode == CameraMode.First: return
	camera_mode = CameraMode.First
	camera_target.position = $Proxy_FPS.position
	camera_boom.spring_length  = 0
	cam_v_offset = camera_target.position.y 
	cam_v_shift  = 0
	cam_vv_shift = 0
	$PlayerMesh.visible = false


func Use1(node):
	print("Use1: ", node.name if node != null else "null")

func Use2(node):
	print("Use2: ", node.name if node != null else "null")


#------------------------- Environment Gravity control ----------------------------------

var gravity_areas := []
var world_gravity_floor := -1.0
@export var world_max_height := 10
@export var world_min_height := -10


func EnteredGravityArea(area: Area3D):
	if not (area in gravity_areas):
		gravity_areas.append(area)
		print ("Player adding gravity area: ", area.name)


func ExitedGravityArea(area: Area3D):
	gravity_areas.erase(area)
	print ("Player removing gravity area: ", area.name)


func UpdateGravity():
	if gravity_areas.size() == 0:
		if global_transform.origin.y > world_max_height:
			up_direction = Vector3(0,1,0)
		elif global_transform.origin.y < world_min_height:
			up_direction = Vector3(0,-1,0)
	else:
		var n = 0
		var v = Vector3()
		for area in gravity_areas:
			n += 1
			v += area.UpdateGravityDirection(global_transform.origin)
		v /= n
		#todo: align direction should not always be the same as gravity direction
		up_direction = -v.normalized()
