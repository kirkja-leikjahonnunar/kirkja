extends PlayerController
class_name Voxeling


const VOXEL : PackedScene = preload("res://Maps/VoxelVillage/Voxel/Voxel.tscn")


func _ready():
	super._ready()
	print ("Voxeling _ready()")
	
	#SPRINT_SPEED = 0.8
	#SPEED = 0.4
	#JUMP_VELOCITY = 2.3


func SpawnVoxel():
	var voxel = VOXEL.instantiate()
	voxel.position = position
	#get_parent().AddVoxel(voxel)
	get_parent().add_child(voxel)


##func _physics_process(delta):
## This is an override called during _physics_process().
#func HandleMovementOLD(delta):
#	if  Input.is_action_just_pressed("voxeling_add_voxel"):
#		print("Adding voxel.")
#		SpawnVoxel()
#
#	# Add the gravity.
#	if not is_on_floor():
#		velocity.y -= gravity * delta
#
#	# Handle Jump.
#	if Input.is_action_just_pressed("char_jump") and is_on_floor():
#		Jump()
#
#	# Get the input direction and handle the movement/deceleration.
#	# As good practice, you should replace UI actions with custom gameplay actions.
#	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
#	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	if direction:
#		velocity.x = direction.x * SPEED
#		velocity.z = direction.z * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		velocity.z = move_toward(velocity.z, 0, SPEED)
#
#	move_and_slide()


var need_to_jump := false
func Jump():
	#OLD: velocity.y = JUMP_VELOCITY
	need_to_jump = true


func HandleMovement(delta):
	
	if  Input.is_action_just_pressed("voxeling_add_voxel"):
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
	
	if char_body.global_transform.origin.y < world_min_height/2:
		char_body.position = spawn_position
	
	# # network sync
	# DefinePlayerState()


func _on_drill_body_entered(body):
	print ("drill entered ", body.name, ", ", body.get_parent().name, ", on floor: ", is_on_floor(), ", action pressed: ", Input.is_action_pressed("voxeling_eraser_mode"))
	if Input.is_action_pressed("voxeling_eraser_mode"):
		if not is_on_floor():
			if body is Voxel:
				Jump()
				body.call_deferred("queue_free") # This works but throws errors in editor.


func _on_bump_body_entered(body):
	print ("bump entered ", body.name, ", ", body.get_parent().name)
	if Input.is_action_pressed("voxeling_eraser_mode"):
		if body is Voxel:
			body.call_deferred("queue_free") # This works but throws errors in editor. # This works but throws errors in editor.
