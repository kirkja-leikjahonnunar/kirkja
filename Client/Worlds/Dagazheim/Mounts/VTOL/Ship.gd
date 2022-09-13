extends RigidDynamicBody3D



@export_group("Context")
@export var active := true
@export var persistent_shell := true

@export_group("Camera")
@export var allow_first_person := true

@export_group("Forces")
@export var force_multiplier := 10.0
@export var torque_multiplier := 5.0
@export var v_force_multiplier := 1.75
@export var gravity := 1.0
@export var jump_force := 5.0


var initial_position : Vector3


func _ready():
	initial_position = position
	
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



func HandleMovement(delta):
	
	#---compute thrust
	var force_vector = Vector3()
	
	if Input.is_action_pressed("char_fly_up"):
		force_vector.y += 1.0 * v_force_multiplier
	if Input.is_action_pressed("char_fly_down"):
		force_vector.y -= 1.0
	
	var input_dir : Vector2 = -Input.get_vector("char_thrust_left", "char_thrust_right", "char_thrust_forward", "char_thrust_backward")
	
	force_vector += Vector3(input_dir.x, 0, input_dir.y)
	#force_vector = get_parent().global_transform.basis * ($FollowPosition/CameraRig.global_transform.basis * force_vector)
	force_vector = basis * force_vector
	
	#print ("force: ", force_vector)
	apply_central_force(force_multiplier * force_vector)
	
	
	#---compute torque
	force_vector = Vector3(Input.get_axis("char_pitch1", "char_pitch2"),
							Input.get_axis("char_yaw1", "char_yaw2"),
							Input.get_axis("char_roll1", "char_roll2")
							)
	apply_torque(basis * (torque_multiplier * force_vector))
	
	#apply_torque(torque_multiplier * Input.get_axis("char_pitch1", "char_pitch2") * (basis * Vector3(1,0,0)))
	#apply_torque(torque_multiplier * Input.get_axis("char_yaw1", "char_yaw2") * (basis * Vector3(0,1,0)))
	#apply_torque(torque_multiplier * Input.get_axis("char_roll1", "char_roll2") * (basis * Vector3(0,0,1)))
	
	if global_position.y < -20:
		position = initial_position
		linear_velocity = Vector3()


func HandleActions():
	if Input.is_action_just_pressed("char_use1"):
		Use1(null)
	
	if Input.is_action_just_pressed("char_use2"):
		Use2(null)


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



##--------------------------- Action functions -----------------------------

func Use1(node):
	print("Use1: ", node.name if node != null else "null")
	if proximity_areas.size() > 0:
		#TODO: find area closest to 
		var thing = proximity_areas[0]
#		if thing is InhabitableTrigger && has_node("PlayerContext"):
#			#get_node("PlayerContext").Inhabit(thing.get_parent())
#			get_node("PlayerContext").Inhabit(thing.GetInhabitableObject())
#		else: thing.Use()
		#----
		thing.Use()

func Use2(node):
	print("Use2: ", node.name if node != null else "null")


##--------------------------- Player context Accessors -----------------------------

# This is used by MainCamera
func GetCameraProxy() -> Node3D:
	return get_node("FollowPosition/CameraRig/Target/SpringArm3D/Camera3D")

