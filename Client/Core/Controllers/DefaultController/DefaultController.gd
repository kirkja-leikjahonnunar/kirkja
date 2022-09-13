extends Node

# **** PROBABLY DON'T USE (?)... rename PlayerController to DefaultController??

#
# Basic movement controls: left, right, forward, backward, jump, sprint.
#

#------------------------- Movement settings ----------------------------

@export_group("Movement")
@export var SPEED := 5.0
@export var SPRINT_SPEED := 10.0
@export var ROTATION_SPEED := .03
@export var JUMP_VELOCITY := 8.5
@export var GRAVITY_MULTIPLIER := 2.0

#------------------------- Camera settings ----------------------------

@export_group("Camera")
@export var camera_rig : Node3D # note, will have camera_rig.camera_settings
@export var allow_fp : bool = true # allow First Person mode

#whether context allows using mouse cursor, should not be 
@export var allow_mouse_toggle := true


#------------------------- World Properties ----------------------------
@export_group("World Properties")

#TODO: these should probably be higher level globals
@export var world_max_height := 10
@export var world_min_height := -10


@export_group("AAAA WHY!?!?!?! export_group broken?") #TODO: remove this when inspector list doesn't get doubled
## AAAA!! repeated properties in inspector.. why???


#------------------------- Variables ----------------------------

@onready var char_body = get_parent()


# The actual active camera. We really only need this to change fov.
#TOOD: this should probably be coordinated more directly via settings window
var main_camera : Camera3D # assume this will be "../MainCamera", set in ready

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# to help smooth out the player movement:
#var target_velocity := Vector3()
var velocity_damp := .1

@onready var player_model_parent  = $PlayerMesh
var player_mesh


#enum CameraHover { Left, Right, Over } # How to center player in 3rd person view
#var camera_hover := CameraHover.Over
#
enum CameraMode { Default, First, Third, VR } # TODO: VR!
##@export_enum(CameraMode) var camera_mode : int = CameraMode.Third <- how to export named enum??
var camera_mode = CameraMode.Default

# store initial spawn position for easy out of bounds respawn
@onready var spawn_position : Vector3 = char_body.position



##--------------------------- Settings Accessors -----------------------------

# This is used by MainCamera
func GetCameraProxy() -> Node3D:
	return get_node("CameraRig/Target/SpringArm3D/Camera3D")


##--------------------------- Interface -----------------------------


# Turn on the 3rd person player mesh, and move camera to minimum distance if necessary.
func SetThirdPerson():
	#if camera_mode == CameraMode.Third: return
	print ("PlayerController set 3rd person")
	#if camera_rig: camera_rig.SetThirdPerson()
	player_model_parent.visible = true


# Turn off the player mesh, and move camera to Proxy_FPS position.
#TODO: replace other player meshes with first person hands
func SetFirstPerson():
	if !allow_fp: return
	print ("PlayerController set 1st person")
	#if camera_rig: camera_rig.SetFirstPerson()
	player_model_parent.visible = false



##--------------------------- Run Loop Functions -----------------------------

func _ready():
	if camera_rig == null && has_node("CameraRig"):
		camera_rig = get_node("CameraRig")
	if camera_rig == null && has_node("../CameraRig"):
		camera_rig = get_node("../CameraRig")
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#if camera_mode == CameraMode.First: SetFirstPerson()
	#else: SetThirdPerson()
	
	if !main_camera && has_node("../MainCamera"):
		main_camera = get_node("../MainCamera")
	
	if player_model_parent.get_child_count() > 0: player_mesh = player_model_parent.get_child(0)



# some cached position status
var last_on_floor: bool

