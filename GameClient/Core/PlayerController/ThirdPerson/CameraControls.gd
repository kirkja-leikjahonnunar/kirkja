extends Node
class_name CameraControls


#------------------------------------- Exports -------------------------------------------

@export var camera_rig: Node3D

#------- Camera settings like fov, sensitivity, etc TODO: coordinate with options menu
var camera_settings := {}
@export var ROTATION_SPEED := .03


#------------------------------------- Variables -------------------------------------------

#------ Reference various camera components
@onready var camera_target = camera_rig.get_node("Target") # where camera should point. may be offset left or right from center
@onready var camera_pitch  = camera_rig.get_node("Target/SpringArm3D") # Rotate only around X 
@onready var camera_boom   = camera_rig.get_node("Target/SpringArm3D")



var camera_placements : CameraPlacements


#-------- Camera rig state
enum CameraHover { Left, Right, Over } # How to center player in 3rd person view
var camera_hover := CameraHover.Over

enum CameraMode { Default, First, Third, VR } # TODO: VR!
#@export_enum(CameraMode) var camera_mode : int = CameraMode.Third <- how to export named enum??
var camera_mode = CameraMode.Default

var camera_gamma := 0.0  # applied to camera_pitch node, rotation around player x axis

# These get changed according to camera_hover
var cam_h_shift := 0.0   # shift left or right off the player
var cam_v_shift := 0.0   # shift front or back
var cam_vv_shift := 0.0  # shift vertically to avoid head
var cam_v_offset := 0.0  # distance from player base to optimal camera height

# we accumulate mouse movements that get applied during the next _physics_process()
var gathered_cam_move : Vector2


#------------------------------------- Exports -------------------------------------------

func _ready():
	# *** connect to global camera settings
	if camera_settings.size() == 0:
		SetDefaultCameraSettings()
	
	if camera_placements == null && has_node("CameraPlacements"):
		camera_placements = get_node("CameraPlacements")


func SetDefaultCameraSettings():
	camera_settings = {
		# global device settings
		"mouse_sensitivity": 1.0,
		"pad_sensitivity": 1.0,
		"invert_x": false,
		"invert_y": false,
		"zoom_amount": .2,  # amount to zoom each wheel click
		
		# settings that may be overridden by context
		"fov": 75.0,
		"aim_fov": 50.0,
		"min_camera_pitch" : -PI/2,
		"max_camera_pitch" : PI/2,
		"min_camera_distance" : 0.5,  # below this, switch to 1st person
		"max_camera_distance" : 5.0,  # maximum to position camera away from player
		}


func custom_unhandled_input(event) -> bool:
	# pan camera with mouse
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			gathered_cam_move += Vector2((1 if camera_settings.invert_x else -1) * event.relative.x * camera_settings.mouse_sensitivity * .02,
										(1 if camera_settings.invert_y else -1) * event.relative.y * camera_settings.mouse_sensitivity * .02)
			#HandleCameraMove(-event.relative.x * mouse_sensitivity * .02,
			#				event.relative.y * mouse_sensitivity * .02)
			return true
	
	return false

#func _process(delta):
#	print (Input.is_action_just_pressed("char_zoom_in"))

func custom_physics_process(delta):
	# rotate camera rig in response to input
	var rotate_v = Input.get_vector("char_rotate_left", "char_rotate_right", "char_rotate_up", "char_rotate_down")
	rotate_v *= delta * 60 * ROTATION_SPEED
	if gathered_cam_move.length_squared() > 1e-5:
		rotate_v += gathered_cam_move
		gathered_cam_move = Vector2()
	if rotate_v.length_squared() > 1e-5: HandleCameraMove(rotate_v.x, rotate_v.y)
	
	#------------ check for actions ----------------
	
		# toggle mouse on/off   *** this should be handled by PlayerContext, not camera control
	#if allow_mouse_toggle && Input.is_action_just_pressed("char_toggle_mouse"):
	#	SetMouseVisible(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	
	#print (Input.is_action_just_pressed("char_zoom_in"))
	# camera zoom in and out
	if Input.is_action_just_released("char_zoom_in"):
		HandleZoom(-camera_settings.zoom_amount)
	elif Input.is_action_just_released("char_zoom_out"):
		HandleZoom(camera_settings.zoom_amount)
	
	# change if camera hovers off to left, right, or center of player
	if camera_mode == CameraMode.Third && Input.is_action_just_released("char_camera_hover"):
		HandleHoverToggle()


