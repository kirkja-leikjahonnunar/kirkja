#
# PlayerController coordinates input to PlayerContext, as well as switching contexts.
# Basic movement controls are built in, but can be overridden by the specific PlayerContext in use.
#

extends CharacterBody3D
class_name PlayerController


#------------------------- Movement settings ----------------------------

@export_group("Movement")
@export var SPEED := 5.0
@export var SPRINT_SPEED := 10.0
@export var ROTATION_SPEED := .03
@export var JUMP_VELOCITY := 8.5
@export var GRAVITY_MULTIPLIER := 2.0

#------------------------- Camera settings ----------------------------

@export_group("Camera")
@export var camera_rig : Node3D
@export var allow_fp : bool = true # allow First Person mode
#@export var min_camera_distance := 0.5  # below this, switch to 1st person
#@export var max_camera_distance := 5.0  # maximum to position camera away from player
#@export var zoom_amount := .2 #amount to zoom each wheel click
#@export var fov_degrees := 75.0
#@export var aim_fov_degrees := 40.0
#@export var mouse_sensitivity := 1.0 #.02
#@export var pad_sensitivity := 1.0
#@export var invert_y := false
#@export var invert_x := true

#whether context allows using mouse cursor, should not be 
@export var allow_mouse_toggle := true


#------------------------- Overlay ui ----------------------------
@export_group("Overlays")

# We need direct link to settings to get things like fov or mouse sensitivity change
@export var SettingsOverlay : NodePath
#@onready var settings_overlay = get_node(SettingsOverlay) if !SettingsOverlay.is_empty() else null


#------------------------- World Properties ----------------------------
@export_group("World Properties")

#TODO: these should probably be higher level globals
@export var world_max_height := 10
@export var world_min_height := -10


@export_group("AAAA WHY!?!?!?! export_group broken?")
## AAAA!! repeated properties in inspector.. why???


#------------------------- Variables ----------------------------

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

#var camera_gamma := 0.0  # applied to camera_pitch node, rotation around player x axis
#var min_camera_pitch := -PI/2
#var max_camera_pitch := PI/2
#var cam_h_shift := 0.0   # shift left or right off the player
#var cam_v_shift := 0.0   # shift front or back
#var cam_vv_shift := 0.0  # shift vertically to avoid head
#var cam_v_offset := 0.0  # distance from player base to optimal camera height

#enum CameraHover { Left, Right, Over } # How to center player in 3rd person view
#var camera_hover := CameraHover.Over
#
enum CameraMode { Default, First, Third, VR } # TODO: VR!
##@export_enum(CameraMode) var camera_mode : int = CameraMode.Third <- how to export named enum??
var camera_mode = CameraMode.Default

# store initial spawn position for easy out of bounds respawn
@onready var spawn_position := position


##--------------------------- Settings Accessors -----------------------------

func GetCameraProxy() -> Node3D:
	return get_node("CameraRig/Target/SpringArm3D/Camera3D")


##--------------------------- Interface -----------------------------


# Turn on the 3rd person player mesh, and move camera to minimum distance if necessary.
func SetThirdPerson():
	#if camera_mode == CameraMode.Third: return
	print ("Set 3rd person")
	if camera_rig: camera_rig.SetThirdPerson()
	player_model_parent.visible = true


# Turn off the player mesh, and move camera to Proxy_FPS position.
#TODO: replace other player meshes with first person hands
func SetFirstPerson():
	if !allow_fp: return
	print ("Set 1st person")
	if camera_rig: camera_rig.SetFirstPerson()
	player_model_parent.visible = false


##--------------------------- Run Loop Functions -----------------------------

