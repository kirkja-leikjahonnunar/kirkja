extends CharacterBody3D
class_name Voxeling

const VOXEL : PackedScene = preload("res://Maps/VoxelVillage/assets/Voxel.tscn")

const SPEED = 0.4
const JUMP_VELOCITY = 1.5

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func SpawnVoxel():
	var voxel = VOXEL.instantiate()
	voxel.position = position
	get_parent().AddVoxel(voxel)


func Jump():
	velocity.y = JUMP_VELOCITY


func _physics_process(delta):
	if  Input.is_action_just_pressed("voxeling_add_voxel"):
		print("Adding voxel.")
		SpawnVoxel()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("char_jump") and is_on_floor():
		Jump()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func _on_drill_body_entered(body):
	if Input.is_action_pressed("voxeling_eraser_mode"):
		if not is_on_floor():
			if body is Voxel:
				Jump()
				body.call_deferred("queue_free") # This works but throws errors in editor.


func _on_bump_body_entered(body):
	if Input.is_action_pressed("voxeling_eraser_mode"):
		if body is Voxel:
			body.call_deferred("queue_free") # This works but throws errors in editor. # This works but throws errors in editor.