# Update camera yaw based on movement x,y.
func HandleCameraMove(x,y):
	if camera_settings.invert_x: x = -x
	if camera_settings.invert_y: y = -y
	#camera_rig.rotation.y += x
	camera_rig.rotate(Vector3(0,1,0), x)
	camera_gamma = clamp(camera_gamma + y, camera_settings.min_camera_pitch, camera_settings.max_camera_pitch)
	SetCameraHoverTarget()


# Detect zoom related events and set camera boom distance
func HandleZoom(amount):
	if amount < 0:
		print("zoom in")
		if camera_boom.spring_length + amount < camera_settings.min_camera_distance:
			SetFirstPerson()
		else:
			camera_boom.spring_length = clamp(camera_boom.spring_length+amount,
											camera_settings.min_camera_distance, camera_settings.max_camera_distance)
	elif amount > 0:
		print("zoom out")
		if camera_mode == CameraMode.First:
			SetThirdPerson()
		else:
			camera_boom.spring_length = clamp(camera_boom.spring_length+amount,
											camera_settings.min_camera_distance, camera_settings.max_camera_distance)


# Handle mouse visibility
func SetMouseVisible(yes: bool):
	if yes:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#if pause_menu: pause_menu.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#if pause_menu: pause_menu.visible = false


# Turn on the 3rd person player mesh, and move camera to minimum distance if necessary.
func SetThirdPerson():
	#if camera_mode == CameraMode.Third: return
	print ("Set 3rd person")
	camera_mode = CameraMode.Third
	if camera_boom.spring_length < camera_settings.min_camera_distance: 
		camera_boom.spring_length = camera_settings.min_camera_distance
	#cam_v_offset = $Proxy_Over.position.y
	#cam_v_shift  = $Proxy_FPS.position.y
	#cam_vv_shift = $Proxy_Over.position.y - cam_v_shift # gets added to cam_v_offset
	SetHoverVars()
	SetCameraHoverTarget()
	#player_model_parent.visible = true


# Turn off the player mesh, and move camera to Proxy_FPS position.
#TODO: replace other player meshes with first person hands
func SetFirstPerson():
	# if !allow_fp: return
	print ("Set 1st person")
	#if camera_mode == CameraMode.First: return
	camera_mode = CameraMode.First
	camera_target.position = camera_placements.proxy_fps if camera_placements != null else Vector3(0.0,1.5,0.0)
	camera_boom.spring_length  = 0
	cam_v_offset = camera_target.position.y 
	cam_v_shift  = 0
	cam_vv_shift = 0
	#player_model_parent.visible = false


# According to camera_hover, set the correct camera position
func HandleHoverToggle():
	match camera_hover:
		CameraHover.Left:  camera_hover = CameraHover.Right
		CameraHover.Right: camera_hover = CameraHover.Over
		CameraHover.Over:  camera_hover = CameraHover.Left
	SetHoverVars()
	SetCameraHoverTarget()


# Set the camera_target position, a point that the camera is supposed to point toward, to point to the proper target. 
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


# According to camera_mode, set cam_v* offset variables that are used in SetCameraHoverTarget().
func SetHoverVars():
	if camera_mode == CameraMode.First:
		cam_v_offset = camera_placements.proxy_fps.y if camera_placements != null else 1.5
		cam_v_shift  = 0
		cam_vv_shift = 0
	
	elif camera_mode == CameraMode.Third:
		if camera_placements:
			match camera_hover:
				CameraHover.Right:
					cam_h_shift = camera_placements.proxy_right.x
					cam_v_offset = camera_placements.proxy_right.y
				CameraHover.Over:
					cam_h_shift = 0
					cam_v_offset = camera_placements.proxy_fps.y
				CameraHover.Left:
					cam_h_shift = camera_placements.proxy_left.x
					cam_v_offset = camera_placements.proxy_left.y
			cam_v_shift = abs(camera_placements.proxy_back.z)
		else:
			match camera_hover:
				CameraHover.Right:
					cam_h_shift = -1.0
					cam_v_offset = 1.5
				CameraHover.Over:
					cam_h_shift = 0
					cam_v_offset = 1.5
				CameraHover.Left:
					cam_h_shift = 1.0
					cam_v_offset = 1.5
			cam_v_shift = 1



#------------------------------ Global syncing functions ------------------------------------

# The MainCamera object will lerp the actual camera to the returned node's transform.
func GetCameraProxy() -> Node3D:
	return get_node("CameraRig/Target/SpringArm3D/Camera3D")
