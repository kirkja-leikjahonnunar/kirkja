#
# Mixed third and first person character controller.
#

extends CharacterBody3D
class_name PlayerController


# @export_group  ... alpha 12
@export var SPEED := 5.0
@export var SPRINT_SPEED := 10.0
@export var ROTATION_SPEED := .03
@export var JUMP_VELOCITY := 8.5
@export var GRAVITY_MULTIPLIER := 2.0

@export var allow_fp : bool = true # allow First Person mode
@export var min_camera_distance := 0.5  # below this, switch to 1st person
@export var max_camera_distance := 5.0  # below this, switch to 1st person
@export var zoom_amount := .2 #amound to zoom each wheel click
@export var fov_degrees := 75.0
@export var aim_fov_degrees := 40.0

@export var mouse_sensitivity := 1.0 #.02
@export var invert_y := false
@export var invert_x := true
@export var allow_mouse_toggle := true

# We need direct link to settings to get things like fov or mouse sensitivity change
@export var SettingsOverlay : NodePath
#@onready var settings_overlay = get_node(SettingsOverlay) if !SettingsOverlay.is_empty() else null

@export var PauseMenu : NodePath
@onready var pause_menu = get_node(PauseMenu) if !PauseMenu.is_empty() else null

var main_camera : Camera3D

# If not null, use this as the player mesh instead of default capsule model
@export var alt_player_mesh : PackedScene


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


##--------------------------- Settings Accessors -----------------------------

func GetCameraProxy() -> Node3D:
	return get_node("CameraRig/Target/SpringArm3D/Camera3D")


##--------------------------- Run Loop Functions -----------------------------

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera_mode == CameraMode.First: SetFirstPerson()
	else: SetThirdPerson()
	cam_v_shift = abs($Proxy_Back.position.z)
	#if pause_menu: pause_menu.visible = false
	
	if alt_player_mesh:
		var pmesh = alt_player_mesh.instantiate()
		for child in $PlayerMesh.get_children():
			child.visible = false
		$PlayerMesh.add_child(pmesh)
	
	if !SettingsOverlay.is_empty():
		ConnectOptionsWindow(SettingsOverlay)
	
	if !main_camera && has_node("../MainCamera"):
		main_camera = get_node("../MainCamera")
	
	call_deferred("ReadyClean")

func ReadyClean():
	if player_model.get_child_count() > 0:
		player_model.get_child(0).SetAsInhabited()


func _physics_process(delta):
	# Coordinate gravity.
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
	#var rotate_amount = 1.0 if Input.is_action_pressed("char_rotate_right") else 0.0 \
	#					- 1.0 if Input.is_action_pressed("char_rotate_left") else 0.0
	#var rotate_amount = rotate_v.x
	#if abs(rotate_amount) > 1e-5: camera_rig.rotate(Vector3(0,-1,0), rotate_amount)
	var rotate_v = Input.get_vector("char_rotate_left", "char_rotate_right", "char_rotate_up", "char_rotate_down")
	rotate_v *= delta * 60 * ROTATION_SPEED
	if gathered_cam_move.length_squared() > 1e-5:
		rotate_v += gathered_cam_move
		gathered_cam_move = Vector2()
	if rotate_v.length_squared() > 1e-5: HandleCameraMove(rotate_v.x, rotate_v.y)
	
	
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
	
	
	#var dpos = position
	#velocity.move_toward(target_velocity, .5)
	var vertical_v = (velocity.dot(up_direction)) * up_direction
	velocity = vertical_v + target_velocity.lerp(velocity - vertical_v, .1) #note: velocity can't move_toward like a normal vector3
	#print ("velocity: ", velocity, ",  target velocity: ", target_velocity)
	#velocity.move_toward(global_transform.basis * target_velocity, .5)
	move_and_slide()
	#dpos -= position # this is world coordinates change in position
	
	DefinePlayerState()


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


#func _input(event):
#	if pause_menu && pause_menu.visible:
#		if event is InputEventKey:
#			if event.physical_keycode == KEY_ESCAPE && event.pressed == false: # on key release
#				pause_menu.visible = false
#				get_viewport().set_input_as_handled()


# we accumulate mouse movements that get applied during the next _physics_process()
var gathered_cam_move : Vector2

func _unhandled_input(event):
	# turn off mouse if you click
	if event is InputEventMouseButton:
		SetMouseVisible(false)
	
	# pan camera with mouse
	elif event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			gathered_cam_move += Vector2((1 if invert_x else -1) * event.relative.x * mouse_sensitivity * .02,
										(1 if invert_y else -1) * event.relative.y * mouse_sensitivity * .02)
			#HandleCameraMove(-event.relative.x * mouse_sensitivity * .02,
			#				event.relative.y * mouse_sensitivity * .02)
	
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
	if player_model == null: return
	
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
		#if pause_menu: pause_menu.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#if pause_menu: pause_menu.visible = false


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
	if proximity_areas.size() > 0:
		#TODO: find area closest to 
		var thing = proximity_areas[0]
		if thing is InhabitableTrigger:
			Inhabit(thing.get_parent())
		else: thing.Use()

func Use2(node):
	print("Use2: ", node.name if node != null else "null")



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
	var old_player_model = player_model.get_child(0)
	
	# we need this to later orient new model to orientation of old model
	var target_global_basis = old_player_model.global_transform.basis
	
	# reparent old model
	var tr = old_player_model.global_transform
	player_model.remove_child(old_player_model)
	get_parent().add_child(old_player_model)
	old_player_model.global_transform = tr
	
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
	var tr = pending_player_model.global_transform
	pending_player_model.get_parent().remove_child(pending_player_model)
	player_model.add_child(pending_player_model)
	pending_player_model.global_transform = tr
	pending_player_model.SetAsInhabited()
	proximity_areas.erase(pending_player_model.get_node("InhabitableTrigger"))
	pending_player_model = null


#------------------------- Proximity controls ----------------------------------

var proximity_areas := []

func AddProximityTrigger(trigger):
	if not proximity_areas.has(trigger):
		#proximity_areas.append(trigger)
		proximity_areas.push_front(trigger)

func RemoveProximityTrigger(trigger):
	proximity_areas.erase(trigger)


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


#------------------------- Settings updates ----------------------------------


func ConnectPauseMenu(win):
	pause_menu = win

func ConnectOptionsWindow(win):
	#settings_overlay = win
	#settings_overlay.setting_changed.connect(_on_settings_updated)
	win.setting_changed.connect(_on_settings_updated)

func _on_settings_updated(setting, value):
	match setting:
		"fov":
			fov_degrees = value
			if main_camera:
				main_camera.fov = fov_degrees
		"aim_fov":
			aim_fov_degrees = value
		"mouse_sensitivity":
			mouse_sensitivity = value
		"invert_x":
			invert_x = value
		"invert_y":
			invert_y = value


#--------------------- Network sync helpers ---------------------------------

# This needs to be called from _physics_process
func DefinePlayerState():
	var player_state = { "T": GameServer.client_clock, 
						"P": global_transform.origin,
						"R": global_transform.basis.get_rotation_quaternion(),
						"R2": $PlayerMesh.basis.get_rotation_quaternion()
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