func _physics_process(delta):
	# Coordinate gravity. Sets up_direction.
	UpdateGravity()
	
	var target_velocity : Vector3
	
	var just_jumped: bool = false
	
	if not char_body.is_on_floor():
		#target_velocity -= (gravity * delta * 10) * up_direction
		char_body.velocity -= GRAVITY_MULTIPLIER * gravity * delta * char_body.up_direction
	else: #on floor
		# Handle Jump.
		if Input.is_action_just_pressed("char_jump"):
			just_jumped = true
			# replace up velocity with jump velocity.. old should be 0 since on floor
			char_body.velocity = char_body.velocity - char_body.velocity.dot(char_body.up_direction) * char_body.up_direction + JUMP_VELOCITY * char_body.up_direction
			#target_velocity = JUMP_VELOCITY * 10 * up_direction
		else:
			# add a little downward to help stick to weird surfaces
			target_velocity = -char_body.up_direction
	
	
	# do input handling for camera rig
	if camera_rig: camera_rig.custom_physics_process(delta)
#	
	
	# Get the input direction
	var input_dir = -Input.get_vector("char_strafe_left", "char_strafe_right", "char_forward", "char_backward")
	var speed = input_dir.length()
	var player_dir = camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y) # now in Player space
	#print (player_dir)
	var direction = (char_body.transform.basis * player_dir).normalized() # now in parent space
	
	var sprinting : bool = Input.is_action_pressed("char_sprint")
	speed = speed * (SPRINT_SPEED if sprinting else SPEED)
	SetCharTilt(player_dir * speed / SPEED)
	
	# Animation syncing
	if player_model_parent.get_child_count() > 0:
		player_model_parent.get_child(0).SetSpeed(input_dir.length() * (2.0 if sprinting else 1.0) - 1.0)
	
	
	if direction:
		target_velocity += direction * speed
	else: # damp toward 0
		#target_velocity.x = move_toward(velocity.x, 0, speed)
		pass

	AlignPlayerToUp()
	
	
	#var dpos = position
	var vertical_v = (char_body.velocity.dot(char_body.up_direction)) * char_body.up_direction
	char_body.velocity = vertical_v + target_velocity.lerp(char_body.velocity - vertical_v, .1) #note: velocity can't move_toward like a normal vector3
	#print ("velocity: ", velocity, ",  target velocity: ", target_velocity)
	char_body.move_and_slide()
	#dpos -= position # this is world coordinates change in position
	
	# Animation syncing
	if player_mesh:
		if just_jumped:
			if ! char_body.is_on_floor():
				if last_on_floor: # we jumped while on the floor
					player_mesh.JumpStart()
				else: #jumped while not on floor, just make sure we are falling?
					player_mesh.Falling()
		else: # not just jumped
			if last_on_floor && not char_body.is_on_floor(): # we probably walked off something
				player_mesh.Falling()
			elif not last_on_floor && char_body.is_on_floor(): # landed somewhere
				player_mesh.JumpEnd()
	
	last_on_floor = char_body.is_on_floor() # cache to help select proper animation when transitioning
	
	# # network sync
	# DefinePlayerState()


# Align the CharacterBody3D to the current up_direction.
func AlignPlayerToUp():
	var axis : Vector3 = char_body.global_transform.basis.y.cross(char_body.up_direction)
	var dot = char_body.global_transform.basis.y.dot(char_body.up_direction)
	var amount = asin(axis.length())
	if dot < 0:
		if abs(amount) < 1e-6: # we are trying to flip a 180
			axis = char_body.global_transform.basis.z
		amount = PI - amount
		#axis = -axis
	#print ("gravity check up amount: ", amount, ", dot: ", dot)
	if abs(amount) < 1e-6 && dot >= 0: return #without 0 check, errors about axis not being normalized, since it's 0 length
		
	axis = axis.normalized()
	if amount  > PI/24:
		# damp down extreme rotations
		char_body.global_transform.basis = char_body.global_transform.basis.rotated(axis.normalized(), PI/24 + (amount-PI/24)*.1)
	else:
		#print ("axis len: ", axis.length(), " ",axis.length_squared())
		char_body.global_transform.basis = char_body.global_transform.basis.rotated(axis, amount)
	
	#global_transform.basis = global_transform.basis.rotated(axis, amount)