func _ready():
	if camera_rig == null && has_node("CameraRig"):
		camera_rig = get_node("CameraRig")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera_mode == CameraMode.First: SetFirstPerson()
	else: SetThirdPerson()
	#cam_v_shift = abs($Proxy_Back.position.z)
	
	
	if !SettingsOverlay.is_empty():
		ConnectOptionsWindow(SettingsOverlay)
	
	if !main_camera && has_node("../MainCamera"):
		main_camera = get_node("../MainCamera")
	
	if player_model_parent.get_child_count() > 0: player_mesh = player_model_parent.get_child(0)
	
	call_deferred("ReadyClean")

func ReadyClean():
	if player_model_parent.get_child_count() > 0:
		player_model_parent.get_child(0).SetAsInhabited()


# some cached position status
var last_on_floor: bool

func _physics_process(delta):
	# Coordinate gravity. Sets up_direction.
	UpdateGravity()
	
	var target_velocity : Vector3
	
	var just_jumped: bool = false
	
	if not is_on_floor():
		#target_velocity -= (gravity * delta * 10) * up_direction
		velocity -= GRAVITY_MULTIPLIER * gravity * delta * up_direction
	else: #on floor
		# Handle Jump.
		if Input.is_action_just_pressed("char_jump"):
			just_jumped = true
			# replace up velocity with jump velocity.. old should be 0 since on floor
			velocity = velocity - velocity.dot(up_direction) * up_direction + JUMP_VELOCITY * up_direction
			#target_velocity = JUMP_VELOCITY * 10 * up_direction
		else:
			# add a little downward to help stick to weird surfaces
			target_velocity = -up_direction
	
	if camera_rig: camera_rig.custom_physics_process(delta)
#	# rotate camera rig in response to input
#	var rotate_v = Input.get_vector("char_rotate_left", "char_rotate_right", "char_rotate_up", "char_rotate_down")
#	rotate_v *= delta * 60 * ROTATION_SPEED
#	if gathered_cam_move.length_squared() > 1e-5:
#		rotate_v += gathered_cam_move
#		gathered_cam_move = Vector2()
#	if rotate_v.length_squared() > 1e-5: HandleCameraMove(rotate_v.x, rotate_v.y)
	
	
	# Get the input direction
	var input_dir = -Input.get_vector("char_strafe_left", "char_strafe_right", "char_forward", "char_backward")
	var player_dir = camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y) # now in Player space
	#print (player_dir)
	var direction = (transform.basis * player_dir).normalized() # now in world space
	
	var sprinting : bool = Input.is_action_pressed("char_sprint")
	var speed = SPRINT_SPEED if sprinting else SPEED
	SetCharTilt(player_dir * speed / SPEED)
	
	# Animation syncing
	if player_model_parent.get_child_count() > 0:
		player_model_parent.get_child(0).SetSpeed(input_dir.length() * (2.0 if sprinting else 1.0) - 1.0)
	
	
	# if yes weird gravity stuff:
	if direction:
		target_velocity += direction * speed
	else: # damp toward 0
		#target_velocity.x = move_toward(velocity.x, 0, speed)
		pass

	AlignPlayerToUp()
	
	#print (Input.is_action_just_pressed("char_zoom_in"), " ", Input.is_action_just_pressed("char_jump"))

	
	#var dpos = position
	#velocity.move_toward(target_velocity, .5)
	var vertical_v = (velocity.dot(up_direction)) * up_direction
	velocity = vertical_v + target_velocity.lerp(velocity - vertical_v, .1) #note: velocity can't move_toward like a normal vector3
	#print ("velocity: ", velocity, ",  target velocity: ", target_velocity)
	#velocity.move_toward(global_transform.basis * target_velocity, .5)
	move_and_slide()
	#dpos -= position # this is world coordinates change in position
	
	if player_mesh:
		if just_jumped:
			if ! is_on_floor():
				if last_on_floor: # we jumped while on the floor
					player_mesh.JumpStart()
				else: #jumped while not on floor, just make sure we are falling?
					player_mesh.Falling()
		else: # not just jumped
			if last_on_floor && not is_on_floor(): # we probably walked off something
				player_mesh.Falling()
			elif not last_on_floor && is_on_floor(): # landed somewhere
				player_mesh.JumpEnd()
	
	last_on_floor = is_on_floor()
	
	# network sync
	DefinePlayerState()


