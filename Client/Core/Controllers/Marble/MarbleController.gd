extends RigidBody3D


@export_group("Context")
@export var active := true
@export var persistent_shell := true

@export_group("Camera")
@export var allow_first_person := true

@export_group("Forces")
@export var force_multiplier := 10
@export var v_force_multiplier := 2
@export var gravity := 1.0
@export var jump_force := 5.0


var player_model_parent
var initial_position : Vector3


#----------------------------- main -------------------------------------

func _ready():
	initial_position = position
	player_model_parent = $PlayerMesh
	
	print ("cam settings at ship _ready: ", $FollowPosition/CameraRig.camera_settings)
	$FollowPosition/CameraRig.camera_settings["max_camera_distance"] = 15
	$FollowPosition/CameraRig.camera_settings["min_camera_distance"] = 2



func _physics_process(delta):
	if active:
		HandleMovement(delta)
	
	$FollowPosition.global_position = global_position
	
	$FollowPosition/CameraRig.custom_physics_process(delta)
	
	HandleActions()
	
	if global_position.y < -20:
		position = initial_position
		linear_velocity = Vector3()


func HandleActions():
	if Input.is_action_just_pressed("char_use1"):
		Use1(null)
	
	if Input.is_action_just_pressed("char_use2"):
		Use2(null)


func _input(event):
	if not active: return
	
#	# turn off mouse if you click
#	if event is InputEventMouseButton && event.pressed == false && Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
#		SetMouseVisible(false)
#		get_viewport().set_input_as_handled()
#		return
#
#	# toggle mouse on/off
#	if allow_mouse_toggle && Input.is_action_just_pressed("char_toggle_mouse"):
#		SetMouseVisible(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	
	# this accumulates mouse move events for the camera:
	$FollowPosition/CameraRig.custom_unhandled_input(event)


#------------------------------- Input handling ---------------------------------------

func HandleMovement(_delta):
	var force_vector = Vector3()
	
#	if Input.is_action_pressed("char_fly_up"):
#		force_vector.y += 1.0 * v_force_multiplier
#	if Input.is_action_pressed("char_fly_down"):
#		force_vector.y -= 1.0
	
	var input_dir = -Input.get_vector("char_strafe_left", "char_strafe_right", "char_forward", "char_backward")
	
	force_vector += Vector3(input_dir.y, 0, -input_dir.x)
	force_vector = get_parent().global_transform.basis * ($FollowPosition/CameraRig.global_transform.basis * force_vector)
	
	#print ("force: ", force_vector)
	print ("Collisions: ", collisions)
	apply_torque(force_multiplier * force_vector)
	
	if Input.is_action_just_pressed("char_jump"):
		apply_central_impulse(Vector3(0,jump_force,0))


#----------------------------------- Signals ----------------------------------------------

var collisions := []

func _on_marble_body_entered(body):
	collisions.append(body)


func _on_marble_body_exited(body):
	collisions.erase(body)


##--------------------------- Action functions -----------------------------

func Use1(node):
	print("Use1: ", node.name if node != null else "null")
	if proximity_areas.size() > 0:
		#TODO: find area closest to 
		var thing = proximity_areas[0]
		if thing is InhabitableTrigger && has_node("PlayerContext"):
			#get_node("PlayerContext").Inhabit(thing.get_parent())
			get_node("PlayerContext").Inhabit(thing.GetInhabitableObject())
		else: thing.Use()
		#----
		#thing.Use()

func Use2(node):
	print("Use2: ", node.name if node != null else "null")


#------------------------- Proximity controls ----------------------------------

var proximity_areas := []

# A ProximityTrigger will call this so the player controller can coordinate interacting with things.
func AddProximityTrigger(trigger) -> bool:
	if !active: return false
	if not proximity_areas.has(trigger):
		#proximity_areas.append(trigger)
		proximity_areas.push_front(trigger)
		return true
	return false

# A ProximityTrigger will call this so the player controller can coordinate interacting with things.
func RemoveProximityTrigger(trigger):
	proximity_areas.erase(trigger)


##--------------------------- Player context Accessors -----------------------------

# This is used by MainCamera
func GetCameraProxy() -> Node3D:
	return get_node("FollowPosition/CameraRig/Target/SpringArm3D/Camera3D")


func SetNameFromId(game_client_id):
	name = str(game_client_id)
	get_node("FollowPosition/Name").text = name

#----Called by CameraControls:

# Turn on the 3rd person player mesh, and move camera to minimum distance if necessary.
func SetThirdPerson():
	#if camera_mode == CameraMode.Third: return
	print ("MarbleController set 3rd person")
	#if camera_rig: camera_rig.SetThirdPerson()
	player_model_parent.visible = true


# Turn off the player mesh, and move camera to Proxy_FPS position.
#TODO: replace other player meshes with first person hands
func SetFirstPerson():
	if !allow_first_person: return
	print ("PlayerController set 1st person")
	#if camera_rig: camera_rig.SetFirstPerson()
	player_model_parent.visible = false



#------------------------ Overrideable functions, context related ----------------------------

## Stub for custom camera placements.
#func GetCameraPlacements() -> CameraPlacements: return null


# Return the bounding box of the player at rest.
#func GetRestAABB() -> AABB: return AABB()


# Whether this mesh as various things implemented on it, such as "walk", or "climb".
#(not used yet)
#func HasFeature(_feature) -> bool:
#	return false


func SetAsInhabited():
	$FollowPosition/InhabitableTrigger.SetUninhabitable()
#	if has_node("InhabitableTrigger"):
#		var node = get_node("InhabitableTrigger")
#		node.SetUninhabitable()

func SetAsUninhabited():
	$FollowPosition/InhabitableTrigger.SetInhabitable()
#	if has_node("InhabitableTrigger"):
#		var node = get_node("InhabitableTrigger")
#		node.SetInhabitable()

# Make the model disappear, and remove from tree
func Deresolution():
	print ("removing ", name)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(0, 0, 0), 0.15).finished.connect(Finalize)

# Callback to queue_free(). By default this is called from Deresolution().
func Finalize():
	queue_free()