func _unhandled_input(event):
	# turn off mouse if you click
	if event is InputEventMouseButton:
		SetMouseVisible(false)
	
	# toggle mouse on/off
	if allow_mouse_toggle && Input.is_action_just_pressed("char_toggle_mouse"):
		SetMouseVisible(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	
	if camera_rig: camera_rig.custom_unhandled_input(event)
	
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

# Make player mesh parent point z in the provided direction (in player space), and also lean in that direction
func SetCharTilt(direction: Vector3):
	if player_model_parent == null: return
	
	if direction.length() != 0: 
		var amount = sqrt(direction.x*direction.x + direction.z*direction.z)
		target_rotation = -atan2(-direction.x, direction.z)
		player_model_parent.rotation.y = lerp_angle(player_model_parent.rotation.y, target_rotation, rotation_damp)
		#print ("angle: ", atan2(-direction.x, direction.z))
		target_tilt = amount * .1 #* sign(direction.y)
		player_model_parent.rotation.x = lerp_angle(player_model_parent.rotation.x, target_tilt, tilt_damp)
		#print ("tilt: ", rad_to_deg(amount * tilt_damp))
	else:
		player_model_parent.rotation.x = lerp_angle(player_model_parent.rotation.x, 0, tilt_damp)


# Handle mouse visibility
func SetMouseVisible(yes: bool):
	if yes:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#if pause_menu: pause_menu.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#if pause_menu: pause_menu.visible = false


##--------------------------- Action functions -----------------------------

func Use1(node):
	print("Use1: ", node.name if node != null else "null")
	if proximity_areas.size() > 0:
		#TODO: find area closest to 
		var thing = proximity_areas[0]
		#if thing is InhabitableTrigger:
		#	Inhabit(thing.get_parent())
		#else: thing.Use()
		#----
		thing.Use()

func Use2(node):
	print("Use2: ", node.name if node != null else "null")


#------------------------- Proximity controls ----------------------------------

var proximity_areas := []

# A ProximityTrigger will call this so the player controller can coordinate interacting with things.
func AddProximityTrigger(trigger):
	if not proximity_areas.has(trigger):
		#proximity_areas.append(trigger)
		proximity_areas.push_front(trigger)

# A ProximityTrigger will call this so the player controller can coordinate interacting with things.
func RemoveProximityTrigger(trigger):
	proximity_areas.erase(trigger)


#------------------------- Environment Gravity control ----------------------------------

var gravity_areas := []
#var world_gravity_floor := -1.0


# A GravityArea will call this so that the player can keep track of intended gravity.
func EnteredGravityArea(area: Area3D):
	if not (area in gravity_areas):
		gravity_areas.append(area)
		print ("Player adding gravity area: ", area.name)


# A GravityArea will call this so that the player can keep track of intended gravity.
func ExitedGravityArea(area: Area3D):
	gravity_areas.erase(area)
	print ("Player removing gravity area: ", area.name)


func UpdateGravity():
	if gravity_areas.size() == 0:
		if char_body.global_transform.origin.y > world_max_height:
			char_body.up_direction = Vector3(0,1,0)
		elif char_body.global_transform.origin.y < world_min_height:
			char_body.up_direction = Vector3(0,-1,0)
	else:
		var n = 0
		var v = Vector3()
		for area in gravity_areas:
			n += 1
			v += area.UpdateGravityDirection(char_body.global_transform.origin)
		v /= n
		#todo: align direction should not always be the same as gravity direction
		char_body.up_direction = -v.normalized()


#------------------------- Settings updates ----------------------------------

func ConnectOptionsWindow(win):
	#settings_overlay = win
	#settings_overlay.setting_changed.connect(_on_settings_updated)
	win.setting_changed.connect(_on_settings_updated)


func _on_settings_updated(setting, value):
	match setting:
		"fov":
			camera_rig.camera_settings.fov_degrees = value
			if main_camera:
				main_camera.fov = value
		"aim_fov":
			camera_rig.camera_settings.aim_fov_degrees = value
		"mouse_sensitivity":
			camera_rig.camera_settings.mouse_sensitivity = value
		"pad_sensitivity":
			camera_rig.camera_settings.pad_sensitivity = value
		"invert_x":
			camera_rig.camera_settings.invert_x = value
		"invert_y":
			camera_rig.camera_settings.invert_y = value