# Align the CharacterBody3D to the current up_direction.
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


# we accumulate mouse movements that get applied during the next _physics_process()
var gathered_cam_move : Vector2

func _unhandled_input(event):
	# turn off mouse if you click
	if event is InputEventMouseButton:
		SetMouseVisible(false)
	
	# toggle mouse on/off
	if allow_mouse_toggle && Input.is_action_just_pressed("char_toggle_mouse"):
		SetMouseVisible(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	
	## change if camera hovers off to left, right, or center of player
	#if camera_rig && camera_mode == CameraMode.Third && Input.is_action_just_pressed("char_camera_hover"):
	# 	camera_rig.HandleHoverToggle()
	
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
		#print ("tilt: ", rad2deg(amount * tilt_damp))
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


#--------------------------- Body hopping -----------------------------------

var pending_player_model = null

func Inhabit(object):
	if pending_player_model:
		print ("cannot inhabit ", object.name, ", pending on ", pending_player_model.name)
		return
	print ("....trying to inhabit ", object.name)
	
	#-------- old model needs to be:
	# - deparented
	# - highlightable if not being removed
	# - optionally removed
	var old_player_model = player_model_parent.get_child(0)
	
	# we need this to later orient new model to orientation of old model
	var target_global_basis = old_player_model.global_transform.basis
	
	# reparent old model
	var _tr = old_player_model.global_transform
	player_model_parent.remove_child(old_player_model)
	get_parent().add_child(old_player_model)
	old_player_model.global_transform = _tr
	player_mesh = null
	
	# get rid of the old model if we have to
	if old_player_model.persistent_shell:
		# old player model gets abandonded and just sits in the world
		old_player_model.SetAsUninhabited()
	else:
		old_player_model.Deresolution()
	
	
	#--------- new model:
	# - must dehighlight
	# - must be lerped to by player controller
	# - reparent after lerp
	pending_player_model = object
	
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", object.global_position, 0.15) #.finished.connect(ReparentNewModel)
	
	object.SetAsInhabited()
	#tween = get_tree().create_tween()
	tween.tween_property(pending_player_model, "global_transform:basis", target_global_basis, 0.15).finished.connect(ReparentNewModel)


# Callback to finish inhabiting.
func ReparentNewModel():
	print ("finishing inhabit of ", pending_player_model.name)
	var gtr = pending_player_model.global_transform
	pending_player_model.get_parent().remove_child(pending_player_model)
	player_model_parent.add_child(pending_player_model)
	player_mesh = pending_player_model
	pending_player_model.global_transform = gtr
	pending_player_model.SetAsInhabited()
	proximity_areas.erase(pending_player_model.get_node("InhabitableTrigger"))
	pending_player_model = null


##--------------------------- Action functions -----------------------------

func Use1(node):
	print("Use1: ", node.name if node != null else "null")
	if proximity_areas.size() > 0:
		#TODO: find area closest to 
		var thing = proximity_areas[0]
		if thing is InhabitableTrigger:
			Inhabit(thing.get_parent())
		else: thing.Use()

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


#--------------------- Network sync helpers ---------------------------------

# This needs to be called from _physics_process
func DefinePlayerState():
	var player_state = { "T": GameServer.client_clock, 
						"P": global_transform.origin,
						"R": global_transform.basis.get_rotation_quaternion(),
						"R2": player_model_parent.basis.get_rotation_quaternion()
						}
	GameServer.SendPlayerState(player_state)


func SetNameFromId(game_client_id):
	name = str(game_client_id)
	$Name.text = name


#TODO: this might be used if all collision processing is done on server
func MovePlayer(_pos, _rot, _rot2):
	pass
	#global_transform.origin = pos
	#global_transform.basis = Basis(rot)


